# Basler Ace 1920 Epics driver

Description of Area detector configuration and implementation for the Basler a2A1920-51gmBAS GigE camera with instructions for running the IOC and GUI.

## Implementation

The driver loads and configures the areaDetector plugins according to the flowchart:
```
┌─────┐        ┌──────┐        ┌────────────┐        ┌──────────┐
│ Raw ├────────► ROI  ├────────► Statistics ├────────► Overlay  │
└─┬───┘        └─┬────┘        └────────────┘        └─┬────────┘
  │              │                                     │
  │  ┌───────┐   │  ┌───────┐                          │  ┌────────┐
  ├──► TIFF  │   ├──► TIFF  │                          ├──► CA IMG │
  │  └───────┘   │  └───────┘                          │  └────────┘
  │              │                                     │ 
  │  ┌───────┐   │  ┌───────┐                          │  ┌─────────┐
  ├──► JPEG  │   ├──► JPEG  │                          └──► PVA IMG │
  │  └───────┘   │  └───────┘                             └─────────┘
  │              │  
  │  ┌────────┐  │  ┌────────┐
  ├──► CA IMG │  ├──► CA IMG │
  │  └────────┘  │  └────────┘
  │              │  
  │  ┌─────────┐ │  ┌─────────┐
  └──► PVA IMG │ └──► PVA IMG │
     └─────────┘    └─────────┘
```
## IOC configuration
The camera specific parameters need to be updated in the `camera-epics/iocBoot/iocCameraSample/st.cmd` file, where:
* `CAMERA_NAME` is the hostname or ip address of the camera,
* _Optional:_ `PREFIX` is the record prefix used by the loaded templates.
> If the value of the record prefix macro `PREFIX` is updated, the value of the GUI macro `DEVICE` in the file `camera-gui/Basler_Main.bob` also needs to be updated to match the record prefix.


The environment paths need to be updated in the `camera-epics/configure/RELEASE` file, where:
* `CAMERA_APP` is the project root directory,
* `EPICS_BASE` is the directory where the EPICS base is installed,
* `MODULES` is the directory containing EPICS support modules,
* `AD_MODULES` is the directory containing areaDetector support modules.

To enable the transfer of images (Raw, ROI and Overlay) via Channel Access(CA) lines 21, 55 and 105 need to be uncommented in the `camera-epics/cmd/post_init.cmd` file:

```
21 # dbpf("$(PREFIX)RawImgCA:EnableCallbacks", 1)
...
55 # dbpf("$(PREFIX)ROIImgCA:EnableCallbacks", 1)
...
105 # dbpf("$(PREFIX)OverlayImgCA:EnableCallbacks", 1)
```
## Running the GUI
In order to start the GUI open the file `camera-gui/Basler_Main.bob` with Display Runtime. 

## Running the IOC
In order to start the IOC:
1. Navigate to the IOC project root directory:
```
$ cd basler-ace-1920-camera/camera-epics/
```
2. Compile the sample IOC:
```
$ make
```
3. Run the sample IOC:
```
$ cd iocBoot/ioccameraSample/
$ ../../bin/<arch>/cameraSample st.cmd
```
