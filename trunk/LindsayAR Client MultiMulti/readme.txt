Notes for those executing the application:

1. 	There is no networking with this application. The markers being tracked
	are those in "markertexture.png". You should either print this out or
	display it on a monitor.
	
2. 	ARTPK seems to be really sensitive to lighting issues. I recommend keeping
	the markers under uniform lighting.
	
	
Notes for developers:
1. 	It is recommended that you are familiar with basic OpenGL concepts
	prior to using the SurfaceToAR API.
	
2.	While modifying code for multimarker use, I have somehow broken the lighting.
	Due to time constraints I had no time to fix this issue, but a more 
	experienced OpenGL developer should not have such issues. 
	
3. 	Should networking be enabled to communicate and allow for dynamic marker
	allocation between the table server and the iPhone client, see developer
	note point 3 under LindsayARClientFinal for suggestions.
	
4. 	The difference between single multimarker tracking code and multi-multimarker
	tracking code is that the TrackerMultiMultiMarker class has a vector of marker
	info objects, whereas TrackerMultiMarker only has one.
	Hence, for more complex projects, I recommend having a container class called
	MarkerInfo that stores at least sceneOffset for each marker. Where the sceneOffset 
	is the transformation matrix to get the origin of the OpenGL scene.
	(Note that compared to multi-multimarker info classes on the server, this 
	implementation doesn't need markerLocation because the AR already gives that to you.)
	
5. 	Note that this class is untested. I don't anticipate any problems because it
	was a very small change, but the change did break a number of tests. There was
	no time to implement a complete test for both TrackerMultiMultiMarker and
	the new ARToolkitPlusWrapper.
	
	Similarly, documentation for these two classes aren't perfect either.
	There was really a lot of hacking done on this. While the classes are fine,
	the main loop code is more messy than I would like. But differences should be very
	easy to figure out when comparing between ES1Renderer classes in this project
	and the single-multimarker project.