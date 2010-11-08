//
//  AppController.h
//  Kidney
//
//  Created by Scott Novakowski on 01/05/09.
//  Copyright 2009 University of Calgary. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "AppGLView.h"

@interface AppController : NSObject {
	IBOutlet	AppGLView*	renderView;
	IBOutlet	NSWindow*	renderParamWin;
	IBOutlet	NSTextField* current_ip;
	
	AsyncSocketServerWrapper *server;
}

@end
