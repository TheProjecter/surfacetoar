Notes for those executing the application:

1. 	The server IP address this application connects to is HARD CODED.
	You should recompile the application whenever the server IP changes.
	For your convenience, the server IP is the last IPv4 IP displayed in
	the Server control panel.
	
	Likewise, the port number is also fixed. Currently the port for both
	the client and server is hard coded at 5000. But this isn't nearly as
	severe as a locked IP.

	Ideally there would be an IP connection screen allowing the user to 
	connect to a server, with boxes for IP and port. However, my lack of
	iPhone GUI programming experience made it difficult to sub views and
	handle the iPhone keyboard. I hope that this feature would be implemented
	by a more experienced developer.
	
	
Notes for developers:
1. 	It is recommended that you are familiar with basic OpenGL concepts
	prior to using the SurfaceToAR API.
	
2.	The file "markerboard_480-499.cfg" is the marker configuration file.
	It contains data on how ARTKP treats markers and the scale that the
	modelview matrix is returned in.
	
	
	EXAMPLE:	
	# number of markers
	1				// number of markers for the multimarker, can be 1 to simulate single-marker
	
	# marker 0
	480				// the id of the marker or the file path to an image of a custom marker
	1.0				// width of the square marker
	0.0 0.0			// pattern width/coordinate origin
	
	// opengl matrix on location of marker offset from origin
	 1.0000  0.0000 0.0000   -2.5		// x axis	
	 0.0000  1.0000 0.0000    1.875		// y axis
	 0.0000  0.0000 1.0000    0.0		// z axis
	 
	
	For pictures of all the id markers that come included with ARToolkitPlus, look 
	into the "id-markers" folder under ARToolkitPlus library folder.
	
	See this page for more details: http://www.hitl.washington.edu/artoolkit/documentation/tutorialmulti.htm
	
	For transformation overlay to work correctly, the size of the multi-marker
	needs to be identical with the size of the texture drawn on the server.
	In this case, the server had 5x4 markers with 6 width 0.25 strips vertically,
	and 5 width 0.25 strips horizontally. This means that the texture will 
	have to be 5*1.0 + 6*0.25 = 6.5 units horizontally, and 4*1.0 + 5*0.25 = 5.25
	vertically.
	
3. 	Should dynamic multi-multimarker additions be included, you need
	to implement the methods addMarker and linkMarker to scene in the
	network code.
	
	Unfortunately, I ran out of time, and was unable to implement these
	more advanced (and useful) features.
	
	addMarker would allow the server to dynamically add new markers by 
	(ideally) sending over an ARMultiMarkerInfoT object, or (less ideally)
	sending over a marker configuration file. This marker is then parsed
	and added to the list of markers.
	
	linkMarker would allow the server to link any marker to a certain OpenGL
	scene. This gives us the ability to swap scenes between markers, dynamically
	allocate a new scene for a new marker, among other things.
	
	Combined, addMarker and linkMarker gives us the ability to dynamically
	generate new (multi)markers from server-side, and to have them quickly
	linked to a pre-existing scene on the iPhone. This might be useful for
	passing AR-rendered cards around the table, placing down new AR-rendered
	tokens for a board game, etc.
	
4. 	Finally, I would like to reiterate that since not all models are the same,
	you will need to eyeball the scaling issue between the iPhone and the table.
	As far as I know there is no way to calculate this unless you know the exact
	height/width of both models.
	In this case, the server model was more than 100 times bigger than the skeleton
	natively, and its size was shrunk until it appeared to match with the skeleton.
	Similarly, not all models have an identical "center" defined. In this case,
	the skeleton was rendered with its origin equal to the origin of the marker,
	so the origin is somewhere at the skeleton's pelvis height.
	However, the origin for the human model is somewhere at its solar plexus. So
	the human model was moved up a bit until its pelvis is also at the marker's
	origin.