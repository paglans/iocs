# SPDX-FileCopyrightText: 2003 Argonne National Laboratory
#
# SPDX-License-Identifier: EPICS

TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================
# Build the IOC support library

USR_CXXFLAGS_Linux += -Wno-write-strings

ifdef ULDAQ_INCLUDE
  USR_INCLUDES_Linux += -I$(ULDAQ_INCLUDE)
endif

ifdef ULDAQ_DIR
  uldaq_DIR = $(ULDAQ_DIR)
endif

DBD += measComp.dbd
DBD += measCompSupport.dbd

LIBRARY_IOC_WIN32 += measComp
ifeq ($(HAVE_ULDAQ), YES)
  LIBRARY_IOC_Linux += measComp
endif

# Compile and add the code to the support library
# Link locally-provided code into the support library,
# rather than directly into the IOC application.

measComp_SRCS += drvMultiFunction.cpp
measComp_SRCS += drvUSBCTR.cpp
measComp_SRCS += measCompDiscover.cpp
measComp_SRCS += USBCTR_SNL.st

measComp_LIBS += asyn
measComp_LIBS += seq pv
measComp_LIBS += $(EPICS_BASE_IOC_LIBS)

#=============================
# Build the IOC application

PROD_IOC = measComp

# measComp.dbd will be created and installed
DBD += measComp.dbd

# measComp.dbd will be made up from these files:
measComp_DBD += base.dbd

# Include dbd files from all support applications:
#measComp_DBD += xxx.dbd

# Add all the support libraries needed by this IOC
measComp_LIBS += measComp
measComp_LIBS += scaler
measComp_LIBS += busy
measComp_LIBS += calc
measComp_LIBS += mca
measComp_LIBS += sscan
measComp_LIBS += autosave
# measComp_LIBS += asyn
# measComp_LIBS += seq pv
ifeq (win32-x86, $(findstring win32-x86, $(T_A)))
  measComp_LIBS += cbw32
  measCompApp_LIBS += cbw32
else ifeq (windows-x64, $(findstring windows-x64, $(T_A)))
  measComp_LIBS += cbw64
  measCompApp_LIBS += cbw64
endif
ifdef ULDAQ_DIR
  measComp_LIBS_Linux += uldaq
else
  measComp_SYS_LIBS_Linux += uldaq
endif
measComp_SYS_LIBS_Linux += usb-1.0


# measComp_registerRecordDeviceDriver.cpp derives from measComp.dbd
measComp_SRCS += measComp_registerRecordDeviceDriver.cpp

# Build the main IOC entry point on workstation OSs.
#measComp_SRCS_DEFAULT += measCompMain.cpp
measComp_SRCS += measCompMain.cpp
measComp_SRCS_vxWorks += -nil-

# Add support from base/src/vxWorks if needed
#measComp_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Finally link to the EPICS Base libraries
measComp_LIBS += $(EPICS_BASE_IOC_LIBS)

# This program lists all Measurement Computing devices on USB or local Ethernet subnet
PROD_IOC_WIN32 += test_measCompDiscover
ifeq ($(HAVE_ULDAQ), YES)
  PROD_IOC_Linux += test_measCompDiscover
endif
test_measCompDiscover_SRCS += test_measCompDiscover.cpp
test_measCompDiscover_LIBS += measComp
ifeq (win32-x86, $(findstring win32-x86, $(T_A)))
  test_measCompDiscover_LIBS += cbw32
  test_measCompDiscover_LIBS += cbw32
else ifeq (windows-x64, $(findstring windows-x64, $(T_A)))
  test_measCompDiscover_LIBS += cbw64
endif
ifdef ULDAQ_DIR
  test_measCompDiscover_LIBS_Linux += uldaq
else
  test_measCompDiscover_SYS_LIBS_Linux += uldaq
endif
test_measCompDiscover_SYS_LIBS_Linux += usb-1.0
test_measCompDiscover_LIBS += $(EPICS_BASE_IOC_LIBS)

PROD_IOC_Linux += testDualEthDevice
ifdef ULDAQ_DIR
  testDualEthDevice_LIBS_Linux += uldaq
else
  testDualEthDevice_SYS_LIBS_Linux += uldaq
endif
testDualEthDevice_SYS_LIBS_Linux += usb-1.0 pthread

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

