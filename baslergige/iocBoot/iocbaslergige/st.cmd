#!/opt/epics/iocs/baslergige/bin/linux-x86_64/baslergige

< envPaths

cd "${TOP}"

## Register all support components
dbLoadDatabase("dbd/baslergige.dbd")
baslergige_registerRecordDeviceDriver(pdbbase)

## ============================================================
## Camera identity — sourced from manage-iocs config file
## ============================================================
epicsEnvSet("CAM_IP",           "$(CAM_IP=192.168.11.11)")
epicsEnvSet("CAM_PREFIX",       "$(CAM_PREFIX=TEST:Cam1:)")
epicsEnvSet("CAM_PORT",         "$(CAM_PORT=CAM1)")
epicsEnvSet("CAM_MAXSIZE_X",    "$(CAM_MAXSIZE_X=2448)")
epicsEnvSet("CAM_MAXSIZE_Y",    "$(CAM_MAXSIZE_Y=2048)")
epicsEnvSet("CAM_BUFFERS",      "$(CAM_BUFFERS=50)")
epicsEnvSet("CAM_NELEMENTS",    "$(CAM_NELEMENTS=5013504)")
epicsEnvSet("CAM_AUTOSAVE_PATH","$(CAM_AUTOSAVE_PATH=/opt/epics/autosave/default)")

## Namespaced plugin port names — unique per IOC on this host
epicsEnvSet("PORT_PVA",  "PVA1_$(CAM_PORT)")
epicsEnvSet("PORT_TIFF", "TIFF1_$(CAM_PORT)")
epicsEnvSet("PORT_JPEG", "JPEG1_$(CAM_PORT)")
epicsEnvSet("PORT_IMG",  "IMAGE1_$(CAM_PORT)")

## ============================================================
## Database search paths — must be set before any dbLoadRecords
## ============================================================
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db:$(ADARAVIS)/db:$(ADGENICAM)/db:$(AUTOSAVE)/db:$(TOP)/db")

## ============================================================
## Autosave — must be configured before iocInit
## ============================================================
set_savefile_path("$(CAM_AUTOSAVE_PATH)")

set_requestfile_path("$(TOP)/autosave")
set_requestfile_path("$(ADCORE)/db")
set_requestfile_path("$(ADARAVIS)/db")

save_restoreSet_Debug(0)
save_restoreSet_NumSeqFiles(1)
save_restoreSet_SeqPeriodInSeconds(5)
save_restoreSet_DatedBackupFiles(1)

set_pass0_restoreFile("basler_settings.sav")
set_pass1_restoreFile("basler_settings.sav")

## ============================================================
## Aravis GigE camera driver
## ============================================================
aravisConfig("$(CAM_PORT)", "$(CAM_IP)", $(CAM_BUFFERS), 0, 0)

## ============================================================
## Camera records
## ============================================================
dbLoadRecords("$(ADCORE)/db/ADBase.template", "P=$(CAM_PREFIX),R=cam1:,PORT=$(CAM_PORT),ADDR=0,TIMEOUT=1")
dbLoadRecords("$(ADARAVIS)/db/aravisCamera.template", "P=$(CAM_PREFIX),R=cam1:,PORT=$(CAM_PORT),ADDR=0,TIMEOUT=1")

## ============================================================
## PVAccess plugin
## ============================================================
NDPvaConfigure("$(PORT_PVA)", 2, 0, "$(CAM_PORT)", 0, "$(CAM_PREFIX)Pva1:Image", 0, 0, 0)
dbLoadRecords("$(ADCORE)/db/NDPva.template", "P=$(CAM_PREFIX),R=Pva1:,PORT=$(PORT_PVA),ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(CAM_PORT)")

## ============================================================
## TIFF file writer
## ============================================================
NDFileTIFFConfigure("$(PORT_TIFF)", 32, 0, "$(CAM_PORT)", 0)
dbLoadRecords("$(ADCORE)/db/NDFileTIFF.template", "P=$(CAM_PREFIX),R=TIFF1:,PORT=$(PORT_TIFF),ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(CAM_PORT),NDARRAY_ADDR=0")

## ============================================================
## JPEG file writer
## ============================================================
NDFileJPEGConfigure("$(PORT_JPEG)", 32, 0, "$(CAM_PORT)", 0)
dbLoadRecords("$(ADCORE)/db/NDFileJPEG.template", "P=$(CAM_PREFIX),R=JPEG1:,PORT=$(PORT_JPEG),ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(CAM_PORT),NDARRAY_ADDR=0")

## ============================================================
## NDStdArrays — legacy CA image waveform
## ============================================================
NDStdArraysConfigure("$(PORT_IMG)", 3, 0, "$(CAM_PORT)", 0)
dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(CAM_PREFIX),R=image1:,PORT=$(PORT_IMG),ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(CAM_PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=$(CAM_NELEMENTS)")

## ============================================================
## Autosave status record
## ============================================================
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(CAM_PREFIX)")

## ============================================================
cd "${TOP}/iocBoot/iocbaslergige"
iocInit
## ============================================================

## Start PVA server
startPVAServer

## Post-init: start periodic saves
create_monitor_set("basler_settings.req", 30, "P=$(CAM_PREFIX),R=cam1:")

## Uncomment when ffmpeg plugin is built:
# NDFFmpegConfigure("FFMPEG1_$(CAM_PORT)", 2, 0, "$(CAM_PORT)", 0)
# dbLoadRecords("db/NDFFmpeg.template",
#     "P=$(CAM_PREFIX),R=FFMpeg1:,PORT=FFMPEG1_$(CAM_PORT),ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(CAM_PORT)")
