#!/bin/bash
# Test launcher — mimics what manage-iocs does when it sources the config file.
# Run from iocBoot/iocbaslergige/:
#   $ ./test_sampleoverview.sh

export CAM_IP=192.168.11.11
export CAM_PREFIX=BL:SampleOv:
export CAM_PORT=SAMPLEOV
export CAM_MAXSIZE_X=2592
export CAM_MAXSIZE_Y=1944
export CAM_BUFFERS=50
export CAM_NELEMENTS=15116544
export CAM_AUTOSAVE_PATH=/opt/epics/autosave/sampleoverview

exec ../../bin/linux-x86_64/baslergige st.cmd
