//
//  MServerPasswordController.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/09/06.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MServer.h"


@interface MServerPasswordController : NSWindowController {
	IBOutlet NSTextField *passwordField;
	IBOutlet NSImageView *image;
	IBOutlet NSButton *connectButton;
	MServer *server;
	NSString *ret;
}

- (MServer *)server;
- (void)setServer:(MServer *)value;

- (NSString *)runModalSheetForWindow:(NSWindow *)window;

- (IBAction)connect:(id)sender;
- (IBAction)cancel:(id)sender;

@end
