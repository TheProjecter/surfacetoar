/**
 * Copyright (C) 2010  ARToolkitPlus Authors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *  Daniel Wagner
 *  Pavel Rojtberg
 */

#include "TrackerMultiMultiMarker.h"

namespace ARToolKitPlus {

TrackerMultiMultiMarker::TrackerMultiMultiMarker(int imWidth, int imHeight, int maxImagePatterns, int pattWidth, int pattHeight,
        int pattSamples, int maxLoadPatterns) :
    Tracker(imWidth, imHeight, maxImagePatterns, pattWidth, pattHeight, pattSamples, maxLoadPatterns) {
    useDetectLite = true;
    numDetected = 0;

    thresh = 150;

    detectedMarkerIDs = new int[MAX_IMAGE_PATTERNS];
    detectedMarkers = new ARMarkerInfo[MAX_IMAGE_PATTERNS];
}

	
TrackerMultiMultiMarker::~TrackerMultiMultiMarker() {
	delete[] detectedMarkerIDs;
	delete[] detectedMarkers;

	for (int i; i < markerInfo.size(); i++)
	{
		arMultiFreeConfig(markerInfo[i]);
	}
}
	

bool TrackerMultiMultiMarker::init(const char* nCamParamFile, ARFloat nNearClip, ARFloat nFarClip) {
	// init some "static" from TrackerMultiMarker
	//
	
	if (this->marker_infoTWO == NULL)
		this->marker_infoTWO = new ARMarkerInfo2[MAX_IMAGE_PATTERNS];

	if (!loadCameraFile(nCamParamFile, nNearClip, nFarClip))
		return false;

	return true;
}
	
	
bool TrackerMultiMultiMarker::addMarker(const char* nMultiFile)
{
	ARMultiMarkerInfoT *marker = arMultiReadConfigFile(nMultiFile);
	if (marker)
	{
		markerInfo.push_back(marker);
		return true;
	}
	return false;
}

	
int TrackerMultiMultiMarker::calc(const unsigned char* nImage, int index) {
	if (index >= markerInfo.size() || index < 0)
	{
		return 0;
	}
	
	numDetected = 0;
	int tmpNumDetected;
	ARMarkerInfo *tmp_markers;

	if (useDetectLite) {
		if (arDetectMarkerLite(const_cast<unsigned char*> (nImage), this->thresh, &tmp_markers, &tmpNumDetected) < 0)
			return 0;
	} else {
		if (arDetectMarker(const_cast<unsigned char*> (nImage), this->thresh, &tmp_markers, &tmpNumDetected) < 0)
			return 0;
	}

	for (int i = 0; i < tmpNumDetected; i++)
		if (tmp_markers[i].id != -1) {
			detectedMarkers[numDetected] = tmp_markers[i];
			detectedMarkerIDs[numDetected++] = tmp_markers[i].id;
			if (numDetected >= MAX_IMAGE_PATTERNS) // increase this value if more markers should be possible to be detected in one image...
				break;
		}

	if (executeMultiMarkerPoseEstimator(tmp_markers, tmpNumDetected, markerInfo[index]) < 0)
		return 0;

	convertTransformationMatrixToOpenGLStyle(markerInfo[index]->trans, this->gl_para);
	return numDetected;
}
	

void TrackerMultiMultiMarker::getDetectedMarkers(int*& nMarkerIDs) {
	nMarkerIDs = detectedMarkerIDs;
}


} // namespace ARToolKitPlus
