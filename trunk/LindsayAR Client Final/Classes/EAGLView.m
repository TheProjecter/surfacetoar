//
//  EAGLView.m
//  LinES1
//
//  Created by Scott Novakowski on 10-02-08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EAGLView.h"

@interface EAGLView (PrivateMethods)
- (void)drawView:(id)sender;
@end

@implementation EAGLView

@synthesize animating;
@dynamic animationFrameInterval;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
	return [self initWithCoder:coder depth:YES];
}


/**
 * Class constructor
 */
- (id)initWithCoder:(NSCoder*)coder depth:(BOOL) depth
{    
    if ((self = [super initWithCoder:coder]))
    {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
        if (!renderer)
        {
            renderer = [[ES1Renderer alloc] initWithLayer:eaglLayer depth:depth];
			
            if (!renderer)
            {
                [self release];
                return nil;
            }
        }
		
        animating = FALSE;
        displayLinkSupported = FALSE;
        animationFrameInterval = 1;
        displayLink = nil;
        animationTimer = nil;
		
        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            displayLinkSupported = TRUE;
		
		// read in data for lindsay skeleton model
		_skel=[Mesh read:[[NSBundle mainBundle] pathForResource:@"skel50" ofType:@"lin"]];
		[_skel retain];
    }
	
    return self;
}


/**
 * Returns the renderer that is being used by the device.
 */
- (id)getRenderer
{
	return renderer;
}


/**
 * This is the main draw loop
 */
- (void)drawView:(id)sender
{
    [renderer startRender];
	[self draw];
	[renderer finishRender];
}


/**
 * Draws the skeleton model
 */
- (void) draw 
{
	[Mesh drawMeshes:_skel];
}


- (void)layoutSubviews
{
    [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
		
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView:) userInfo:nil repeats:TRUE];
		
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            animationTimer = nil;
        }
		
        animating = FALSE;
    }
}

- (void)dealloc
{
    [renderer release];
	[_skel release];
    [super dealloc];
}

@end
