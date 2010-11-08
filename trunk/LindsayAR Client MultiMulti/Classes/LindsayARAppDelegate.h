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

@class EAGLView;

@interface LindsayARAppDelegate : NSObject <UIApplicationDelegate> {
	CameraController* camera;	// Camera Controller responsible for getting frames from camera
	UIWindow *window;
    EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;


//- (IBAction) buttonTapped;
//- (IBAction) doneButtonOnKeyboardPressed;
@end

