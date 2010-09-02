//
//  CameraController.h
//  LindsayAR
//
//  Created by Jishuo Yang on 10-06-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//
//	A controller library used for capturing and saving camera output for the
//	iPhone. Code modified from:
//  http://forum.unity3d.com/viewtopic.php?t=49378


#import <AVFoundation/AVFoundation.h>

@interface CameraController : NSObject 
{
	/**
	 * Any class that needs the camera frames should be assigned as CameraWrapper's
	 * delegate. 
	 * The delegate needs to implement the function:
	 *
	 * - (void) processFrameAt:(unsigned char *) baseAddress withWidth:(size_t) width andHeight:(size_t) height
	 *
	 * where "baseAddress" is a pointer to the byte data of the captured frame,
	 * "width" and "height" are dimensions of the frame.
	 * processFrame will be called whenever a new frame is captured from camera.
	 */
	id delegate;

@private
	/**
	 * The capture session is responsible for capturing frames from the camera
	 */
	AVCaptureSession* captureSession;
}
@property (readwrite, assign) id delegate;


/**
 * Constructor for the class to initialize video capture settings.
 */
- (id)initVideoCapture;

@end
