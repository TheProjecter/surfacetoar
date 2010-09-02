//
//  AppGLView.h
//  Kidney
//
//  Created by Scott Novakowski on 02/06/09.
//  Copyright 2009 University of Calgary. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "AsyncSocketServerWrapper.h"

@interface AppGLView : OpenGLView {

	NSArray* skin;	// lindsay model
	
	GLint texture[1];	// marker texture
	
	// Links to GUI values in the Control Panel Window.
	IBOutlet NSTextField *x_translate;
	IBOutlet NSTextField *y_translate;
	IBOutlet NSTextField *z_translate;
	IBOutlet NSTextField *x_rotate;
	IBOutlet NSTextField *y_rotate;
	IBOutlet NSTextField *z_rotate;
	IBOutlet NSTextField *x_scale;
	IBOutlet NSTextField *y_scale;
	IBOutlet NSTextField *z_scale;
	
	// socket server that updates the offset matrix for each client
	id network_delegate;
}
@property (readwrite, assign) id network_delegate;

- (void) loadPicture: (NSString *) name;

@end
