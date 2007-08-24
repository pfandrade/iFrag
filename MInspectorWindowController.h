//
//  MInspectorWindowController.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/06/05.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MInspectorWindowController : NSWindowController {
	NSArrayController *serversArrayController;
}

- (NSArrayController *)serversArrayController;
- (void)setServersArrayController:(NSArrayController *)value;

@end
