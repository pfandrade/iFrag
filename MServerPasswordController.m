//
//  MServerPasswordController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/09/06.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MServerPasswordController.h"


@implementation MServerPasswordController

- (MServer *)server {
    return [[server retain] autorelease];
}

- (void)setServer:(MServer *)value {
    if (server != value) {
        [server release];
        server = [value retain];
    }
}

- (IBAction)connect:(id)sender
{
	ret = [passwordField stringValue];
	[self close];
	[NSApp stopModalWithCode:0];
}

- (IBAction)cancel:(id)sender
{
	ret = nil;
	[self  close];
	[NSApp stopModalWithCode:1];
}

- (NSString *)runModalSheetForWindow:(NSWindow *)window
{
	//force window to load
	[self window];

	ret = nil;
	//let's create the image
	NSImage *slIcon = [[server valueForKeyPath:@"game.icon"] copy];
	[slIcon setScalesWhenResized:YES];
	[slIcon setSize:NSMakeSize(64,64)];
	NSString* imageName = [[NSBundle mainBundle] pathForResource:@"Play" ofType:@"tiff"]; 
	NSImage *playImg = [[NSImage alloc] initWithContentsOfFile:imageName];
	NSImage *composedImage = [[NSImage alloc] initWithSize:[slIcon size]];
	
	[composedImage lockFocus];
	[slIcon compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver];
	[playImg compositeToPoint:NSMakePoint(32,0) operation:NSCompositeSourceOver];
	[composedImage unlockFocus];
	
	[image setImage:composedImage];
	[composedImage release];
	[slIcon release];
	[playImg release];
	[passwordField setStringValue:@""];
	[connectButton setEnabled:NO];
//	[NSApp beginSheet:[self window]
//	   modalForWindow:window
//		modalDelegate:nil 
//	   didEndSelector:nil 
//		  contextInfo:nil];
	[NSApp runModalForWindow:[self window]];
	return ret;
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	if([passwordField stringValue] != nil && ![[passwordField stringValue] isEqualToString:@""]){
		[connectButton setEnabled:YES];
	}else{
		[connectButton setEnabled:NO];
	}
	
}

#pragma mark NSWindow Delegate methods 

- (void)windowWillClose:(NSNotification *)aNotification
{
//	[NSApp endSheet:[self window]];
}

@end
