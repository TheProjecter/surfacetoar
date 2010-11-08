//
//  ConnectMenuViewController.m
//  ConnectMenu
//
//  Created by Jishuo Yang on 10-11-05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "LindsayARAppDelegate.h"
#import "ConnectMenuViewController.h"

@implementation ConnectMenuViewController

- (IBAction)connectPressed: (id) sender
{
	UITextField* ipField =  (UITextField *) [self.view viewWithTag: 100];
	UITextField* numField =  (UITextField *) [self.view viewWithTag: 101];
	
	NSString* ipAddress = ipField.text;
	int numMarkers = (int)[numField.text doubleValue];
	
	LindsayARAppDelegate* delegate = (LindsayARAppDelegate*)[[UIApplication sharedApplication] delegate];
	[delegate connectHostByIP:ipAddress andMarkerCount:numMarkers];
}

- (BOOL)pressDoneKey:(UITextField *)textBoxName {
	[textBoxName resignFirstResponder];
	return YES;
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
