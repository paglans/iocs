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

PROD_IOC = doMore
# doMore.dbd will be created and installed
DBD += doMore.dbd
DBD += modbusSupport.dbd

INC += drvModbusAsyn.h
INC += modbusInterpose.h
INC += modbus.h

LIBRARY_IOC = modbus

USR_CFLAGS += -DUSE_TYPED_RSET
USR_CPPFLAGS += -DUSE_TYPED_RSET

LIB_SRCS += drvModbusAsyn.cpp
LIB_SRCS += modbusInterpose.c
LIB_SRCS += testModbusSyncIO.cpp
LIB_LIBS += asyn
LIB_LIBS += $(EPICS_BASE_IOC_LIBS)

# doMore.dbd will be made up from these files:
doMore_DBD += base.dbd

# Include dbd files from all support applications:
doMore_DBD += asyn.dbd
doMore_DBD += drvAsynIPPort.dbd
doMore_DBD += drvAsynSerialPort.dbd
doMore_DBD += modbusSupport.dbd

# Add all the support libraries needed by this IOC
#doMore_LIBS += xxx

# doMore_registerRecordDeviceDriver.cpp derives from doMore.dbd
doMore_SRCS += doMore_registerRecordDeviceDriver.cpp
# doMore_SRCS += modbusMain.cpp

# Build the main IOC entry point on workstation OSs.
doMore_SRCS_DEFAULT += doMoreMain.cpp
doMore_SRCS_vxWorks += -nil-

PROD_IOC += testClient
testClient_SRCS += testClient.cpp

PROD_LIBS += modbus
PROD_LIBS += asyn
PROD_LIBS += $(EPICS_BASE_IOC_LIBS)

# Add support from base/src/vxWorks if needed
#doMore_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Finally link to the EPICS Base libraries
doMore_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

