#
# Copyright (c) 2024 Cosylab d.d.
#

# Description:
# This .cmd file configures all loaded plugins. 
# ioc shell commands are used, therefore it should be invoked after iocInit().


# Configure camera
dbpf("$(PREFIX)Cam:ArrayCallbacks", 1)
dbpf("$(PREFIX)Cam:TriggerSource", "Line1")
dbpf("$(PREFIX)Cam:ImageMode", "Continuous")
dbpf("$(PREFIX)Cam:AcquireTime.EGU", "ms")
dbpf("$(PREFIX)Cam:AcquireTime_RBV.EGU", "ms")

# PVA Raw Image activation
dbpf("$(PREFIX)RawImg:EnableCallbacks", 1)

# CA Raw Image activation
dbpf("$(PREFIX)RawImgCA:EnableCallbacks", 1)

# Raw Tiff plugin configuration
dbpf("$(PREFIX)RawTiff:EnableCallbacks", 1)
dbpf("$(PREFIX)RawTiff:ArrayCallbacks", 1)
dbpf("$(PREFIX)RawTiff:AutoIncrement", 1)
dbpf("$(PREFIX)RawTiff:FileTemplate", "%s%s_%3.3d.tiff")
dbpf("$(PREFIX)RawTiff:FileWriteMode", "Capture")
dbpf("$(PREFIX)RawTiff:AutoSave", 1)
dbpf("$(PREFIX)RawTiff:FilePath", "/tmp")
dbpf("$(PREFIX)RawTiff:FileName", "raw_image")

# Raw JPEG plugin configuration
dbpf("$(PREFIX)RawJPEG:EnableCallbacks", 1)
dbpf("$(PREFIX)RawJPEG:ArrayCallbacks", 1)
dbpf("$(PREFIX)RawJPEG:AutoIncrement", 1)
dbpf("$(PREFIX)RawJPEG:FileTemplate", "%s%s_%3.3d.JPEG")
dbpf("$(PREFIX)RawJPEG:FileWriteMode", "Capture")
dbpf("$(PREFIX)RawJPEG:AutoSave", 1)
dbpf("$(PREFIX)RawJPEG:FilePath", "/tmp")
dbpf("$(PREFIX)RawJPEG:FileName", "raw_image")

# Roi && Transform configuration
dbpf("$(PREFIX)ROI:EnableCallbacks", 1)
dbpf("$(PREFIX)ROI:ArrayCallbacks", 1)
dbpf("$(PREFIX)ROI:MinX", 0)
dbpf("$(PREFIX)ROI:MinY", 0)
dbpf("$(PREFIX)ROI:SizeX", 1000)
dbpf("$(PREFIX)ROI:SizeY", 1000)

# PVA ROI Image activation
dbpf("$(PREFIX)ROIImg:EnableCallbacks", 1)

# CA ROI Image activation
dbpf("$(PREFIX)ROIImgCA:EnableCallbacks", 1)

# Roi Tiff plugin configuration
dbpf("$(PREFIX)ROITiff:EnableCallbacks", 1)
dbpf("$(PREFIX)ROITiff:ArrayCallbacks", 1)
dbpf("$(PREFIX)ROITiff:AutoIncrement", 1)
dbpf("$(PREFIX)ROITiff:FileTemplate", "%s%s_%3.3d.tiff")
dbpf("$(PREFIX)ROITiff:FileWriteMode", "Capture")
dbpf("$(PREFIX)ROITiff:AutoSave", 1)
dbpf("$(PREFIX)ROITiff:FilePath", "/tmp")
dbpf("$(PREFIX)ROITiff:FileName", "roi_image")

# Roi JPEG plugin configuration
dbpf("$(PREFIX)ROIJPEG:EnableCallbacks", 1)
dbpf("$(PREFIX)ROIJPEG:ArrayCallbacks", 1)
dbpf("$(PREFIX)ROIJPEG:AutoIncrement", 1)
dbpf("$(PREFIX)ROIJPEG:FileTemplate", "%s%s_%3.3d.JPEG")
dbpf("$(PREFIX)ROIJPEG:FileWriteMode", "Capture")
dbpf("$(PREFIX)ROIJPEG:AutoSave", 1)
dbpf("$(PREFIX)ROIJPEG:FilePath", "/tmp")
dbpf("$(PREFIX)ROIJPEG:FileName", "roi_image")

# Stats configuration (enable histogram)
dbpf("$(PREFIX)Stats:EnableCallbacks", 1)
dbpf("$(PREFIX)Stats:ArrayCallbacks", 1)
dbpf("$(PREFIX)Stats:ComputeHistogram", 1)
dbpf("$(PREFIX)Stats:ComputeCentroid", 1)
dbpf("$(PREFIX)Stats:ComputeProfiles", 1)
dbpf("$(PREFIX)Stats:TS:TSAcquire", 1)
dbpf("$(PREFIX)Stats:CentroidThreshold", 100)

# Overlay configuration
dbpf("$(PREFIX)Overlay:EnableCallbacks", 1)
# Overlay1 => Crosshair (Centroid)
dbpf("$(PREFIX)Overlay:1:Use", 0)
dbpf("$(PREFIX)Overlay:1:Green", 40)
dbpf("$(PREFIX)Overlay:1:WidthX", 10)
dbpf("$(PREFIX)Overlay:1:WidthY", 10)
dbpf("$(PREFIX)Overlay:1:SizeX", 200)
dbpf("$(PREFIX)Overlay:1:SizeY", 200)
# Overlay2 => Ellipse (SigmaX/Y)
#dbpf("$(PREFIX)Overlay:2:Use", 0)
#dbpf("$(PREFIX)Overlay:2:WidthX", 10)
#dbpf("$(PREFIX)Overlay:2:WidthY", 10)
#dbpf("$(PREFIX)Overlay:2:Green", 200)

# PVA Overlay Image activation
dbpf("$(PREFIX)OverlayImg:EnableCallbacks", 1)

# CA Overlay Image activation
dbpf("$(PREFIX)OverlayImgCA:EnableCallbacks", 1)

