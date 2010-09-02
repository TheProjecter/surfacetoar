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


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	application.idleTimerDisabled = YES;
    [glView startAnimation];
    return YES;
}

/*
- (IBAction) buttonTapped
{
	UITextField *field = (UITextField*) [window viewWithTag:50];
	client = [[AsyncSocketClientWrapper alloc] initWithAddress:field.text andPort:SOCKET_PORT];
	[client connectToHost];
	[client setDelegate:[glView getRenderer]];
}


- (IBAction)doneButtonOnKeyboardPressed
{}
*/

- (void)applicationWillResignActive:(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	camera = [[CameraController alloc] initVideoCapture];		// initialize camera
	
	// whenever a new camera frame is received, "processFrame" in glView's renderer is called
	[camera setDelegate:[glView getRenderer]];					
	
	// connect to server, ideally should make an ip connect screen
	client = [[AsyncSocketClientWrapper alloc] initWithAddress:@"10.11.16.136" andPort:5000];	
	
	// whenever a new matrix is received from server, "updateOffset" in glView's renderer is called
	[client setDelegate:[glView getRenderer]];
	[glView startAnimation];
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
