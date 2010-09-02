//
//  AppGLView.m
//  Kidney
//
//  Created by Jishuo Yang on 08/06/10.
//  Copyright 2010 University of Calgary. All rights reserved.
//

#import "AppGLView.h"

#define MARKER_WIDTH 6.5
#define MARKER_HEIGHT 5.25

/**
 * The transformation matrix at which the model is offset from the location of
 * the marker that is being tracked.
 */
float scene_offset[16]={1, 0, 0, 0,
						0, 1, 0, 0,
						0, 0, 1, 0,
						0, 0, 0, 1};


@implementation AppGLView
@synthesize network_delegate;


/**
 * Lindsay function, draws a given LINDSAY model.
 */
-(void) drawMesh:(Mesh*) mesh {
	if(mesh.texMode) {
		[[MeshManager instance].engine setShaderParameter:PAR_SHADER_TEX_MODE to:TRUE];		
	} else {
		[[MeshManager instance].engine setShaderParameter:PAR_SHADER_TEX_MODE to:FALSE];		
	}
	[mesh drawMesh];
}


/**
 * Lindsay function to load a given Lindsay model.
 */
-(NSArray*) load:(NSString*) name alpha:(float) alpha {
	NSArray* array;
	array=[[MeshManager instance].meshes loadLinPath:[[NSBundle mainBundle] pathForResource:name ofType:@"lin"]];
	[array retain];
	for(Mesh* mesh in array) {
		[mesh setColor:[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:alpha]];
		[mesh setBlendMode:BLEND_CULL];
	}
	return array;
}


/**
 * GUI function to update scene_offset with the current values in the control window.
 */
- (void)updateTransformation
{
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	
	glTranslatef([x_translate floatValue], [y_translate floatValue], [z_translate floatValue]);
	glScalef([x_scale floatValue], [y_scale floatValue], [z_scale floatValue]);
	glRotatef([x_rotate floatValue], 1, 0, 0);
	glRotatef([y_rotate floatValue], 0, 1, 0);
	glRotatef([z_rotate floatValue], 0, 0, 1);
	
	glGetFloatv(GL_MODELVIEW_MATRIX, scene_offset);
	
	glPopMatrix();
}


/**
 * Draws the marker texture in a rectangle.
 */
- (void)drawMarker
{
    // glBindTexture is one of the commands that doesn't work within a glBegin - glEnd sequence
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    glBegin(GL_POLYGON);
	glTexCoord2f(0, 1); 
	glVertex3f(0, 0, 0);			// bottom left
	glTexCoord2f(1, 1); 
	glVertex3f(MARKER_WIDTH, 0, 0);			// bottom right
	glTexCoord2f(1, 0); 
	glVertex3f(MARKER_WIDTH, MARKER_HEIGHT, 0);			// top right
	glTexCoord2f(0, 0); 
	glVertex3f(0, MARKER_HEIGHT, 0);			// top left
    glEnd();
}


/**
 * Loads the marker image "markertexture2.png" as a background texture.
 */
- (void)getTextures
{
    // generate the texture objects references
    glGenTextures( 1, texture );
    
    // first we will be working on the each texture individually
    // we aren't using mipmaps or anything, so we'll just do everything
    // in a separate method
    glBindTexture( GL_TEXTURE_2D, texture[0] );
    [self loadPicture: @"markertexture2"];
}


/**
 * Given a file path, loads the given image file as a texture.
 */
- (void) loadPicture: (NSString *) name
{
    NSBitmapImageRep *bitmap;
    NSImage *image; // to use a picture, it must be included in the resources (under groups and files)
    
    //NSLog( @"loadJPEG called with argument %s", name);
    
    // initialize the image to the correct file (name)
    image = [ NSImage imageNamed: name ];
    // create a bitmap with the correct image data
    bitmap = [[NSBitmapImageRep alloc]initWithData: [image TIFFRepresentation]];
    if (bitmap == nil)
        NSLog(@"in LoadGLTextures : NSBitmapImageRep not loaded");
    
    NSLog(@"spp: %d, bps: %d, brp: %d", [bitmap samplesPerPixel], [bitmap bitsPerSample], [bitmap bytesPerRow]);

	
    NSBitmapImageRep *destinationBitmap =
	[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
											pixelsWide:[bitmap pixelsWide]
											pixelsHigh:[bitmap pixelsHigh]
										 bitsPerSample:8
									   samplesPerPixel:3
											  hasAlpha:NO
											  isPlanar:YES
										colorSpaceName:NSCalibratedRGBColorSpace
										   bytesPerRow:4*[bitmap pixelsWide]
										  bitsPerPixel:32];
    
    // if greyscale, change to rgb
    if ([bitmap samplesPerPixel] == 2 && [bitmap bitsPerSample] == 8 ) {
        
		//Allocate a 32bit RGBA bitmap rep for drawing into.
		//The destination bitmap has the same dimensions as the source except for the
		//  fact that it has 4 samples per pixel (RGBA) instead of 2 (G/A).
		//Get the pointer references to the pixel data.
		//We're using unsigned chars (GLubyte's) so that we can increment by byte (1 byte = 1 sample).
        GLubyte *srcBuffer = (GLubyte*)[bitmap bitmapData];
        GLubyte *dstBuffer = (GLubyte*)[destinationBitmap bitmapData];
        
		//iterate through the 16bit image byte by byte
        int i;
        for ( i = 0; i < [bitmap pixelsWide]*[bitmap  pixelsHigh]; i++ ) {
            dstBuffer[i*3] = srcBuffer[i*2];     //put grayscale value into R
            dstBuffer[i*3+1] = srcBuffer[i*2];   //put grayscale value into G
            dstBuffer[i*3+2] = srcBuffer[i*2];   //put grayscale value into B
        }
    }
    // this is what we're expecting in the next function, an RGB image!
    else if ([bitmap samplesPerPixel] == 3 && [bitmap bitsPerSample] == 8 ) {
        destinationBitmap = bitmap;
    }
    else if( [bitmap samplesPerPixel] == 1 && [bitmap bitsPerSample] == 8 )
    {
        GLubyte *srcBuffer = (GLubyte*)[bitmap bitmapData];
        
        GLubyte *dstBuffer = (GLubyte*)[destinationBitmap bitmapData];
		//iterate through our 16bit image byte by byte
        int i;
        for ( i = 0; i < [bitmap pixelsWide]*[bitmap  pixelsHigh]; i++ ) {
            dstBuffer[i*3]   = srcBuffer[i];   //put grayscale value into R
            dstBuffer[i*3+1] = srcBuffer[i];   //put grayscale value into G
            dstBuffer[i*3+2] = srcBuffer[i];   //put grayscale value into B
        }
    }
    
    glPixelStorei(GL_UNPACK_ALIGNMENT,   1   );
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 
                 [destinationBitmap size].width, [destinationBitmap size].height, 0, 
                 // right here, we're expecting RGB unsigned bytes, so the bitmap has to be that
                 GL_RGB, GL_UNSIGNED_BYTE, [destinationBitmap bitmapData]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}


/**
 * Draw all lindsay models
 */
- (void) drawBlend:(NSArray*) array {
	for(Mesh* mesh in array) [self drawMesh:mesh];	// draw lindsay model
}


/**
 * Main rendering loop.
 */
- (void) drawRect: (NSRect) rect
{
	// setting up OpenGL viewport
	GLsizei vportw=(GLsizei) rect.size.width;
	GLsizei vporth=(GLsizei) rect.size.height;
	GLsizei vportx=(GLsizei) 0;
	GLsizei vporty=(GLsizei) 0;
	glViewport(vportx, vporty, vportw, vporth);
	
	
	// clear screen to black
	glClearColor(0,0,0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// Draw marker as background -----------------------------------------
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0, MARKER_WIDTH, 0, MARKER_HEIGHT, -1000, 1);		// make marker fill entire screen, recall that marker texture size is 6.5 x 5.25
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glTranslatef(0, 0, 5);										// translate 5 units forward for better lighting.
	[self drawMarker];
	// Finished drawing marker -------------------------------------------
	
	
	// Draw human model --------------------------------------------------
	// Note that neither the projection or model matrices have been reset,
	// the human model is offset from the marker. So it uses the same starting matrices.
	
	glMatrixMode(GL_MODELVIEW);
	glTranslatef(MARKER_WIDTH/2, MARKER_HEIGHT/2, 0.1);			// set it so that human model is in the center of marker, and slightly forward so that it does not clip through the marker
	
	[self updateTransformation];								// get transformation values from GUI
	
	[network_delegate updateOffset:scene_offset];				// write updated scene_offset to each connected client
	
	glMultMatrixf(scene_offset);								// apply scene_offset to current matrix
	
	glTranslatef(0, 0.104*MARKER_HEIGHT, 0);	// the center of lindsay model is a bit lower compared ot the skeleton. 
											// whereas the skeleton's pelvis is at the center of the model, the human model's pelvis
											// is below center. in order to match them up, we need to move it up a bit.
											// As far as I know there is no way to calculate this, if you want overlay, you'll have to eyeball it.
	
	glScalef(0.0084*MARKER_HEIGHT, 0.0084*MARKER_HEIGHT, 0.0084*MARKER_HEIGHT);
	// the human model and the skeleton model are of dramatically different sizes. We need to shrink the human model to have it match
	// up with the skeleton model. Again, there is no magical formula, we need to eyeball this.
		
	[self drawBlend:skin];
	// Finished drawing model --------------------------------------------
	
	[[self openGLContext] flushBuffer];
	iteration++;
}	


/**
 * Class constructor
 */
- (id) initWithFrame: (NSRect) frame
{
	self = [super initWithFrame:frame];
	if (self != nil) {
		
		glEnable(GL_TEXTURE_2D);
		glEnable(GL_COLOR_MATERIAL);
		[self getTextures];						// load marker texture
		
		skin=[self load:@"body" alpha:1.0];		// load lindsay model
	}
	return self;
}


/**
 * Class destructor
 */
- (void) dealloc
{
	[super dealloc];
}

@end
