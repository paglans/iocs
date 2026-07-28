#!../../bin/linux-x86_64/mightex

#- SPDX-FileCopyrightText: 2003 Argonne National Laboratory
#-
#- SPDX-License-Identifier: EPICS

#- You may have to change mightex to something else
#- everywhere it appears in this file

< envPaths

cd "${TOP}"

## Register all support components
dbLoadDatabase "dbd/mightex.dbd"
mightex_registerRecordDeviceDriver pdbbase

mightexHidPortConfigure("MIGHTEX1", "/dev/mightex-led", 0, 0)

epicsEnvSet("STREAM_PROTOCOL_PATH", "$(TOP)/mightexApp/Db")

dbLoadRecords("$(ASYN)/db/asynRecord.db","P=mightex:,R=asyn1,PORT=MIGHTEX1,ADDR=0,IMAX=100,OMAX=100")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch1:,PORT=MIGHTEX1,CHL=1,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch2:,PORT=MIGHTEX1,CHL=2,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch3:,PORT=MIGHTEX1,CHL=3,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch4:,PORT=MIGHTEX1,CHL=4,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch5:,PORT=MIGHTEX1,CHL=5,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch6:,PORT=MIGHTEX1,CHL=6,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch7:,PORT=MIGHTEX1,CHL=7,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch8:,PORT=MIGHTEX1,CHL=8,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch9:,PORT=MIGHTEX1,CHL=9,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch10:,PORT=MIGHTEX1,CHL=10,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch11:,PORT=MIGHTEX1,CHL=11,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch12:,PORT=MIGHTEX1,CHL=12,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch13:,PORT=MIGHTEX1,CHL=13,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch14:,PORT=MIGHTEX1,CHL=14,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch15:,PORT=MIGHTEX1,CHL=15,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexChannel.template","P=BL:LED:,R=Ch16:,PORT=MIGHTEX1,CHL=16,SCAN=Passive")
dbLoadRecords("$(TOP)/db/mightexDevice.template","P=BL:LED:,R=,PORT=MIGHTEX1")

## Load record instances
#dbLoadRecords("db/mightex.db","user=anders")

cd "${TOP}/iocBoot/${IOC}"
iocInit

## Start any sequence programs
#seq sncxxx,"user=anders"
