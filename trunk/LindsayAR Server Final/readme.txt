Notes for developers:
1. 	It is recommended that you are familiar with basic OpenGL concepts
	prior to using the SurfaceToAR API.
	
2.	Currently the server renders the marker as a texture taken from an image file.
	This is not optimal, since you will need to make new images for each multimarker.
	In addition, this makes it impossible for us to dynamically create multimarkers.
	
	Ideally, the server should read in a marker configuration file and create its own
	texture file from the images in "id-markers" folder under the ARToolkitPlus library.
	I suggest using OpenGL texture subimages.
	
3. 	Further development ideas:
	a} Dynamic addition of one multimarker (low difficulty, did not implement due to time constraints)
		1} Read in a marker from a configuration file.
		2) Generate an ARMultiMarkerInfoT using ARTKP's Tracker class.
		3) Send the ARMultiMarkerInfoT over to each client and allocate the marker.
		4) Link the new marker to a scene.
		
	b) Dynamic multimarker generation (medium difficulty)
		1) Open up the marker generation GUI window
		2) Be able to pull from available markers into a central canvas.
		3) Application dynamically generates marker configuration file based on 
			size and location of markers.
		
	b) Dynamic single-marker creation (high difficulty, difficult prior to SmartTable Mac drivers)
		1) Allow finger-painting in GUI window for a single marker.
		2) Add this marker into single-marker pool.