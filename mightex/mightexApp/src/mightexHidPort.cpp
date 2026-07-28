/* mightexHidPort.cpp
 *
 * asynOctet/asynCommon port driver for the Mightex Sirius SLC-series USB
 * LED controller, talking to the device's raw HID interface via
 * /dev/hidraw* ioctls (HIDIOCSFEATURE / HIDIOCGFEATURE), and presenting
 * a standard asynOctet interface so StreamDevice can drive it with an
 * ordinary protocol file, exactly as it would a serial port.
 *
 * Framing was reverse-engineered from a USB capture of the vendor
 * Windows tool and validated against real hardware via a standalone
 * Python/hidraw prototype before this port was written. See
 * mightexHidPort.h for the framing summary.
 *
 * IMPORTANT: asynCommon and asynOctet are plain C structs of function
 * pointers, not C++ interfaces -- there is no vtable. This class uses
 * composition, not inheritance: ordinary member functions do the real
 * work, and free-standing trampoline functions (matching the exact
 * void* drvPvt signatures asyn expects) forward calls into them. Static
 * struct instances holding pointers to the trampolines -- not `this` --
 * are what get registered with asynManager. This mirrors the pattern
 * used by asyn's own drvAsynSerialPort.c.
 *
 * TODO before production use:
 *   - Honor pasynUser->timeout properly in read()/write() rather than
 *     the fixed inter-chunk delay copied from the Python prototype.
 *   - Add retry/backoff on transient ioctl EAGAIN/EWOULDBLOCK.
 *   - Confirm behavior when the utnserver Pro connection drops mid-
 *     transfer (ioctl should fail; disconnect/reconnect path needs
 *     exercising against that failure mode specifically).
 */

#include <cerrno>
#include <cstdio>
#include <cstring>
#include <string>

#include <fcntl.h>
#include <linux/hidraw.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include <asynDriver.h>  // asynCommon is defined here in asyn R4-45, not a separate header
#include <asynOctet.h>
#include <epicsExport.h>
#include <epicsMutex.h>
#include <epicsThread.h>
#include <iocsh.h>

#include "mightexHidPort.h"

namespace {
const int REPORT_SIZE = 18;                  // HID feature report payload bytes
const int CHUNK_SIZE = 16;                   // usable ASCII bytes per report
const unsigned char MARKER_BYTE = 0x01;
const double CHUNK_DELAY_SEC = 0.03;         // NOTE: 0.01 proved marginal --
                                              // observed intermittent truncated
                                              // reads at 0.01 that only
                                              // disappeared when debug printf
                                              // overhead accidentally added
                                              // extra inter-chunk spacing.
                                              // Bumped for reliability; still
                                              // a fixed guess, not a real
                                              // ready-signal from the device.
const double READ_SETTLE_DELAY_SEC = 0.05;   // settle time before first GET_REPORT,
                                              // mirrors the Python prototype's
                                              // sleep between send_command() and
                                              // read_response() -- without this,
                                              // the first GET_REPORT can race the
                                              // device and return stale leftover
                                              // report content from a prior
                                              // transaction instead of the new
                                              // response.
const int MAX_READ_CHUNKS = 32;
const char *DRIVER_NAME = "mightexHidPort";
}  // namespace

// Plain class -- NOT inheriting from asynCommon/asynOctet. Those are
// C structs of function pointers; C++ inheritance from them plus
// virtual methods corrupts the memory layout asyn expects. See header
// comment above.
class mightexHidPort {
public:
    mightexHidPort(const char *portName, const char *hidrawDevice,
                   int priority, int noAutoConnect);
    ~mightexHidPort();

    // asynCommon-equivalent methods
    void report(FILE *fp, int details);
    asynStatus connect(asynUser *pasynUser);
    asynStatus disconnect(asynUser *pasynUser);

    // asynOctet-equivalent methods
    asynStatus write(asynUser *pasynUser, const char *data, size_t numchars,
                      size_t *nbytesTransfered);
    asynStatus read(asynUser *pasynUser, char *data, size_t maxchars,
                     size_t *nbytesTransfered, int *eomReason);
    asynStatus flush(asynUser *pasynUser);
    asynStatus setInputEos(asynUser *pasynUser, const char *eos, int eoslen);
    asynStatus getInputEos(asynUser *pasynUser, char *eos, int eossize,
                            int *eoslen);
    asynStatus setOutputEos(asynUser *pasynUser, const char *eos, int eoslen);
    asynStatus getOutputEos(asynUser *pasynUser, char *eos, int eossize,
                             int *eoslen);

    std::string portName_;

private:
    asynStatus setFeatureReport(asynUser *pasynUser,
                                 const unsigned char *chunkData18);
    asynStatus getFeatureReport(asynUser *pasynUser,
                                unsigned char *chunkData18);
    asynStatus openDevice(asynUser *pasynUser);
    void closeDevice();
    void handleIoctlFailure(asynUser *pasynUser);
    // Assumes lock_ is already held by the caller. Factored out of
    // connect() so write()/read() can attempt an inline reconnect
    // without deadlocking on the same non-recursive mutex they're
    // already holding.
    asynStatus reconnectLocked(asynUser *pasynUser);

    std::string hidrawDevice_;
    int fd_;
    bool connected_;
    epicsMutexId lock_;
    asynInterface commonInterface_;
    asynInterface octetInterface_;
    std::string inputEos_;
    std::string outputEos_;

    // Persistent read buffer: asyn's read() contract allows (and
    // StreamDevice relies on) a single logical response being served
    // across MULTIPLE read() calls, each bounded by that call's own
    // maxchars. Fetching the whole HID-chunked response in one go and
    // returning only maxchars of it -- discarding the rest -- silently
    // loses data whenever the caller's buffer is smaller than the full
    // response (confirmed happening in practice: StreamDevice sizes its
    // buffer to the literal pattern being matched, e.g. 2 bytes for
    // "##", not to the full response length). pendingBuffer_ retains
    // whatever hasn't been served yet; pendingEosFound_ remembers
    // whether the ORIGINAL fetch (which filled pendingBuffer_ from the
    // device) ended on a genuine terminator match, so that eomReason is
    // reported correctly on the final call that drains the buffer.
    std::string pendingBuffer_;
    bool pendingEosFound_;
};

// ---------------------------------------------------------------------
// Trampolines: free functions matching asyn's exact C function-pointer
// signatures. Each casts drvPvt back to mightexHidPort* and forwards.
// ---------------------------------------------------------------------

static void trampReport(void *drvPvt, FILE *fp, int details) {
    static_cast<mightexHidPort *>(drvPvt)->report(fp, details);
}
static asynStatus trampConnect(void *drvPvt, asynUser *pasynUser) {
    return static_cast<mightexHidPort *>(drvPvt)->connect(pasynUser);
}
static asynStatus trampDisconnect(void *drvPvt, asynUser *pasynUser) {
    return static_cast<mightexHidPort *>(drvPvt)->disconnect(pasynUser);
}
static asynStatus trampWrite(void *drvPvt, asynUser *pasynUser,
                              const char *data, size_t numchars,
                              size_t *nbytesTransfered) {
    return static_cast<mightexHidPort *>(drvPvt)->write(
        pasynUser, data, numchars, nbytesTransfered);
}
static asynStatus trampRead(void *drvPvt, asynUser *pasynUser, char *data,
                             size_t maxchars, size_t *nbytesTransfered,
                             int *eomReason) {
    return static_cast<mightexHidPort *>(drvPvt)->read(
        pasynUser, data, maxchars, nbytesTransfered, eomReason);
}
static asynStatus trampFlush(void *drvPvt, asynUser *pasynUser) {
    return static_cast<mightexHidPort *>(drvPvt)->flush(pasynUser);
}
static asynStatus trampSetInputEos(void *drvPvt, asynUser *pasynUser,
                                    const char *eos, int eoslen) {
    return static_cast<mightexHidPort *>(drvPvt)->setInputEos(pasynUser, eos,
                                                               eoslen);
}
static asynStatus trampGetInputEos(void *drvPvt, asynUser *pasynUser,
                                    char *eos, int eossize, int *eoslen) {
    return static_cast<mightexHidPort *>(drvPvt)->getInputEos(
        pasynUser, eos, eossize, eoslen);
}
static asynStatus trampSetOutputEos(void *drvPvt, asynUser *pasynUser,
                                     const char *eos, int eoslen) {
    return static_cast<mightexHidPort *>(drvPvt)->setOutputEos(pasynUser, eos,
                                                                eoslen);
}
static asynStatus trampGetOutputEos(void *drvPvt, asynUser *pasynUser,
                                     char *eos, int eossize, int *eoslen) {
    return static_cast<mightexHidPort *>(drvPvt)->getOutputEos(
        pasynUser, eos, eossize, eoslen);
}

// Static struct instances holding trampoline pointers -- these are what
// get registered with asynManager, never `this`.
static asynCommon commonMethods = {trampReport, trampConnect,
                                    trampDisconnect};

// registerInterruptUser/cancelInterruptUser are left NULL here --
// pasynOctetBase->initialize() supplies its own wrapping implementation
// for those when interruptProcess is enabled (see constructor).
static asynOctet octetMethods = {
    trampWrite,       trampRead,        trampFlush,
    NULL,             NULL,             trampSetInputEos,
    trampGetInputEos, trampSetOutputEos, trampGetOutputEos};

// ---------------------------------------------------------------------

mightexHidPort::mightexHidPort(const char *portName, const char *hidrawDevice,
                                int priority, int noAutoConnect)
    : portName_(portName), hidrawDevice_(hidrawDevice), fd_(-1),
      connected_(false), pendingEosFound_(false) {
    lock_ = epicsMutexCreate();

    asynStatus status = pasynManager->registerPort(
        portName, ASYN_CANBLOCK, /*autoConnect*/ !noAutoConnect, priority, 0);
    if (status != asynSuccess) {
        printf("%s: registerPort failed for %s\n", DRIVER_NAME, portName);
        return;
    }

    commonInterface_.interfaceType = asynCommonType;
    commonInterface_.pinterface = &commonMethods;
    commonInterface_.drvPvt = this;
    status = pasynManager->registerInterface(portName, &commonInterface_);
    if (status != asynSuccess) {
        printf("%s: registerInterface (asynCommon) failed for %s\n",
               DRIVER_NAME, portName);
        return;
    }

    octetInterface_.interfaceType = asynOctetType;
    octetInterface_.pinterface = &octetMethods;
    octetInterface_.drvPvt = this;
    // processEosIn=0, processEosOut=0: we handle terminator detection
    // ourselves in read()/write() rather than delegating to
    // asynOctetBase's generic EOS processing.
    // interruptProcess=0: no I/O Intr / asynchronous callback support
    // for this first pass -- StreamDevice's synchronous request/response
    // use doesn't need it. Revisit if that changes.
    status = pasynOctetBase->initialize(portName, &octetInterface_, 0, 0, 0);
    if (status != asynSuccess) {
        printf("%s: pasynOctetBase->initialize failed for %s\n", DRIVER_NAME,
               portName);
        return;
    }

    if (!noAutoConnect) {
        asynUser *pasynUser = pasynManager->createAsynUser(0, 0);
        pasynManager->connectDevice(pasynUser, portName, 0);
        connect(pasynUser);
        pasynManager->disconnect(pasynUser);
        pasynManager->freeAsynUser(pasynUser);
    }
}

mightexHidPort::~mightexHidPort() {
    closeDevice();
    epicsMutexDestroy(lock_);
}

asynStatus mightexHidPort::openDevice(asynUser *pasynUser) {
    fd_ = open(hidrawDevice_.c_str(), O_RDWR);
    if (fd_ < 0) {
        if (pasynUser) {
            epicsSnprintf(pasynUser->errorMessage, pasynUser->errorMessageSize,
                           "%s: could not open %s: %s", DRIVER_NAME,
                           hidrawDevice_.c_str(), strerror(errno));
        }
        return asynError;
    }
    return asynSuccess;
}

void mightexHidPort::closeDevice() {
    if (fd_ >= 0) {
        close(fd_);
        fd_ = -1;
    }
}

asynStatus mightexHidPort::reconnectLocked(asynUser *pasynUser) {
    // Caller must already hold lock_.
    if (connected_) {
        return asynSuccess;
    }
    pasynTrace->print(pasynUser, ASYN_TRACE_FLOW,
                       "%s: attempting to open %s\n", DRIVER_NAME,
                       hidrawDevice_.c_str());
    asynStatus status = openDevice(pasynUser);
    if (status == asynSuccess) {
        connected_ = true;
        pasynTrace->print(pasynUser, ASYN_TRACE_FLOW, "%s: connected\n",
                           DRIVER_NAME);
        pasynManager->exceptionConnect(pasynUser);
    }
    return status;
}

asynStatus mightexHidPort::connect(asynUser *pasynUser) {
    epicsMutexLock(lock_);
    asynStatus status = reconnectLocked(pasynUser);
    epicsMutexUnlock(lock_);
    return status;
}

asynStatus mightexHidPort::disconnect(asynUser *pasynUser) {
    epicsMutexLock(lock_);
    closeDevice();
    connected_ = false;
    epicsMutexUnlock(lock_);
    pasynTrace->print(pasynUser, ASYN_TRACE_FLOW, "%s: disconnected\n",
                       DRIVER_NAME);
    pasynManager->exceptionDisconnect(pasynUser);
    return asynSuccess;
}

void mightexHidPort::report(FILE *fp, int details) {
    fprintf(fp, "Port %s: %s, connected=%s, fd=%d\n", portName_.c_str(),
            hidrawDevice_.c_str(), connected_ ? "yes" : "no", fd_);
}

void mightexHidPort::handleIoctlFailure(asynUser *pasynUser) {
    // An ioctl failure on a previously-good fd almost always means the
    // underlying device vanished out from under us -- confirmed
    // happening after a device-issued Reset command, which causes real
    // USB re-enumeration (a new USB device number, even though
    // /dev/hidrawN may keep the same path). The old fd becomes
    // permanently dead at that point.
    //
    // IMPORTANT: this deliberately does NOT call
    // pasynManager->exceptionDisconnect(). Confirmed by testing: doing
    // so causes asynManager's queueRequest to refuse ALL future
    // requests to this port with "queueRequest failed" before our
    // code even runs again -- autoConnect does not retry connect()
    // automatically the way its name suggests. Recovery is instead
    // handled entirely inline, self-contained within the ioctl
    // wrappers below (close, reopen, retry once), so asynManager never
    // needs to be told anything happened.
    closeDevice();
    connected_ = false;
    pendingBuffer_.clear();
    pendingEosFound_ = false;
}

asynStatus mightexHidPort::setFeatureReport(asynUser *pasynUser,
                                             const unsigned char *chunkData18) {
    for (int attempt = 0; attempt < 2; ++attempt) {
        unsigned char buf[1 + REPORT_SIZE];
        buf[0] = 0;  // report ID 0 -- device does not use numbered reports
        memcpy(&buf[1], chunkData18, REPORT_SIZE);

        // Trace the outgoing HID Feature report at the same byte-level
        // detail that ad-hoc printf debugging relied on all through this
        // driver's development -- now available on demand via
        // asynSetTraceIOMask("<port>", 0, 0x8) (ASYN_TRACEIO_DRIVER)
        // rather than needing to add/remove debug code by hand.
        pasynTrace->printIO(pasynUser, ASYN_TRACEIO_DRIVER,
                             reinterpret_cast<const char *>(chunkData18),
                             REPORT_SIZE, "%s: HIDIOCSFEATURE ->",
                             DRIVER_NAME);

        int ret = ioctl(fd_, HIDIOCSFEATURE(sizeof(buf)), buf);
        if (ret >= 0) {
            return asynSuccess;
        }

        epicsSnprintf(pasynUser->errorMessage, pasynUser->errorMessageSize,
                       "%s: HIDIOCSFEATURE failed: %s", DRIVER_NAME,
                       strerror(errno));
        pasynTrace->print(pasynUser, ASYN_TRACE_ERROR,
                           "%s: HIDIOCSFEATURE failed: %s\n", DRIVER_NAME,
                           strerror(errno));

        if (attempt == 0) {
            // First failure: assume a stale fd (e.g. from device
            // re-enumeration) and try exactly one inline recover-and-
            // retry before giving up.
            pasynTrace->print(pasynUser, ASYN_TRACE_FLOW,
                               "%s: attempting inline reconnect after "
                               "ioctl failure\n",
                               DRIVER_NAME);
            handleIoctlFailure(pasynUser);
            if (openDevice(pasynUser) == asynSuccess) {
                connected_ = true;
                continue;  // retry the ioctl once against the new fd
            }
        }
        return asynError;
    }
    return asynError;  // unreachable
}

asynStatus mightexHidPort::getFeatureReport(asynUser *pasynUser,
                                             unsigned char *chunkData18) {
    for (int attempt = 0; attempt < 2; ++attempt) {
        unsigned char buf[1 + REPORT_SIZE];
        buf[0] = 0;
        int ret = ioctl(fd_, HIDIOCGFEATURE(sizeof(buf)), buf);
        if (ret >= 0) {
            memcpy(chunkData18, &buf[1], REPORT_SIZE);
            pasynTrace->printIO(pasynUser, ASYN_TRACEIO_DRIVER,
                                 reinterpret_cast<const char *>(chunkData18),
                                 REPORT_SIZE, "%s: HIDIOCGFEATURE <-",
                                 DRIVER_NAME);
            return asynSuccess;
        }

        epicsSnprintf(pasynUser->errorMessage, pasynUser->errorMessageSize,
                       "%s: HIDIOCGFEATURE failed: %s", DRIVER_NAME,
                       strerror(errno));
        pasynTrace->print(pasynUser, ASYN_TRACE_ERROR,
                           "%s: HIDIOCGFEATURE failed: %s\n", DRIVER_NAME,
                           strerror(errno));

        if (attempt == 0) {
            pasynTrace->print(pasynUser, ASYN_TRACE_FLOW,
                               "%s: attempting inline reconnect after "
                               "ioctl failure\n",
                               DRIVER_NAME);
            handleIoctlFailure(pasynUser);
            if (openDevice(pasynUser) == asynSuccess) {
                connected_ = true;
                continue;  // retry the ioctl once against the new fd
            }
        }
        return asynError;
    }
    return asynError;  // unreachable
}

asynStatus mightexHidPort::write(asynUser *pasynUser, const char *data,
                                  size_t numchars, size_t *nbytesTransfered) {
    epicsMutexLock(lock_);
    *nbytesTransfered = 0;

    pasynTrace->printIO(pasynUser, ASYN_TRACEIO_DRIVER, data, numchars,
                         "%s: write() numchars=%zu", DRIVER_NAME, numchars);

    if (!connected_) {
        asynStatus reconnectStatus = reconnectLocked(pasynUser);
        if (reconnectStatus != asynSuccess) {
            epicsMutexUnlock(lock_);
            // pasynUser->errorMessage already set by openDevice() via
            // reconnectLocked on failure.
            return asynError;
        }
        // Reconnected successfully -- fall through and continue with
        // this write using the freshly (re)opened device.
    }

    // A new command means any leftover, unconsumed bytes from a
    // PREVIOUS response are now stale -- e.g. a trailing byte that
    // wasn't part of a literal match (confirmed happening: "1 byte
    // surplus input" on a prior exchange) must not bleed into the next
    // command's read(). Discard before issuing the new command.
    pendingBuffer_.clear();
    pendingEosFound_ = false;

    // NOTE: StreamDevice's protocol "out" template typically already has
    // the configured terminator appended to `data` before this is called
    // -- this driver does not append one itself.

    size_t offset = 0;
    while (offset < numchars) {
        size_t chunkLen = numchars - offset;
        if (chunkLen > static_cast<size_t>(CHUNK_SIZE)) {
            chunkLen = CHUNK_SIZE;
        }
        unsigned char report[REPORT_SIZE];
        memset(report, 0, REPORT_SIZE);
        report[0] = MARKER_BYTE;
        report[1] = static_cast<unsigned char>(chunkLen);
        memcpy(&report[2], data + offset, chunkLen);

        asynStatus status = setFeatureReport(pasynUser, report);
        if (status != asynSuccess) {
            epicsMutexUnlock(lock_);
            return status;
        }
        offset += chunkLen;
        epicsThreadSleep(CHUNK_DELAY_SEC);
    }

    *nbytesTransfered = numchars;
    epicsMutexUnlock(lock_);
    return asynSuccess;
}

asynStatus mightexHidPort::read(asynUser *pasynUser, char *data,
                                 size_t maxchars, size_t *nbytesTransfered,
                                 int *eomReason) {
    epicsMutexLock(lock_);
    *nbytesTransfered = 0;
    if (eomReason) {
        *eomReason = 0;
    }

    if (!connected_) {
        asynStatus reconnectStatus = reconnectLocked(pasynUser);
        if (reconnectStatus != asynSuccess) {
            epicsMutexUnlock(lock_);
            return asynError;
        }
        // Reconnected successfully -- fall through and continue with
        // this read using the freshly (re)opened device.
    }

    // Only hit the hardware when nothing is left over from a previous
    // call. This is what allows one logical device response to be
    // served across multiple read() calls with different maxchars, as
    // StreamDevice expects -- see pendingBuffer_ comment in the header.
    // (Confirmed necessary in practice: StreamDevice sizes its read
    // buffer to the literal pattern being matched -- e.g. 2 bytes for
    // "##" -- not to the full response length, and calls read() again
    // for more if the first call didn't end in EOS.)
    if (pendingBuffer_.empty()) {
        std::string assembled;
        bool eosFound = false;
        double timeoutSec = pasynUser->timeout;

        pasynTrace->print(pasynUser, ASYN_TRACE_FLOW,
                           "%s: read() maxchars=%zu timeout=%f (%s)\n",
                           DRIVER_NAME, maxchars, timeoutSec,
                           timeoutSec <= 0.0 ? "quick probe" : "timed read");

        if (timeoutSec <= 0.0) {
            // A timeout of exactly 0 (or negative) is standard asyn
            // convention for "non-blocking, single immediate check" --
            // NOT "caller has no preference, use your own default".
            // Confirmed via timing instrumentation: StreamDevice issues
            // exactly this kind of call (timeoutSec=0.000000) as a
            // quick "anything pending?" probe before every command, and
            // an earlier version of this fix wrongly treated timeout<=0
            // as "fall back to the ~1.0-1.25s fixed MAX_READ_CHUNKS
            // loop" -- which meant this quick probe paid the full fixed
            // cost every single time regardless, adding roughly a full
            // second of pure overhead to every scan-triggered command
            // and starving the scan list under any real channel count.
            // Do exactly one attempt, no settle delay, no retry loop,
            // and return whatever comes back (likely empty -- that's
            // the correct, fast answer to "nothing pending yet").
            unsigned char report[REPORT_SIZE];
            asynStatus status = getFeatureReport(pasynUser, report);
            if (status != asynSuccess) {
                epicsMutexUnlock(lock_);
                return status;
            }
            unsigned char chunkLen = report[1];
            if (chunkLen > CHUNK_SIZE) {
                chunkLen = CHUNK_SIZE;
            }
            assembled.append(reinterpret_cast<char *>(&report[2]), chunkLen);
            if (!inputEos_.empty() && assembled.size() >= inputEos_.size() &&
                assembled.compare(assembled.size() - inputEos_.size(),
                                   inputEos_.size(), inputEos_) == 0) {
                eosFound = true;
            }
        } else {
            // Real read with a genuine caller-specified timeout (e.g.
            // StreamDevice's ReplyTimeout for an actual command
            // response). Let the device finish preparing its response
            // before the first GET_REPORT -- without this, the first
            // read can race the device and return stale content left
            // over from a prior transaction.
            epicsThreadSleep(READ_SETTLE_DELAY_SEC);

            struct timespec loopStart;
            clock_gettime(CLOCK_MONOTONIC, &loopStart);

            for (int i = 0; i < MAX_READ_CHUNKS; ++i) {
                struct timespec now;
                clock_gettime(CLOCK_MONOTONIC, &now);
                double elapsed = (now.tv_sec - loopStart.tv_sec) +
                                  (now.tv_nsec - loopStart.tv_nsec) / 1e9;
                if (elapsed >= timeoutSec) {
                    break;  // caller's requested timeout has elapsed
                }

                unsigned char report[REPORT_SIZE];
                asynStatus status = getFeatureReport(pasynUser, report);
                if (status != asynSuccess) {
                    epicsMutexUnlock(lock_);
                    return status;
                }

                unsigned char chunkLen = report[1];
                if (chunkLen > CHUNK_SIZE) {
                    chunkLen = CHUNK_SIZE;  // defensive clamp against malformed data
                }
                assembled.append(reinterpret_cast<char *>(&report[2]), chunkLen);

                if (!inputEos_.empty() && assembled.size() >= inputEos_.size() &&
                    assembled.compare(assembled.size() - inputEos_.size(),
                                       inputEos_.size(), inputEos_) == 0) {
                    eosFound = true;
                    break;
                }

                if (chunkLen < CHUNK_SIZE && !assembled.empty()) {
                    // Short chunk with no EOS match, AFTER we've already
                    // accumulated some real content -- treat as end of
                    // data. Deliberately does NOT fire on a still-empty
                    // buffer: a zero-length chunk before any real data
                    // has arrived means the device hasn't finished
                    // preparing its response yet (confirmed bug -- this
                    // used to terminate the read immediately with an
                    // empty result on marginal timing, e.g.
                    // intermittently for ?STROBE while ?CURRENT happened
                    // to be reliably fast enough not to trigger it).
                    break;
                }

                epicsThreadSleep(CHUNK_DELAY_SEC);
            }
        }

        pendingBuffer_ = assembled;
        pendingEosFound_ = eosFound;
    }

    // Serve up to maxchars from whatever's pending, retaining any
    // leftover in pendingBuffer_ for a subsequent call rather than
    // discarding it.
    size_t nCopy = pendingBuffer_.size();
    if (nCopy > maxchars) {
        nCopy = maxchars;
    }
    memcpy(data, pendingBuffer_.data(), nCopy);
    *nbytesTransfered = nCopy;

    bool servedEverything = (nCopy == pendingBuffer_.size());
    pendingBuffer_.erase(0, nCopy);

    if (eomReason) {
        if (servedEverything && pendingEosFound_) {
            *eomReason = ASYN_EOM_EOS;
        } else if (!servedEverything) {
            // More data remains buffered; caller should call read()
            // again to retrieve it.
            *eomReason = ASYN_EOM_CNT;
        } else {
            *eomReason = ASYN_EOM_END;
        }
    }

    pasynTrace->printIO(pasynUser, ASYN_TRACEIO_DRIVER, data, nCopy,
                         "%s: read() served nCopy=%zu eomReason=%d "
                         "remainingPending=%zu",
                         DRIVER_NAME, nCopy, eomReason ? *eomReason : -1,
                         pendingBuffer_.size());

    epicsMutexUnlock(lock_);
    return asynSuccess;
}

asynStatus mightexHidPort::flush(asynUser *pasynUser) {
    // pendingBuffer_ is the one piece of state worth discarding here --
    // anything not yet served to a caller that no longer wants it.
    epicsMutexLock(lock_);
    pendingBuffer_.clear();
    pendingEosFound_ = false;
    epicsMutexUnlock(lock_);
    return asynSuccess;
}

asynStatus mightexHidPort::setInputEos(asynUser *pasynUser, const char *eos,
                                        int eoslen) {
    inputEos_.assign(eos, eoslen);
    return asynSuccess;
}

asynStatus mightexHidPort::getInputEos(asynUser *pasynUser, char *eos,
                                        int eossize, int *eoslen) {
    int n = static_cast<int>(inputEos_.size());
    if (n > eossize) {
        n = eossize;
    }
    memcpy(eos, inputEos_.data(), n);
    *eoslen = n;
    return asynSuccess;
}

asynStatus mightexHidPort::setOutputEos(asynUser *pasynUser, const char *eos,
                                         int eoslen) {
    outputEos_.assign(eos, eoslen);
    return asynSuccess;
}

asynStatus mightexHidPort::getOutputEos(asynUser *pasynUser, char *eos,
                                         int eossize, int *eoslen) {
    int n = static_cast<int>(outputEos_.size());
    if (n > eossize) {
        n = eossize;
    }
    memcpy(eos, outputEos_.data(), n);
    *eoslen = n;
    return asynSuccess;
}

extern "C" int mightexHidPortConfigure(const char *portName,
                                        const char *hidrawDevice, int priority,
                                        int noAutoConnect) {
    if (!portName || !hidrawDevice) {
        printf("%s: portName and hidrawDevice are required\n", DRIVER_NAME);
        return -1;
    }
    new mightexHidPort(portName, hidrawDevice, priority, noAutoConnect);
    return 0;
}

// --- iocsh registration ---

static const iocshArg configureArg0 = {"portName", iocshArgString};
static const iocshArg configureArg1 = {"hidrawDevice", iocshArgString};
static const iocshArg configureArg2 = {"priority", iocshArgInt};
static const iocshArg configureArg3 = {"noAutoConnect", iocshArgInt};
static const iocshArg *const configureArgs[] = {
    &configureArg0, &configureArg1, &configureArg2, &configureArg3};
static const iocshFuncDef configureFuncDef = {"mightexHidPortConfigure", 4,
                                               configureArgs};

static void configureCallFunc(const iocshArgBuf *args) {
    mightexHidPortConfigure(args[0].sval, args[1].sval, args[2].ival,
                             args[3].ival);
}

static void mightexHidPortRegister(void) {
    iocshRegister(&configureFuncDef, configureCallFunc);
}

extern "C" {
epicsExportRegistrar(mightexHidPortRegister);
}
