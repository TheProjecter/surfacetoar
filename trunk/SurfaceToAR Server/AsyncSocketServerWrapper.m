//
//  AsyncSocketServerWrapper.m
//  SocketServerTest
//
//  Created by Jishuo Yang on 10-08-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AsyncSocketServerWrapper.h"

#define MATRIX_LENGTH 16

// AsyncSocket message tags
#define UPDATE_OFFSET 1
#define ADD_MARKER 2
#define LINK_MODEL 3

@implementation AsyncSocketServerWrapper

- (id)initWithPort:(int)port
{
	listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
	connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
	
	NSError *error = nil;
	
	if (port < 0 || port > 65535)		// port must be between 0 and 65535
	{
		NSLog(@"Invalid port number: %@", port);
		return nil;
	}
	
	if(![listenSocket acceptOnPort:port error:&error])
	{
		NSLog(@"Error starting server: %@", port);
		return nil;
	}
	
	return self;
}


/**
 *
 * When a new client is connected, add it to the list of connected devices.
 *
 */
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	[connectedSockets addObject:newSocket];
}


/**
 *
 * Log when a new client connects.
 *
 */
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"Accepted client %@:%hu", host, port);
}


/**
 *
 * When a socket disconnects, remove it from list of connected sockets.
 *
 */
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	[connectedSockets removeObject:sock];
}


/**
 *
 * Updates the transformation matrix at which an OpenGL scene is offset from the
 * marker it is tracked from. This matrix is written to all client devices.
 * 
 * @param	float[] offset: a size 16 array of floats representing an OpenGL 
 *							transformation matrix
 *
 */
- (void)updateOffset:(float[])offset
{
	NSData *matrix_data = [NSData dataWithBytes:offset length:(sizeof(float) * MATRIX_LENGTH)];
	
	for (AsyncSocket *sock in connectedSockets)
	{
		[sock writeData:matrix_data withTimeout:-1 tag:UPDATE_OFFSET];
	}
}


/**
 *
 * TODO: Add a new (multi)marker to the list of markers on all devices.
 * 
 * @param	marker: info on new marker to be created
 *
 */
- (void)addMarker
{
}


/**
 *
 * TODO: Link an OpenGL scene to a marker, so that this scene would be rendered whenever
 * the marker is detected. Written to all client devices.
 * 
 * @param	marker: marker to be linked to
 * 
 * @param	scene: a sequence of opengl rendering code
 *
 */
- (void)linkScene
{
}


- (void)dealloc 
{
	[listenSocket release];
	[super dealloc];
}

@end
