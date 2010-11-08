//
//  AppController.m
//  Kidney
//
//  Created by Scott Novakowski on 01/05/09.
//  Copyright 2009 University of Calgary. All rights reserved.
//

#import "AppController.h"

#define SERVER_PORT 5000


@implementation AppController

/**
 * Class initialize
 */
-(void) awakeFromNib {
	server = [[AsyncSocketServerWrapper alloc] initWithPort:SERVER_PORT];	// initialize server
	[renderView setNetwork_delegate:server];	// renderView will use server to send updates to clients
	[current_ip setStringValue:[self IPv4Address]];		// display current IP address in GUI
	[renderView runTimer];
}

/**
 * Find this machine's IP address
 */
-(NSString*)IPv4Address;
{
    NSEnumerator* e = [[[NSHost currentHost] addresses] objectEnumerator];
	NSString* all_addresses = @"127.0.0.1";
    NSString* addr;
    while (addr = (NSString*)[e nextObject])
    {
        if ([[addr componentsSeparatedByString:@"."] count] == 4 && ![addr isEqual:@"127.0.0.1"])
        {
            all_addresses = [NSString stringWithFormat:@"%@, %@",all_addresses, addr];
        }
    }
    return all_addresses; // No non-loopback IPv4 addresses exist
}

- (void) dealloc
{
	[super dealloc];
}

@end
