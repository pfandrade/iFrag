//
//  MDrawerController.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/06/06.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MDrawerController : NSObject {
	IBOutlet NSDrawer *drawer;
	NSArrayController *serversArrayController;
}

- (id)initWithDrawer:(NSDrawer *)aDrawer;
- (id)initWithDrawerNibName:(NSString *)drawerNibName;

- (NSArrayController *)serversArrayController;
- (void)setServersArrayController:(NSArrayController *)value;

- (NSDrawer *)drawer;
- (void)setDrawer:(NSDrawer *)value;



@end
