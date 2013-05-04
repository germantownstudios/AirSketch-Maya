AirSketch:Maya
©2013 Geoffrey Beatty
geoff@germantownstudios.com

>Summary

AirSketch:Maya is an application for creating 3D strokes within Autodesk Maya.  The user moves an iPhone (or iPod) equipped with both an accelerometer and a gyroscope through space, and a corresponding line appears in Maya.  This interaction allows for a more natural, gesture-based approach for creating lines.  When used in conjunction with Maya’s Paint Effects, it becomes a visual painting tool.


>Requirements

AirSketch:Maya  is targeted towards desktop users of Maya.  It requires the use of an iPhone 4 (or greater) or a 4th generation iPod Touch (or greater), as these contain sensors with the necessary precision to accomplish the accurate recording of gesture.  Network communication will be limited to those machines on the same wireless network as the phone running AirSketch.

AirSketch:Maya is a native iOS (6.1) app written in Objective-C. It uses two externally-developed libraries to handle the input prompt as well as the “picker” for the brushes. There is also a small, ancillary Python script that runs within Maya in order to open a “commandport” interface to communicate with AirSketch:Maya. Because it is a script and not a plugin (which would have to be compiled and specific to each operating system and platform), and because it works with common nodes and features in Maya, it should function properly with any version of Maya from 2010 to the present.

Note: You will only be able to build to your iOS device if you have an iOS developer account.


>Download

Downlaod the latest build of AirSketch:Maya at <https://github.com/germantownstudios/AirSketch-Maya>.


>Installation

These are the components of the download:
-AirSketchMaya.xcodeproj (Xcode project file)
-AirSketchMaya (Xcode directory containing all necessary files for build)
-MayaFiles/icon/AirSketch.png (shelf icon file)
-MayaFiles/scripts/AirSketch.py (main Python file)
-MayaFiles/shelf/shelf_AirSketch.mel (shelf MEL script)
-README (this help file)

Copy the contained AirSketchMaya directory and AirSketchMaya.xcodeproj to a location of your choice.

Copy the AirSketch.py script to 
/Users/<USERNAME>/Library/Preferences/Autodesk/maya/scripts (MacOS)
\Users\<USERNAME>\Documents\maya\scripts (Windows)

Copy the AirSketch.png file to
/Users/<USERNAME>/Library/Preferences/Autodesk/maya/<VERSION>/prefs/icons (MacOS)
\Users\<USERNAME>\Documents\maya\<VERSION>\prefs\icons (Windows)

Copy the shelf_AirSketch.mel file to
/Users/<USERNAME>/Library/Preferences/Autodesk/maya/<VERSION>/prefs/shelves (MacOS)
\Users\<USERNAME>\Documents\maya\<VERSION>\prefs\shelves (Windows)

If Maya is open when you install these items, you will have to quit and restart Maya in order to see the AirSketch shelf appear.


>Usage

Clicking on the shelf button opens a prompt displaying the desktop device’s local ip address as well as the opportunity to specify a port number. You can make a change to the port number if the supplied port is already in use. These two components are crucial for the app to make a connection with Maya over the wireless network.

After initiating the “commandport,” open the AirSketch:Maya app on your iPhone and configure it with the correct information. If the app can’t make a connection over the wireless network with Maya, it offers troubleshooting advice.

Once the devices are connected (as indicated by a message on screen as well as a change in the iPhone interface), you can then begin to make curves. 

Pressing “new” will create a cursor object which is driven around the space by the motion of the device.

Holding down “record” sets the Maya timeline to play and simultaneously records the motion of the cursor object. When “record” is released, the recording ceases and the program creates a curve based on the recorded motion.

After generating the curve, you may use the other controls on the remote to perform additional functions on the curve, such as simplifying it, moving it, changing the attached brush, and rendering an image.

You can also delete the existing curve and start over or you can undo the last performed editing actions.

At each point in the process, a sliding, translucent cover indicates which interactions are available at each moment.


>Known problems (in no particular order)

Extrapolating position from accelerometer data is notoriously difficult and AirSketch:Maya suffers from the inability to sufficiently filter out the little pops and drift that make the motion capture less than faithful. Much more work needs to be done in this area.

The undo function doesn't work as intended. There are ways to wrap certain blocks as a single undo chunk, but this isn't implemented yet.

Changing the brush can inadvertently delete a brush from another curve. That's because Maya builds the list of existing brushes alphabetically rather than in order of creation. The call to delete the last created brush needs to be fixed in order to take this into account.

There are probably tons of things that could be done to make things run faster and more efficiently, maybe add functionality that doesn't exist yet. I'm just learning all of this, so any constructive feedback is welcome.


>Credits

Many thanks to the following official and unofficial members of my thesis committee:

Marc Downie (Open Ended Group)
EJ Herczyk (Associate Professor, Philadelphia University)
Jeremy Suggs (EICR Institute)
Sherman Finch (Director, BS/MS Interactive Design and Media, Philadelphia University)
Phil Sorrentino (Creative Director, Aquent Design Studios)

