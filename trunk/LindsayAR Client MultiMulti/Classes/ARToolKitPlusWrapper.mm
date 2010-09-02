//
//  ARToolKitPlusWrapper.m
//  LindsayAR
//
//  Created by Jishuo Yang on 10-08-04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ARToolKitPlusWrapper.h"
#import "TrackerMultiMultiMarker.h"
#import "ARToolKitPlus.h"
using ARToolKitPlus::TrackerMultiMultiMarker;

#include <cstdio>
#include <iostream>
#include <fstream>

using namespace std;

@implementation ARToolKitPlusWrapper
@synthesize cameraBuffer;


/**
 * This global variable is declared because having a C++ instance
 * variable in a header file means that every header file that imports 
 * this class must also have its ".m" file renamed to an Obj-C++ 
 * ".mm" file. In the interest of avoiding a snowballing of changes 
 * whenever this class is used, this variable is declared as global.
 *
 * The tracker variable is responsible for tracking the markers
 * and returning their locations.
 */
TrackerMultiMultiMarker* tracker;


- (id)initARTKPwithWidth:(int) width andHeight:(int)height
{
	if (width < 0 || height < 0)
	{
		NSLog(@"ERROR: invalid resolution\n");
		return nil;
	}
	
	// create a tracker that does:
	//  - 6x6 sized marker images (required for binary markers)
	//  - samples at a maximum of 6x6
	//  - can load a maximum of 0 non-binary pattern
	//  - can detect a maximum of 8 patterns in one image
	tracker = new TrackerMultiMultiMarker(width, height, 8, 6, 6, 6, 0);
	
	return self;
}
	
- (void)initTrackerWithCameraFile:(NSString*)camera_path
{
	//  - works with BGRA images (iPhone camera outputs BGRA)
	tracker->setPixelFormat(ARToolKitPlus::PIXEL_FORMAT_BGRA);
	
	char camera_cstr[512] = {0};
	[camera_path getCString:camera_cstr maxLength:512 encoding:NSASCIIStringEncoding];
	
	// load a camera file and marker configuration file
	if (!tracker->init(camera_cstr, 1.0f, 1000.0f)) 
	{
		NSLog(@"ERROR: init() failed\n");
		return;
	}
	
	tracker->setHullMode(ARToolKitPlus::HULL_OFF);
	
	// the marker in the BCH test image has a thiner border...
	tracker->setBorderWidth(0.125f);
	
	// set a threshold. we could also activate automatic thresholding
	tracker->setThreshold(160);
	
	// let's use lookup-table undistortion for high-speed
	// note: LUT only works with images up to 1024x1024
	tracker->setUndistortionMode(ARToolKitPlus::UNDIST_LUT);
	
	// switch to simple ID based markers
	// use the tool in tools/IdPatGen to generate markers
	tracker->setMarkerMode(ARToolKitPlus::MARKER_ID_SIMPLE);
}


-(bool)addMarkerFromFile:(NSString*)marker_path
{
	char marker_cstr[512] = {0};
	[marker_path getCString:marker_cstr maxLength:512 encoding:NSASCIIStringEncoding];
	
	return tracker->addMarker(marker_cstr);
}


-(void)getProjectionMatrix:(float[])outMatrix 
{
	const ARFloat* inMatrix = tracker->getProjectionMatrix();
	
	for (int i = 0; i < 16; i++)
	{
		NSLog(@"%f", inMatrix[i]);
		outMatrix[i] = inMatrix[i];
	}
}


- (bool)detectMarker:(float[])outMatrix atIndex:(int)index
{
	if (tracker->calc(cameraBuffer, index) > 0)
	{
		const ARFloat* inMatrix = tracker->getModelViewMatrix();
		
		for (int i = 0; i < 16; i++)
		{
			outMatrix[i] = inMatrix[i];
		}
		return true;
	}
	else
	{
		return false;
	}
}


/**
 * These two functions serve to get and set the normally unaccessible 
 * tracker instance variable. There is really no need to call these functions
 * in any application. However, they are necessary for unit tests so we
 * are able to use a MockTracker instead of the actual TrackerMultiMarker.
 */
- (TrackerMultiMultiMarker*)getTracker
{
	return tracker;
}
- (void)setTracker:(TrackerMultiMultiMarker*)newTracker
{
	delete tracker;
	tracker = newTracker;
}


- (void) dealloc
{
	delete tracker; 

	[super dealloc];
}

@end
