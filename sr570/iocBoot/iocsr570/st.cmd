#!../../bin/linux-x86_64/sr570

#- SPDX-FileCopyrightText: 2003 Argonne National Laboratory
#-
#- SPDX-License-Identifier: EPICS

#- You may have to change sr570 to something else
#- everywhere it appears in this file

< envPaths

cd "${TOP}"

## Register all support components
dbLoadDatabase "dbd/sr570.dbd"
sr570_registerRecordDeviceDriver pdbbase

## Load record instances
#dbLoadRecords("db/sr570.db","user=anders")

cd "${TOP}/iocBoot/${IOC}"
iocInit

## Start any sequence programs
#seq sncxxx,"user=anders"
