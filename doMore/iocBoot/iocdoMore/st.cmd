#!../../bin/linux-x86_64/doMore

< envPaths

cd "${TOP}"

## Register all support components
dbLoadDatabase "dbd/doMore.dbd"
doMore_registerRecordDeviceDriver pdbbase

#---------------------------------------------------------
# Do-more CPU - single Modbus TCP connection
# IP: 192.168.10.162, port 502
#---------------------------------------------------------
drvAsynIPPortConfigure("Koyo1", "192.168.10.162:502", 0, 0, 0)
asynSetOption("Koyo1", 0, "disconnectOnReadTimeout", "Y")
modbusInterposeConfig("Koyo1", 0, 5000, 0)

# Do-more Modbus memory spaces (all start at offset 0, 1-based in Do-more):
#   MI  -> FC2  discrete inputs  (read-only)
#   MC  -> FC1/FC5 coils         (read/write)
#   MIR -> FC4  input registers  (read-only,  125-word chunks)
#   MHR -> FC3/FC16 holding regs (read/write, 125-word read / 120-word write chunks)

# --- MI discrete inputs (FC2, read-only) ---
# MI257-MI736 used (offsets 256-735), cover 736 bits total
drvModbusAsynConfigure("K1_MI",      "Koyo1", 0,  2, 0, 736, 0, 100, "DoMore")

# --- MC coils (FC1 read / FC5 write) ---
# MC1-MC281 and X0-X95 used; max offset = 280, cover 281 bits
drvModbusAsynConfigure("K1_MC_In",   "Koyo1", 0,  1, 0, 281, 0, 100, "DoMore")
drvModbusAsynConfigure("K1_MC_Out",  "Koyo1", 0,  5, 0, 281, 0,   0, "DoMore")

# --- MIR input registers (FC4, read-only) ---
# WX0-WX23 (offsets 0-23) and MIR1-MIR249 (offsets 0-248); max offset = 248
drvModbusAsynConfigure("K1_MIR_0",   "Koyo1", 0,  4,   0, 125, 0, 100, "DoMore")  # offsets 0-124
drvModbusAsynConfigure("K1_MIR_1",   "Koyo1", 0,  4, 125, 125, 0, 100, "DoMore")  # offsets 125-249

# --- MHR holding registers (FC3 read / FC16 write) ---
# MHR1-MHR390 used (offsets 0-389)
# Read chunks (125 words, FC3):
drvModbusAsynConfigure("K1_MHR_In_0",  "Koyo1", 0,  3,   0, 125, 0, 100, "DoMore")  # offsets 0-124
drvModbusAsynConfigure("K1_MHR_In_1",  "Koyo1", 0,  3, 125, 125, 0, 100, "DoMore")  # offsets 125-249
drvModbusAsynConfigure("K1_MHR_In_2",  "Koyo1", 0,  3, 250, 125, 0, 100, "DoMore")  # offsets 250-374
drvModbusAsynConfigure("K1_MHR_In_3",  "Koyo1", 0,  3, 375, 120, 0, 100, "DoMore")  # offsets 375-389
# Write chunks (120 words, FC16):
drvModbusAsynConfigure("K1_MHR_Out_0", "Koyo1", 0, 16,   0, 120, 0,   0, "DoMore")  # offsets 0-119
drvModbusAsynConfigure("K1_MHR_Out_1", "Koyo1", 0, 16, 120, 120, 0,   0, "DoMore")  # offsets 120-239
drvModbusAsynConfigure("K1_MHR_Out_2", "Koyo1", 0, 16, 240, 120, 0,   0, "DoMore")  # offsets 240-359
drvModbusAsynConfigure("K1_MHR_Out_3", "Koyo1", 0, 16, 360, 120, 0,   0, "DoMore")  # offsets 360-389

#---------------------------------------------------------
## Load record instances
#---------------------------------------------------------
dbLoadRecords("db/doMore.db")

cd "${TOP}/iocBoot/${IOC}"
iocInit
