//
//  AsyncSocketServerWrapper.h
//  SocketServerTest
//
//  Created by Jishuo Yang on 10-08-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//	Networking class to facilitate synchronization between touch table
//	and handheld mobile.
//	This is the server that multiple clients connect to. It updates 
//	each client with marker and scene information when they change.

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"

@interface AsyncSocketServerWrapper : NSObject {
	
	/**
	 * The server socket that listens for connections from mobile clients
	 */
	AsyncSocket *listenSocket;
	
	/**
	 * An array of all the connected sockets
	 */
	NSMutableArray *connectedSockets;
}

/**
 *
 * Constructor for initializing the socket with a port to listen on.
 * 
 * @param	int Port:	integer value of the port for the socket to listen on, must
 *						be between 0 and 65535
 *
 */
- (id)initWithPort:(int)port;

/**
 *
 * Updates the transformation matrix at which an OpenGL scene is offset from the
 * marker it is tracked from. This matrix is written to all client devices.
 * 
 * @param	float[] offset: a size 16 array of floats representing an OpenGL 
 *							transformation matrix
 *
 */
- (void)updateOffset:(float[])offset;

@end
