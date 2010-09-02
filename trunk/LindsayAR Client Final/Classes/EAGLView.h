//
//  EAGLView.h
//  LinES1
//
//  Created by Scott Novakowski on 10-02-08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Mesh.h"
#import "Plane.h"
#import "ParameterControl.h"
#import "ES1Renderer.h"

@interface EAGLView : UIView {
    ES1Renderer* renderer;	// the rendering uses OpenGL ES 1
@private
	NSArray* _skel;		// array containing information on the lindsay skeleton model
    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
    // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
    // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
    // isn't available.
    id displayLink;
    NSTimer *animationTimer;
}
@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
- (id)initWithCoder:(NSCoder*)coder depth:(BOOL) depth;

- (void)startAnimation;
- (void)stopAnimation;
- (void) draw;
- (id) getRenderer;

@end
