/* mightexHidPort.h
 *
 * Low-level asyn port driver exposing a Mightex Sirius SLC-series LED
 * controller's HID interface as a standard asynOctet port, so that
 * StreamDevice (or any asynOctetSyncIO client) can talk to it exactly as
 * it would to a serial or IP port -- same ASCII command set as the
 * RS232 variant, just framed as chunked HID Feature reports underneath.
 *
 * Framing (derived from a USB capture of the vendor Windows tool):
 *   Each 18-byte HID Feature report (report ID 0) is:
 *     [0]      : 0x01 marker byte (constant "data valid" flag)
 *     [1]      : length of valid ASCII payload in this chunk (0-16)
 *     [2:2+len]: ASCII payload bytes for this chunk
 *     [rest]   : padding, ignored on read / zero-filled on write
 *   Commands/responses longer than 16 bytes span multiple chunks.
 */

#ifndef mightexHidPort_H
#define mightexHidPort_H

#ifdef __cplusplus
extern "C" {
#endif

/** Create and register a Mightex HID asyn port.
 *
 * @param portName        Name to register the asyn port under, referenced
 *                         by the StreamDevice protocol's port link (e.g.
 *                         in the db "@asyn(MIGHTEX1,0)").
 * @param hidrawDevice     Path to the device node, e.g. "/dev/hidraw3"
 *                         (use a stable udev by-id symlink in production,
 *                         not a raw enumeration-order node).
 * @param priority          epicsThread scheduling priority, 0 for default.
 * @param noAutoConnect     If non-zero, don't connect automatically at
 *                         iocInit; a caller must connect explicitly.
 * @return 0 on success, -1 on failure.
 */
int mightexHidPortConfigure(const char *portName, const char *hidrawDevice,
                             int priority, int noAutoConnect);

#ifdef __cplusplus
}
#endif

#endif
