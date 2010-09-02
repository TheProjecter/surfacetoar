//
//  ARToolKitPlusWrapper.h
//  LindsayAR
//
//  Created by Jishuo Yang on 10-08-04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//	A wrapper class used to simplify ARToolkitPlus use on the iPhone.
//	Code modified from:
//  http://studierstube.icg.tu-graz.ac.at/handheld_ar.recent/artoolkitplus_tutorial.php
//	This class tracks a single (multi)marker and returns the projection
//	matrix and model view matrix at which the marker is located.

#import <Foundation/Foundation.h>


@interface ARToolKitPlusWrapper : NSObject {
	
	/**
	 * This char pointer points to the buffer that holds one frame from the
	 * camera stream.
	 * The marker location can be calculated by assigning this pointer to
	 * the base address of the camera frame, and calling "detectMarker".
	 * This should be done for each new frame.
	 */
	unsigned char* cameraBuffer;
}

@property (nonatomic,readwrite) unsigned char* cameraBuffer;

/**
 *
 * Constructor for initializing the ARTPK tracker variables.
 * 
 * @param	int width: width of camera frame
 *
 * @param	int height: height of camera frame
 *
 */
- (id)initARTKPwithWidth:(int) width andHeight:(int)height;


/**
 *
 * Initializes the multimarker tracker with path to the camera calibration file and
 * path to the multimarker configuration file to be tracked.
 * 
 * @param	NSString camera_path: path to camera calibration file
 *
 * @param	NSString marker_path: path to multimarker configuration file
 *
 */
- (void)initTrackerWithCameraFile:(NSString*)camera_path andMarkerFile:(NSString*)marker_path;


/**
 *
 * Returns the transformation matrix for the projection matrix.
 * This matrix is calculated from the camera calibration file,
 * so it remains the same for the duration of the program.
 * 
 * @param	float[] outMatrix: the function copies the projection
 *					matrix into the outMatrix, so this argument
 *					is actually a return value.
 *
 */
-(void)getProjectionMatrix:(float[])outMatrix;


/**
 *
 * Returns the transformation matrix for the model/view matrix.
 * This matrix is recalculated for each camera frame, it is the
 * location of the marker in the camera frame.
 * 
 * @param	float[] outMatrix: the function copies the model/view
 *					matrix into the outMatrix, so this argument
 *					is actually a return value.
 *
 */
-(bool)detectMarker:(float[])outMatrix;


@end
