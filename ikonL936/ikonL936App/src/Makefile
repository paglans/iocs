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

PROD_IOC = ikonL936
PROD_NAME = $(PROD_IOC)

LIBRARY_IOC_Linux += andorCCD
LIB_SRCS += andorCCD.cpp
ifeq ($(WITH_SHAMROCK), YES)
  LIB_SRCS += shamrock.cpp
  USR_CPPFLAGS += -DUSE_SHAMROCK
  LIB_LIBS_WIN32 += ShamrockCIFm
  DBD += shamrockSupport.dbd
endif


# ikonL936.dbd will be created and installed
DBD += ikonL936.dbd

# LIBRARY_IOC_Linux += andorCCD
# LIB_SRCS += andorCCD.cpp

# ikonL936.dbd will be made up from these files:
ikonL936_DBD += base.dbd

# Include dbd files from all support applications:
ikonL936_DBD += ADSupport.dbd
ikonL936_DBD += asyn.dbd
ikonL936_DBD += NDPluginSupport.dbd
ikonL936_DBD += NDFileNull.dbd
ikonL936_DBD += qsrv.dbd
ikonL936_DBD += NDPluginPva.dbd
ikonL936_DBD += PVAServerRegister.dbd
ikonL936_DBD += NDFileTIFF.dbd
ikonL936_DBD += NDFileHDF5.dbd
ikonL936_DBD += NDFileJPEG.dbd
ikonL936_DBD += NDFileNetCDF.dbd
ikonL936_DBD += NDFileNexus.dbd
ikonL936_DBD += NDFileMagick.dbd
ikonL936_DBD += asSupport.dbd
ikonL936_DBD += busySupport.dbd
ikonL936_DBD += calcSupport.dbd
ikonL936_DBD += calc.dbd
ikonL936_DBD += devIocStats.dbd
ikonL936_DBD += sscanSupport.dbd

# Add all the support libraries needed by this IOC
ikonL936_LIBS += andorCCD

ikonL936_LIBS += ADBase
ikonL936_LIBS += asyn
ikonL936_LIBS += NDPlugin
ikonL936_LIBS += qsrv
ikonL936_LIBS += ntndArrayConverter
ikonL936_LIBS += nt
ikonL936_LIBS += pvDatabase
ikonL936_LIBS += $(EPICS_BASE_PVA_CORE_LIBS)
ikonL936_LIBS += pvAccess
ikonL936_LIBS += pvData
ikonL936_LIBS += autosave
ikonL936_LIBS += busy
ikonL936_LIBS += calc
ikonL936_LIBS += devIocStats
ikonL936_LIBS += sscan
ikonL936_LIBS += seq pv

INC += andorCCD.h
ikonL936_LIBS += andorCCD
ikonL936_SRCS += andorCCD.cpp

include $(ADCORE)/ADApp/commonDriverMakefile

DATA += GREY.PAL

ikonL936_DBD += andorCCDSupport.dbd

# ikonL936_registerRecordDeviceDriver.cpp derives from ikonL936.dbd
ikonL936_SRCS += ikonL936_registerRecordDeviceDriver.cpp

# Build the main IOC entry point on workstation OSs.
ikonL936_SRCS_DEFAULT += ikonL936Main.cpp
ikonL936_SRCS_vxWorks += -nil-

# Add support from base/src/vxWorks if needed
#ikonL936_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Finally link to the EPICS Base libraries
ikonL936_LIBS += $(EPICS_BASE_IOC_LIBS)

include $(ADCORE)/ADApp/commonLibraryMakefile

PROD_IOC_Linux += linuxTest
PROD_IOC_Linux += FKTest
PROD_IOC_Linux += accumTest
PROD_SYS_LIBS += andor

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

