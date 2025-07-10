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

PROD_IOC = simDetector
PROD_NAME = $(PROD_IOC)
# simDetector.dbd will be created and installed
DBD += simDetector.dbd
# DBD += simDetectorSupport.dbd

# simDetector.dbd will be made up from these files:
simDetector_DBD += base.dbd

# Include dbd files from all support applications:
simDetector_DBD += ADSupport.dbd
simDetector_DBD += asyn.dbd
simDetector_DBD += NDPluginSupport.dbd
simDetector_DBD += NDFileNull.dbd
simDetector_DBD += qsrv.dbd
simDetector_DBD += NDPluginPva.dbd
simDetector_DBD += PVAServerRegister.dbd
simDetector_DBD += NDFileTIFF.dbd
simDetector_DBD += NDFileHDF5.dbd
simDetector_DBD += NDFileJPEG.dbd
simDetector_DBD += NDFileNetCDF.dbd
simDetector_DBD += NDFileNexus.dbd
simDetector_DBD += NDFileMagick.dbd
simDetector_DBD += asSupport.dbd
simDetector_DBD += busySupport.dbd
simDetector_DBD += calcSupport.dbd
simDetector_DBD += calc.dbd
simDetector_DBD += devIocStats.dbd
simDetector_DBD += sscanSupport.dbd

# Add all the support libraries needed by this IOC
simDetector_LIBS += ADBase
simDetector_LIBS += asyn
simDetector_LIBS += NDPlugin
simDetector_LIBS += qsrv
simDetector_LIBS += ntndArrayConverter
simDetector_LIBS += nt
simDetector_LIBS += pvDatabase
simDetector_LIBS += $(EPICS_BASE_PVA_CORE_LIBS)
simDetector_LIBS += pvAccess
simDetector_LIBS += pvData
simDetector_LIBS += autosave
simDetector_LIBS += busy
simDetector_LIBS += calc
simDetector_LIBS += devIocStats
simDetector_LIBS += sscan
simDetector_LIBS += seq pv

INC += simDetector.h
simDetector_LIBS += simDetector
simDetector_SRCS += simDetector.cpp

simDetector_DBD += simDetectorSupport.dbd
# simDetector_DBD += simDetector.dbd

#include $(ADCORE)/ADApp/commonLibraryMakefile
include $(ADCORE)/ADApp/commonDriverMakefile

# simDetector_registerRecordDeviceDriver.cpp derives from simDetector.dbd
simDetector_SRCS += simDetector_registerRecordDeviceDriver.cpp

# Build the main IOC entry point on workstation OSs.
simDetector_SRCS_DEFAULT += simDetectorMain.cpp
simDetector_SRCS_vxWorks += -nil-

# Add support from base/src/vxWorks if needed
#simDetector_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Finally link to the EPICS Base libraries
simDetector_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

