//
//  MockTracker.cpp
//  LindsayAR
//
//  Created by Jishuo Yang on 10-08-29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#include "MockTracker.h"

MockTracker::MockTracker(int imWidth, int imHeight, int maxImagePatterns, int pattWidth, int pattHeight,
									   int pattSamples, int maxLoadPatterns) :
TrackerMultiMarker(imWidth, imHeight, maxImagePatterns, pattWidth, pattHeight, pattSamples, maxLoadPatterns) 
{
	for (int i = 0; i < 16; i++)
	{
		modelview_matrix[i] = (float)i*2;
	}
	
	for (int i = 0; i < 16; i++)
	{
		projection_matrix[i] = (float)i;
	}
}

bool MockTracker::init(const char* nCamParamFile, const char* nMultiFile, ARFloat nNearClip, ARFloat nFarClip) 
{
	if (strlen(nCamParamFile) == 0 || strlen(nMultiFile) == 0)
	{
		count_init = 0;
		return false;
	}
	else
	{
		count_init = 1;
		return true;
	}	
}

int MockTracker::calc(const unsigned char* nImage) 
{
	return 5;
}

const ARFloat* MockTracker::getModelViewMatrix() const
{
	return modelview_matrix;
}


const ARFloat* MockTracker::getProjectionMatrix() const
{
	return projection_matrix;
}