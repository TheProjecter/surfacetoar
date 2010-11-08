//
//  AsyncSocketClientWrapper.h
//  SocketClientTest
//
//  Created by Jishuo Yang on 10-08-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//	Networking class to receive changes in marker and scene information
//	from a touch table server.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@interface AsyncSocketClientWrapper : NSObject {

	/**
	 * The client socket that connects to the touch table.
	 */
	AsyncSocket *clientSocket;
	
	/**
	 * Any class that handles marker changes should be assigned as this class'
	 * delegate. 
	 * The delegate needs to implement the function:
	 *
	 * - (void) updateOffset:(float[]) offset
	 *
	 * where "offset" is a pointer to the transformation matrix at which a
	 * given OpenGL scene is offset from the marker it is being tracked from.
	 *
	 * updateOffset will be called whenever an update call is received from
	 * the server.
	 */
	id delegate;
}

@property (readwrite, assign) id delegate;


/**
 *
 * Constructor for initializing a socket, and to connect to the server with
 * a specified IP address and port.
 * 
 * @param	NSString address: string value of the IP address of the server
 *
 * @param	int Port:	integer value of the port for the socket to connect to, must
 *						be between 0 and 65535
 *
 */
- (id)initWithAddress:(NSString *)address andPort:(int)port;
@end
