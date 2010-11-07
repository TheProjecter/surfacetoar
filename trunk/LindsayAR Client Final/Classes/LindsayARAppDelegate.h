//
//  LindsayARAppDelegate.h
//  LindsayAR
//
//  Created by Jishuo Yang on 10-06-14.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CameraController.h"
#import "AsyncSocketClientWrapper.h"
#import "ConnectMenuViewController.h"

@class EAGLView;

@interface LindsayARAppDelegate : NSObject <UIApplicationDelegate> {
	CameraController* camera;	// Camera Controller responsible for getting frames from camera
	UIWindow *window;
    EAGLView *glView;
	AsyncSocketClientWrapper* client;	// Network client responsible for receiving updated offset matrices
	ConnectMenuViewController* connectMenu;
	int numTrackedMarkers;
}

- (void)connectHostByIP:(NSString *)ipAddress andMarkerCount:(int) markerCount;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;
@property (nonatomic, retain) IBOutlet ConnectMenuViewController * connectMenu;
@property (nonatomic) int numTrackedMarkers;



//- (IBAction) buttonTapped;
//- (IBAction) doneButtonOnKeyboardPressed;
@end

