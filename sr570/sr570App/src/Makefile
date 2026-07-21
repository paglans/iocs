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
#sr570_DBD += xxx.dbd

# Add all the support libraries needed by this IOC
#sr570_LIBS += xxx

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

