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

#==================================================
# build a support library

LIBRARY_IOC += camera

# xxxRecord.h will be created from xxxRecord.dbd
#DBDINC += xxxRecord
# install camera.dbd into <top>/dbd
DBD += camera.dbd

camera_LIBS += ADAravis
camera_LIBS += ADGenICam
camera_LIBS += ADBase
camera_LIBS += asyn
camera_SYS_LIBS += aravis-0.8
camera_LIBS += NDPlugin
camera_LIBS += qsrv
camera_LIBS += ntndArrayConverter
camera_LIBS += nt
camera_LIBS += pvDatabase
camera_LIBS += $(EPICS_BASE_PVA_CORE_LIBS)
camera_LIBS += pvAccess
camera_LIBS += pvData
camera_LIBS += autosave
camera_LIBS += busy
camera_LIBS += calc
camera_LIBS += devIocStats
camera_LIBS += sscan
camera_LIBS += seq pv

# specify all source files to be compiled and added to the library
#camera_SRCS += xxx

camera_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

