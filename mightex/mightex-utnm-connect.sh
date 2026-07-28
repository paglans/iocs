#!/bin/bash
# mightex-utnm-connect.sh
#
# Connects the Mightex Sirius SLC-CA16-U via the SEH utnserver Pro (utnm),
# and verifies the resulting device node is actually present and
# accessible before returning success. Intended to run as a systemd
# oneshot unit ordered before softioc-mightex.service, so the IOC never
# starts racing against an as-yet-unconnected USB-over-network device.
#
# Exit code 0: device confirmed ready.
# Exit code 1: gave up after MAX_RETRIES; device not ready. Check
#   `utnm -c "getlist <ip>"` -- if Owner shows another host, this is an
#   exclusivity conflict, not something this script can resolve alone.

set -uo pipefail

UTNSERVER_IP="192.168.10.52"
UTNSERVER_PORT="1"
DEVICE_SYMLINK="/dev/mightex-led"
MAX_RETRIES=10
RETRY_DELAY_SEC=3

log() {
    echo "[mightex-utnm-connect] $*"
}

for attempt in $(seq 1 "$MAX_RETRIES"); do
    log "Attempt ${attempt}/${MAX_RETRIES}: connecting to utnserver ${UTNSERVER_IP} port ${UTNSERVER_PORT}"

    # utnm activate is expected to succeed harmlessly if this host
    # already holds the connection (e.g. a service restart, not a fresh
    # boot) -- that specific case returns exit code 23 "Is already
    # activated" per `utnm --help`, which is a non-zero but genuinely
    # benign result, not a real failure. If a DIFFERENT host currently
    # owns the port, this fails with error 25 "another user has
    # activated the USB port" -- that's the documented exclusivity
    # behavior (see the operations manual), and this script deliberately
    # does not try to force it; it just retries in case the conflict is
    # transient (e.g. the other host is in the middle of its own
    # deactivate).
    utnm -c "activate ${UTNSERVER_IP} ${UTNSERVER_PORT}"
    utnm_exit=$?
    case "${utnm_exit}" in
        0)
            log "activate succeeded"
            ;;
        23)
            log "already activated (benign -- proceeding to verify device node)"
            ;;
        *)
            log "activate returned exit code ${utnm_exit} (see utnm --help for meaning); will retry"
            ;;
    esac

    # Give udev a moment to process the resulting device event before
    # checking -- the symlink may not appear instantaneously even after
    # a successful connect.
    sleep 1

    if [ -e "${DEVICE_SYMLINK}" ] && [ -r "${DEVICE_SYMLINK}" ] && [ -w "${DEVICE_SYMLINK}" ]; then
        log "${DEVICE_SYMLINK} present and accessible. Success."
        exit 0
    fi

    log "${DEVICE_SYMLINK} not yet ready; waiting ${RETRY_DELAY_SEC}s before retry"
    sleep "${RETRY_DELAY_SEC}"
done

log "ERROR: ${DEVICE_SYMLINK} never became available after ${MAX_RETRIES} attempts"
log "Check current port ownership: utnm -c \"getlist ${UTNSERVER_IP}\""
log "If Owner shows a different host, this is an exclusivity conflict requiring manual resolution, not a transient failure this script can retry past."
exit 1
