#!../../bin/linux-x86_64/sr570
< envPaths

epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(TOP)/db")

dbLoadDatabase("../../dbd/sr570.dbd")
sr570_registerRecordDeviceDriver(pdbbase)

#------------------------------------------------------------------
# Serial ports: Moxa CN2650-16 in Real COM mode.
# npreal2 maps each configured channel to a local tty device.
# CONFIRM the ttyr## <-> "COM1x" mapping against /etc/npreal2d.cf
# before trusting this list -- edit the device paths below to match.
#------------------------------------------------------------------

drvAsynSerialPortConfigure("SR570_1", "/dev/ttyr00", 0, 0, 0)
asynSetOption           ("SR570_1", 0, "baud",   "9600")
asynSetOption           ("SR570_1", 0, "bits",   "8")
asynSetOption           ("SR570_1", 0, "parity", "none")
asynSetOption           ("SR570_1", 0, "stop",   "2")
asynOctetSetInputEos    ("SR570_1", 0, "\r\n")
asynOctetSetOutputEos   ("SR570_1", 0, "\r\n")

drvAsynSerialPortConfigure("SR570_2", "/dev/ttyr01", 0, 0, 0)
asynSetOption           ("SR570_2", 0, "baud",   "9600")
asynSetOption           ("SR570_2", 0, "bits",   "8")
asynSetOption           ("SR570_2", 0, "parity", "none")
asynSetOption           ("SR570_2", 0, "stop",   "2")
asynOctetSetInputEos    ("SR570_2", 0, "\r\n")
asynOctetSetOutputEos   ("SR570_2", 0, "\r\n")

drvAsynSerialPortConfigure("SR570_3", "/dev/ttyr02", 0, 0, 0)
asynSetOption           ("SR570_3", 0, "baud",   "9600")
asynSetOption           ("SR570_3", 0, "bits",   "8")
asynSetOption           ("SR570_3", 0, "parity", "none")
asynSetOption           ("SR570_3", 0, "stop",   "2")
asynOctetSetInputEos    ("SR570_3", 0, "\r\n")
asynOctetSetOutputEos   ("SR570_3", 0, "\r\n")

drvAsynSerialPortConfigure("SR570_4", "/dev/ttyr03", 0, 0, 0)
asynSetOption           ("SR570_4", 0, "baud",   "9600")
asynSetOption           ("SR570_4", 0, "bits",   "8")
asynSetOption           ("SR570_4", 0, "parity", "none")
asynSetOption           ("SR570_4", 0, "stop",   "2")
asynOctetSetInputEos    ("SR570_4", 0, "\r\n")
asynOctetSetOutputEos   ("SR570_4", 0, "\r\n")

drvAsynSerialPortConfigure("SR570_5", "/dev/ttyr04", 0, 0, 0)
asynSetOption           ("SR570_5", 0, "baud",   "9600")
asynSetOption           ("SR570_5", 0, "bits",   "8")
asynSetOption           ("SR570_5", 0, "parity", "none")
asynSetOption           ("SR570_5", 0, "stop",   "2")
asynOctetSetInputEos    ("SR570_5", 0, "\r\n")
asynOctetSetOutputEos   ("SR570_5", 0, "\r\n")

drvAsynSerialPortConfigure("SR570_6", "/dev/ttyr05", 0, 0, 0)
asynSetOption           ("SR570_6", 0, "baud",   "9600")
asynSetOption           ("SR570_6", 0, "bits",   "8")
asynSetOption           ("SR570_6", 0, "parity", "none")
asynSetOption           ("SR570_6", 0, "stop",   "2")
asynOctetSetInputEos    ("SR570_6", 0, "\r\n")
asynOctetSetOutputEos   ("SR570_6", 0, "\r\n")

drvAsynSerialPortConfigure("SR570_7", "/dev/ttyr06", 0, 0, 0)
asynSetOption           ("SR570_7", 0, "baud",   "9600")
asynSetOption           ("SR570_7", 0, "bits",   "8")
asynSetOption           ("SR570_7", 0, "parity", "none")
asynSetOption           ("SR570_7", 0, "stop",   "2")
asynOctetSetInputEos    ("SR570_7", 0, "\r\n")
asynOctetSetOutputEos   ("SR570_7", 0, "\r\n")

drvAsynSerialPortConfigure("SR570_8", "/dev/ttyr07", 0, 0, 0)
asynSetOption           ("SR570_8", 0, "baud",   "9600")
asynSetOption           ("SR570_8", 0, "bits",   "8")
asynSetOption           ("SR570_8", 0, "parity", "none")
asynSetOption           ("SR570_8", 0, "stop",   "2")
asynOctetSetInputEos    ("SR570_8", 0, "\r\n")
asynOctetSetOutputEos   ("SR570_8", 0, "\r\n")

#------------------------------------------------------------------
# Records: one row of SR570.db per amplifier, from the substitutions file
#------------------------------------------------------------------

dbLoadTemplate("sr570.substitutions")

cd ${TOP}/iocBoot/iocsr570

#------------------------------------------------------------------
# Autosave: the SR570 is listen-only (no query/readback), so autosave
# is the *only* record of instrument state across a restart.
#
# IMPORTANT: autosave keys each save set purely off the *request
# filename* (see create_data_set()/create_monitor_set() in
# save_restore.c) -- it does NOT distinguish sets by macro string. Using
# the same "SR570preamp_settings.req" for all 8 amps would collide: the
# 2nd through 8th create_monitor_set() calls would be rejected outright
# and all 8 would try to share one save file. To avoid that, Db/ has 8
# physical copies of the request file (SR570_1_settings.req ...
# SR570_8_settings.req, identical content, distinct names) so each amp
# gets its own independent save set and .sav file.
#------------------------------------------------------------------

save_restoreSet_status_prefix("SR:")
set_savefile_path("/opt/epics/autosave/sr570")
set_requestfile_path("../../sr570App/Db")
save_restoreSet_NumSeqFiles(3)
save_restoreSet_IncompleteSetsOk(1)
save_restoreSet_DatedBackupFiles(1)

# Restore each amp's last-known settings before iocInit. Using pass1 only
# here: pass0 exists for records whose restored value must be in place
# before *other* records' init() routines run (e.g. motor RESOLUTION/
# OFFSET); nothing in SR570.db has that kind of init-order dependency, so
# a single pass1 restore should be sufficient. Worth confirming on first
# bring-up that all 8 amps come back with their prior sensitivity/offset/
# filter settings before relying on this in production.
set_pass1_restoreFile("SR570_1_settings.sav", "P=BL:SR570_1:,A=")
set_pass1_restoreFile("SR570_2_settings.sav", "P=BL:SR570_2:,A=")
set_pass1_restoreFile("SR570_3_settings.sav", "P=BL:SR570_3:,A=")
set_pass1_restoreFile("SR570_4_settings.sav", "P=BL:SR570_4:,A=")
set_pass1_restoreFile("SR570_5_settings.sav", "P=BL:SR570_5:,A=")
set_pass1_restoreFile("SR570_6_settings.sav", "P=BL:SR570_6:,A=")
set_pass1_restoreFile("SR570_7_settings.sav", "P=BL:SR570_7:,A=")
set_pass1_restoreFile("SR570_8_settings.sav", "P=BL:SR570_8:,A=")

iocInit

# Restore-then-repush: autosave sets the record VAL fields above, but that
# alone does not talk to the hardware. Each instance's "init" seq record
# is what actually walks the restored values back out over serial -- a
# fresh SR570, or one that lost power, has no memory of what the last IOC
# session had it set to until this runs.
dbpf("BL:SR570_1:init.PROC", "1")
dbpf("BL:SR570_2:init.PROC", "1")
dbpf("BL:SR570_3:init.PROC", "1")
dbpf("BL:SR570_4:init.PROC", "1")
dbpf("BL:SR570_5:init.PROC", "1")
dbpf("BL:SR570_6:init.PROC", "1")
dbpf("BL:SR570_7:init.PROC", "1")
dbpf("BL:SR570_8:init.PROC", "1")

# Ongoing periodic saves, one independent set per amp (see note above on
# why each needs its own request-file name).
create_monitor_set("SR570_1_settings.req", 5, "P=BL:SR570_1:,A=")
create_monitor_set("SR570_2_settings.req", 5, "P=BL:SR570_2:,A=")
create_monitor_set("SR570_3_settings.req", 5, "P=BL:SR570_3:,A=")
create_monitor_set("SR570_4_settings.req", 5, "P=BL:SR570_4:,A=")
create_monitor_set("SR570_5_settings.req", 5, "P=BL:SR570_5:,A=")
create_monitor_set("SR570_6_settings.req", 5, "P=BL:SR570_6:,A=")
create_monitor_set("SR570_7_settings.req", 5, "P=BL:SR570_7:,A=")
create_monitor_set("SR570_8_settings.req", 5, "P=BL:SR570_8:,A=")
