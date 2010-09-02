//
//  ES1Renderer.m
//  LinES1
//
//  Created by Scott Novakowski on 10-02-08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ES1Renderer.h"

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define MATRIX_LENGTH 16


// coordinates for the background camera frame, made so that the frame captured from camera fills background
const GLfloat spriteVertices[] =   {-1,1,0, 
									-1,-1,0, 
									1,1,0,
									1,-1,0};

// texture coordinates for the camera frame.
const GLfloat spriteTexcoords[] =  {0,360.0/1024,
									480.0/1024,360.0/1024,   
									0,0,   
									480.0/1024,0,};

const GLfloat light_position[] = {-1.0, 1.0, 1.0, 0.0 };	// lighting position
const GLfloat mat_col[] = {1.0,0.9,0.8,1};					// lighting diffuse and ambient
const GLfloat mat_spec[] = {0.5,0.5,0.5,1};					// lighting specular component
const GLfloat mat_shininess[] = { 8 };						// lighting shininess


@implementation ES1Renderer
@synthesize iteration=_iteration;


/**
 * Standard gluLookAt, implemented since glu does not exist on the iPhone.
 * Never actually used.
 */
// http://code.google.com/p/glues : glues_project.c
void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez, GLfloat centerx,
			   GLfloat centery, GLfloat centerz, GLfloat upx, GLfloat upy,
			   GLfloat upz)
{
    GLfloat forward[3], side[3], up[3];
    GLfloat m[4][4];
	
    forward[0] = centerx - eyex;
    forward[1] = centery - eyey;
    forward[2] = centerz - eyez;
	
    up[0] = upx;
    up[1] = upy;
    up[2] = upz;
	
    vec3normalize(forward);
	
    /* Side = forward x up */
    vec3cross(side, forward, up);
	vec3normalize(side);
	
    /* Recompute up as: up = side x forward */
    vec3cross(side, forward, up);
	
    mat4identity(&m[0][0]);
    m[0][0] = side[0];
    m[1][0] = side[1];
    m[2][0] = side[2];
	
    m[0][1] = up[0];
    m[1][1] = up[1];
    m[2][1] = up[2];
	
    m[0][2] = -forward[0];
    m[1][2] = -forward[1];
    m[2][2] = -forward[2];
	
    glMultMatrixf(&m[0][0]);
    glTranslatef(-eyex, -eyey, -eyez);
}


// Create an ES 1.1 context
- (id) initWithLayer:(CAEAGLLayer *)layer depth:(BOOL) depth {
	if (self = [super init]) {
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if (!context || ![EAGLContext setCurrentContext:context])
		{
			[self release];
			return nil;
		}
		
		// Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
		glGenFramebuffersOES(1, &defaultFramebuffer);
		glGenRenderbuffersOES(1, &colorRenderbuffer);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
		[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);		
		
		glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
		glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
		
		if (depth) {			
			glGenRenderbuffersOES(1, &depthRenderbuffer);
			glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
			glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
			glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
		}
		
		// Lighting set up --------------------------------------------------
		glEnable(GL_LIGHTING);
		glEnable(GL_LIGHT0);
		glEnable(GL_BLEND);
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		glLightfv(GL_LIGHT0, GL_POSITION, light_position);
		glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, mat_spec);
		glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, mat_shininess);
		glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, mat_col);
		glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, mat_col);
		glEnable(GL_COLOR_MATERIAL);
		// End lighting set up ----------------------------------------------
		
		if (depth)
		{
			glEnable(GL_DEPTH_TEST);
		}
		
		// Setting up the viewport.
		CGRect rect = [[UIScreen mainScreen] bounds];
		glViewport(0, 0, rect.size.width, rect.size.height);
		//Make the OpenGL modelview matrix the default
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		
		
		// Setup texture options so that we are ready to assign camera frames to it ----------------
		glGenTextures(1, &spriteTexture);
		glBindTexture(GL_TEXTURE_2D, spriteTexture);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1024, 1024, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);	
		
		// Set the texture parameters to use a minifying filter and a linear filer (weighted average)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		
		// Enable use of the texture
		glEnable(GL_TEXTURE_2D);
		
		// End texture setup ------------------------------------------------------------------------	
		
		
		// read in data for lindsay skeleton model
		_skel=[Mesh read:[[NSBundle mainBundle] pathForResource:@"skel50" ofType:@"lin"]];
		[_skel retain];
		

		// iteration begins at 0
		_iteration=0;
	}

	return self;
}


- (id) initWithLayer:(CAEAGLLayer *)layer
{
	return [self initWithLayer:layer depth:YES];
}


/**
 * Main rendering loop Part 1
 */
- (void) render
{	
	// This application only creates a single context which is already set current at this point.
	// This call is redundant, but needed if dealing with multiple contexts.
    [EAGLContext setCurrentContext:context];
    
	// This application only creates a single default framebuffer which is already bound at this point.
	// This call is redundant, but needed if dealing with multiple framebuffers.
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);

	// Clear screen to black
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// Disable lighting from last loop
	glDisable(GL_LIGHTING);
	
	// Draw camera frame as background -------------------
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glOrthof(-1, 1, -1, 1, -1000, 1);	// make sure background fills entire screen
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	
	glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, spriteVertices);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, spriteTexcoords);	
	
	glBindTexture(GL_TEXTURE_2D, spriteTexture);	// bind camera image as texture,
													// camera image is updated in a separate delegate method, not here
	glEnable(GL_TEXTURE_2D);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
	glPopMatrix();
	// End drawing background ------------------------------
	
	// Get matrices for overlay model --------------------
	glMatrixMode(GL_PROJECTION);
	glLoadMatrixf(ogl_projection_matrix);	// projection matrix comes from ARTPK, updated in separate delegate method

	glRotatef(90, 0, 0, 1);					// rotate because iPhone camera feed is rotated 90 degrees CCW
	glScalef(480.0/640, 640.0/480, 1);		// scale because ARToolkit returns the scale for rotated 640 x 480, not 480 x 640
	
	glMatrixMode(GL_MODELVIEW);
	glLoadMatrixf(ogl_camera_matrix1);		// model view matrix also from ARTPK, updated in separate delegate method
	[Mesh drawMeshes:_skel];
	glLoadMatrixf(ogl_camera_matrix2);		// model view matrix also from ARTPK, updated in separate delegate method
	[Mesh drawMeshes:_skel];	
	// ---------------------------------------------------
	
	
	// Handle lighting
	glLightfv(GL_LIGHT0, GL_POSITION, light_position); 
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glPopMatrix();
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
	_iteration++;
}



/**
 * Delegate method called by CameraWrapper. This takes the latest camera frame, calculates and updates the
 * new projection and modelview matrices, and updates the ARToolKitPlusWrapper with the address to the latest
 * camera frame.
 */
- (void) processFrameAt:(unsigned char *) baseAddress withWidth:(size_t) width andHeight:(size_t) height
{
	glBindTexture(GL_TEXTURE_2D, spriteTexture);
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_BGRA, GL_UNSIGNED_BYTE, baseAddress);
	
	if(artwrapper == nil) {
		NSString* camera_path = [[NSBundle mainBundle] pathForResource:@"no_distortion" ofType:@"cal"];
		NSString* marker_path1 = [[NSBundle mainBundle] pathForResource:@"marker1" ofType:@"cfg"];
		NSString* marker_path2 = [[NSBundle mainBundle] pathForResource:@"marker2" ofType:@"cfg"];
		
		artwrapper = [[ARToolKitPlusWrapper alloc] initARTKPwithWidth:width andHeight:height];
		if (artwrapper != nil)
		{
			[artwrapper initTrackerWithCameraFile:camera_path];
			[artwrapper addMarkerFromFile:marker_path1];
			[artwrapper addMarkerFromFile:marker_path2];
			[artwrapper getProjectionMatrix:ogl_projection_matrix];
		}
		else
		{
			return;
		}

	}
	[artwrapper setCameraBuffer:baseAddress];
	[artwrapper detectMarker:ogl_camera_matrix1 atIndex:0];
	[artwrapper detectMarker:ogl_camera_matrix2 atIndex:1];
}


- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer
{	
    // Allocate color buffer backing based on the current layer size
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
	
    return YES;
}


/**
 * Destructor
 */
- (void) dealloc
{
	// Tear down GL
	if (defaultFramebuffer)
	{
		glDeleteFramebuffersOES(1, &defaultFramebuffer);
		defaultFramebuffer = 0;
	}
	
	if (colorRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &colorRenderbuffer);
		colorRenderbuffer = 0;
	}
	
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
	
	// Tear down context
	if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	
	[context release];
	context = nil;
	
	[_skel release];
	[artwrapper release];
	[super dealloc];
}

@end
