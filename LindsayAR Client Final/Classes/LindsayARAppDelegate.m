//
//  LindsayARAppDelegate.m
//  LindsayAR
//
//  Created by Jishuo Yang on 10-06-14.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "LindsayARAppDelegate.h"
#import "EAGLView.h"

#define SOCKET_PORT 5000

@implementation LindsayARAppDelegate

@synthesize window;
@synthesize glView;
@synthesize numTrackedMarkers;
@synthesize connectMenu;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	application.idleTimerDisabled = YES;
    [glView startAnimation];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)connectHostByIP:(NSString *)ipAddress andMarkerCount:(int) markerCount
{
	numTrackedMarkers = markerCount;
	
	camera = [[CameraController alloc] initVideoCapture];		// initialize camera
	
	// whenever a new camera frame is received, "processFrame" in glView's renderer is called
	[camera setDelegate:[glView getRenderer]];					
	
	// connect to server, ideally should make an ip connect screen
	client = [[AsyncSocketClientWrapper alloc] initWithAddress:ipAddress andPort:5000];	
	
	// whenever a new matrix is received from server, "updateOffset" in glView's renderer is called
	[client setDelegate:[glView getRenderer]];
	[glView startAnimation];
	
	[connectMenu.view setHidden:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[window addSubview:connectMenu.view];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)dealloc
{
    [window release];
    [glView release];

    [super dealloc];
}

@end
