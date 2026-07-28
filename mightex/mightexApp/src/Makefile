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

PROD_IOC = mightex
# mightex.dbd will be created and installed
DBD += mightex.dbd

# mightex.dbd will be made up from these files:
mightex_DBD += base.dbd

# Include dbd files from all support applications:
mightex_DBD += asyn.dbd
mightex_DBD += calc.dbd
mightex_DBD += mightexHidPort.dbd
mightex_DBD += stream.dbd

# Add all the support libraries needed by this IOC
mightex_LIBS += asyn
mightex_LIBS += calc
mightex_LIBS += stream

# mightex driver
mightex_SRCS += mightexHidPort.cpp

# mightex_registerRecordDeviceDriver.cpp derives from mightex.dbd
mightex_SRCS += mightex_registerRecordDeviceDriver.cpp

# Build the main IOC entry point on workstation OSs.
mightex_SRCS_DEFAULT += mightexMain.cpp
mightex_SRCS_vxWorks += -nil-

# Add support from base/src/vxWorks if needed
#mightex_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Finally link to the EPICS Base libraries
mightex_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

