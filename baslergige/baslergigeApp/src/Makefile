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

PROD_IOC = baslergige
# baslergige.dbd will be created and installed
DBD += baslergige.dbd

# baslergige.dbd will be made up from these files:
baslergige_DBD += base.dbd

# Include dbd files from all support applications:
#baslergige_DBD += xxx.dbd
baslergige_DBD += camera.dbd
baslergige_DBD += ADAravisSupport.dbd
baslergige_DBD += ADSupport.dbd
baslergige_DBD += asyn.dbd
baslergige_DBD += NDPluginSupport.dbd
baslergige_DBD += NDFileNull.dbd
baslergige_DBD += qsrv.dbd
baslergige_DBD += NDPluginPva.dbd
baslergige_DBD += PVAServerRegister.dbd
baslergige_DBD += NDFileTIFF.dbd
baslergige_DBD += NDFileHDF5.dbd
baslergige_DBD += NDFileJPEG.dbd
baslergige_DBD += asSupport.dbd
baslergige_DBD += busySupport.dbd
baslergige_DBD += calcSupport.dbd
baslergige_DBD += calc.dbd
baslergige_DBD += devIocStats.dbd
baslergige_DBD += sscanSupport.dbd

# Add all the support libraries needed by this IOC
#baslergige_LIBS += xxx
baslergige_LIBS += ADAravis
baslergige_LIBS += ADGenICam
baslergige_LIBS += ADBase
baslergige_LIBS += asyn
baslergige_SYS_LIBS += aravis-0.10
baslergige_LIBS += NDPlugin
baslergige_LIBS += qsrv
baslergige_LIBS += ntndArrayConverter
baslergige_LIBS += nt
baslergige_LIBS += pvDatabase
baslergige_LIBS += $(EPICS_BASE_PVA_CORE_LIBS)
baslergige_LIBS += pvAccess
baslergige_LIBS += pvData
baslergige_LIBS += autosave
baslergige_LIBS += busy
baslergige_LIBS += calc
baslergige_LIBS += devIocStats
baslergige_LIBS += sscan
baslergige_LIBS += seq pv

# baslergige_registerRecordDeviceDriver.cpp derives from baslergige.dbd
baslergige_SRCS += baslergige_registerRecordDeviceDriver.cpp

# Build the main IOC entry point on workstation OSs.
baslergige_SRCS_DEFAULT += baslergigeMain.cpp
baslergige_SRCS_vxWorks += -nil-

# Add support from base/src/vxWorks if needed
#baslergige_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Finally link to the EPICS Base libraries
baslergige_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

