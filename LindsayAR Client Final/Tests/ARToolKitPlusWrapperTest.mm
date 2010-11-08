//
//  ARToolKitPlusWrapperTest.m
//  LindsayAR
//
//  Created by Jishuo Yang on 10-08-26.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ARToolKitPlusWrapperTest.h"

@implementation ARToolKitPlusWrapperTest

- (void) testPass {
	
	//STAssertTrue(TRUE, @"");
	//STFail(@"Should fail\n");
}


/**
 * Tests to see if the initalize function takes illegal resolutions.
 */
- (void) test_initARTKPwithWidth_invalidParameter
{
	MockARToolKitPlusWrapper* wrapper = [[MockARToolKitPlusWrapper alloc] initARTKPwithWidth:-5 andHeight:-5];
	STAssertNil(wrapper, @"should not be initialized");
	
	[wrapper release];
}


/**
 * Tests to see if the class is initialized with legal resolutions.
 */
- (void) test_initARTKPwithWidth_validParameter
{
	MockARToolKitPlusWrapper* wrapper = [[MockARToolKitPlusWrapper alloc] initARTKPwithWidth:5 andHeight:5];
	STAssertNotNil(wrapper, @"should be initialized");
	
	[wrapper release];
}


/**
 * Tests to see if the tracker initialization takes null values.
 */
- (void) test_initTracker_nullParameter
{
	MockARToolKitPlusWrapper* wrapper = [[MockARToolKitPlusWrapper alloc] initARTKPwithWidth:10 andHeight:10];
	
	[wrapper initTrackerWithCameraFile:NULL andMarkerFile:NULL];
	MockTracker* tempTracker = (MockTracker*)[wrapper getTracker];
	
	STAssertEquals(0, tempTracker->count_init, @"Tracker should not be initialized on invalid addresses");
	
	[wrapper release];
}


/**
 * Tests to see if the tracker initializes on valid file addresses.
 */
- (void) test_initTracker_validParameter
{
	MockARToolKitPlusWrapper* wrapper = [[MockARToolKitPlusWrapper alloc] initARTKPwithWidth:10 andHeight:10];
	
	NSBundle* bundle = [NSBundle bundleWithIdentifier:@"com.yourcompany.LindsayClientTest"];
	NSString* camera_path = [bundle pathForResource:@"no_distortion" ofType:@"cal"];
	NSString* marker_path = [bundle pathForResource:@"markerboard_480-499" ofType:@"cfg"];
	
	[wrapper initTrackerWithCameraFile:camera_path andMarkerFile:marker_path];
	MockTracker* tempTracker = (MockTracker*)[wrapper getTracker];
	
	STAssertEquals(1, tempTracker->count_init, @"Tracker should be initialized on a valid address");
	
	[wrapper release];
}


/**
 * Tests to see if correct projection matrices are returned.
 */
- (void) test_getProjectionMatrix_correctness
{
	MockARToolKitPlusWrapper* wrapper = [[MockARToolKitPlusWrapper alloc] initARTKPwithWidth:10 andHeight:10];
	
	float testMatrix[16];
	
	[wrapper getProjectionMatrix:testMatrix];
	
	for (int i = 0; i < 16; i++)
	{
		STAssertEquals((float)i, testMatrix[i], @"Returned projection matrix should be identical to MockTracker's projection matrix.");
	}
	
	[wrapper release];
}


/**
 * Tests to see if correct model view matrices are returned.
 */
- (void) test_detectMarker_correctness
{
	MockARToolKitPlusWrapper* wrapper = [[MockARToolKitPlusWrapper alloc] initARTKPwithWidth:10 andHeight:10];
	
	float testMatrix[16];
	
	[wrapper detectMarker:testMatrix];
	
	for (int i = 0; i < 16; i++)
	{
		STAssertEquals((float)i*2, testMatrix[i], @"Returned model/view matrix should be identical to MockTracker's model/view matrix.");
	}
	
	[wrapper release];
}


@end
