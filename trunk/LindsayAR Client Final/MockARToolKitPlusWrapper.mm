//
//  MockARToolKitPlusWrapper.m
//  LindsayAR
//
//  Created by Jishuo Yang on 10-08-29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MockARToolKitPlusWrapper.h"
#import "MockTracker.h"

@implementation MockARToolKitPlusWrapper

- (id)initARTKPwithWidth:(int) width andHeight:(int)height
{
	if ([super initARTKPwithWidth:width andHeight:height])
	{
		MockTracker* newTracker = new MockTracker(width, height, 8, 6, 6, 6, 0);
		[self setTracker:newTracker];
		return self;
	}
	else
	{
		return nil;
	}

}

@end
