//
//  AsyncSocketClientWrapper.m
//  SocketClientTest
//
//  Created by Jishuo Yang on 10-08-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AsyncSocketClientWrapper.h"

#define MATRIX_LENGTH 16

// AsyncSocket message tags
#define UPDATE_OFFSET 1
#define ADD_MARKER 2
#define LINK_MODEL 3

@implementation AsyncSocketClientWrapper
@synthesize delegate;

- (id)initWithAddress:(NSString *)address andPort:(int)port
{
	
	clientSocket = [[AsyncSocket alloc] initWithDelegate:self];
	
	NSError *err = nil;
	if(![clientSocket connectToHost:address onPort:port error:&err])
	{
		NSLog(@"Error: %@", err);
	}
	return self;
}


/**
 *
 * When we have connected to server, start reading from socket.
 *
 */
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu", sock, host, port);
	
	[sock readDataWithTimeout:-1 tag:0];
}


/**
 *
 * When we have read some data from the server, parse the data according to the tag.
 *
 */
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	//NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	
	if (tag == UPDATE_OFFSET)
	{
		float offset[16];
		[data getBytes:offset length:sizeof(float)*MATRIX_LENGTH];
		[delegate updateOffset:offset];
	}
	else if (tag == ADD_MARKER)
	{
		//[delegate addMarker:data];
	}
	else if (tag == LINK_MODEL)
	{
		//[delegate linkModel:data];
	}
	
	[sock readDataWithTimeout:-1 tag:1];
}


- (void)dealloc 
{
	[clientSocket disconnect];
	
	[clientSocket release];
	
	[super dealloc];
}

@end
