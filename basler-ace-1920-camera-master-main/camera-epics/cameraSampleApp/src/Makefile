#
# Copyright (c) 2023 Cosylab d.d.
# Developed IP
# This software is distributed under the terms found
# in file LICENSE.txt that is included with this distribution.
#

TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#=============================
# Build the IOC application

PROD_IOC = cameraSample
# cameraSample.dbd will be created and installed
DBD += cameraSample.dbd

# cameraSample.dbd will be made up from these files:
cameraSample_DBD += base.dbd

# Include dbd files from all support applications:
cameraSample_DBD += camera.dbd
cameraSample_DBD += ADAravisSupport.dbd
cameraSample_DBD += ADSupport.dbd
cameraSample_DBD += asyn.dbd
cameraSample_DBD += NDPluginSupport.dbd
cameraSample_DBD += NDFileNull.dbd
cameraSample_DBD += qsrv.dbd
cameraSample_DBD += NDPluginPva.dbd
cameraSample_DBD += PVAServerRegister.dbd
cameraSample_DBD += NDFileTIFF.dbd
cameraSample_DBD += NDFileHDF5.dbd
cameraSample_DBD += NDFileJPEG.dbd
cameraSample_DBD += asSupport.dbd
cameraSample_DBD += busySupport.dbd
cameraSample_DBD += calcSupport.dbd
cameraSample_DBD += calc.dbd
cameraSample_DBD += devIocStats.dbd
cameraSample_DBD += sscanSupport.dbd

# Add all the support libraries needed by this IOC
cameraSample_LIBS += ADAravis
cameraSample_LIBS += ADGenICam
cameraSample_LIBS += ADBase
cameraSample_LIBS += asyn
cameraSample_SYS_LIBS += aravis-0.8
cameraSample_LIBS += NDPlugin
cameraSample_LIBS += qsrv
cameraSample_LIBS += ntndArrayConverter
cameraSample_LIBS += nt
cameraSample_LIBS += pvDatabase
cameraSample_LIBS += $(EPICS_BASE_PVA_CORE_LIBS)
cameraSample_LIBS += pvAccess
cameraSample_LIBS += pvData
cameraSample_LIBS += autosave
cameraSample_LIBS += busy
cameraSample_LIBS += calc
cameraSample_LIBS += devIocStats
cameraSample_LIBS += sscan
cameraSample_LIBS += seq pv

# cameraSample_registerRecordDeviceDriver.cpp derives from cameraSample.dbd
cameraSample_SRCS += cameraSample_registerRecordDeviceDriver.cpp

# Build the main IOC entry point on workstation OSs.
cameraSample_SRCS_DEFAULT += cameraSampleMain.cpp
cameraSample_SRCS_vxWorks += -nil-

# Add support from base/src/vxWorks if needed
#cameraSample_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Finally link to the EPICS Base libraries
cameraSample_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

