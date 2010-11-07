//
//  MockTracker.h
//  LindsayAR
//
//  Created by Jishuo Yang on 10-08-29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifndef __MOCK_ARTOOLKITPLUS_TRACKERMULTIMARKERIMPL_HEADERFILE__
#define __MOCK_ARTOOLKITPLUS_TRACKERMULTIMARKERIMPL_HEADERFILE__

#include "TrackerMultiMarker.h"
using ARToolKitPlus::TrackerMultiMarker;


class MockTracker: public TrackerMultiMarker 
{
public:
	MockTracker(int imWidth, int imHeight, int maxImagePatterns, int pattWidth, int pattHeight,
				int pattSamples, int maxLoadPatterns);
	bool init(const char* nCamParamFile, const char* nMultiFile, ARFloat nNearClip, ARFloat nFarClip);
	int calc(const unsigned char* nImage);
	const ARFloat* getModelViewMatrix() const;
	const ARFloat* getProjectionMatrix() const;
	
	int count_init;
	ARFloat projection_matrix[16];
	ARFloat modelview_matrix[16];
};

#endif //__ARTOOLKITPLUS_TRACKERMULTIMARKERIMPL_HEADERFILE__
