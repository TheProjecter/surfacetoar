//
//  ES1Renderer.h
//  LinES1
//
//  Created by Scott Novakowski on 10-02-08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "vec.h"
#import "ARToolKitPlusWrapper.h"

@interface ES1Renderer : NSObject {
	
	//AR objects
	float ogl_camera_matrix[16];		// modelview matrix returned from ARTPK
	float ogl_projection_matrix[16];	// projection matrix returned from ARTPK
	float marker_offset[16];			// the matrix at which a scene is offset from the marker, returned from the network client
	
    GLuint spriteTexture;				// the frames returned from the camera made into a texture
	//------------

	int _iteration;						// iteration used for model rotation (if any)
	
	ARToolKitPlusWrapper* artwrapper;	// ARTPK wrapper for AR
	
@private
	EAGLContext *context;
	
	// The pixel dimensions of the CAEAGLLayer
	GLint backingWidth;
	GLint backingHeight;
	
	// The OpenGL names for the framebuffer and renderbuffer used to render to this view
	GLuint defaultFramebuffer, colorRenderbuffer;
	
    GLuint depthRenderbuffer;
}

@property int iteration;

- (id) initWithLayer:(CAEAGLLayer *)layer depth:(BOOL) depth;

- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;
- (void) startRender;
- (void) finishRender;
- (void) processFrameAt:(unsigned char *) baseAddress withWidth:(size_t) width andHeight:(size_t) height;
- (void) updateOffset:(float[]) offset;
@end
