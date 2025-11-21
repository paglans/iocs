#!../../bin/linux-x86_64/cameraSample
#
# Copyright (c) 2023 Cosylab d.d.
# Developed IP
# This software is distributed under the terms found
# in file LICENSE.txt that is included with this distribution.
#

< envPaths

epicsEnvSet("CAMERA_APP",	"/opt/epics/iocs/basler-acA1920-40gc-camera-master-main/camera-epics")

cd "${TOP}"

## Register all support components
dbLoadDatabase "dbd/cameraSample.dbd"
cameraSample_registerRecordDeviceDriver pdbbase

## PREFIX = Record prefix, each camera should have an unique PREFIX
## CAMERA_NAME = IP address or hostname of the camera 
iocshLoad("$(CAMERA_APP)/cmd/main.cmd", "PREFIX=BaslerAce1920:, CAMERA_NAME=192.168.11.6")


cd "${TOP}/iocBoot/${IOC}"
iocInit

iocshLoad("$(CAMERA_APP)/cmd/post_init.cmd", "PREFIX=BaslerAce1920:")
