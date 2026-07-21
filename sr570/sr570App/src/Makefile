# SPDX-FileCopyrightText: 2003 Argonne National Laboratory
#
# SPDX-License-Identifier: EPICS

TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#=============================
# Build the IOC application

PROD_IOC = sr570
# sr570.dbd will be created and installed
DBD += sr570.dbd

# sr570.dbd will be made up from these files:
sr570_DBD += base.dbd

# Include dbd files from all support applications:
# asyn: provides drvAsynSerialPortConfigure and the asyn record layer
sr570_DBD += asyn.dbd
sr570_DBD += drvAsynSerialPort.dbd
sr570_LIBS += asyn

# ip module: provides SR570.db's device support (devXxStrParm, registered
# as "asyn ... stringParm") via ip.dbd -> ipSupport.dbd
sr570_DBD += ip.dbd
sr570_LIBS += ip

# calc module: provides the "calc" and "transform" record types used by SR570.db
sr570_DBD  += calcSupport.dbd
sr570_LIBS += calc

# seq/pv are pulled in transitively by the ip library (Keithley/Federal/
# Oxford sequence programs bundled in that module) -- harmless to link
# even though SR570 itself doesn't use sequencer code.
ifdef SNCSEQ
sr570_LIBS += seq pv
endif

# Add all the support libraries needed by this IOC
sr570_DBD  += asSupport.dbd
sr570_LIBS += autosave

# sr570_registerRecordDeviceDriver.cpp derives from sr570.dbd
sr570_SRCS += sr570_registerRecordDeviceDriver.cpp

# Build the main IOC entry point on workstation OSs.
sr570_SRCS_DEFAULT += sr570Main.cpp
sr570_SRCS_vxWorks += -nil-

# Add support from base/src/vxWorks if needed
#sr570_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Finally link to the EPICS Base libraries
sr570_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

