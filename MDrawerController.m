//
//  MDrawerController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/06/06.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MDrawerController.h"


@implementation MDrawerController

- (id) initWithDrawer:(NSDrawer *)aDrawer 
{
	self = [super init];
	if (self != nil) {
		drawer = [aDrawer retain];
	}
	return self;
}

- (id)initWithDrawerNibName:(NSString *)drawerNibName
{
	self = [super init];
	if (self != nil) {
		[NSBundle loadNibNamed:drawerNibName owner:self];
	}
	return self;
}

- (NSArrayController *)serversArrayController {
    return [[serversArrayController retain] autorelease];
}

- (void)setServersArrayController:(NSArrayController *)value {
    if (serversArrayController != value) {
        [serversArrayController release];
        serversArrayController = [value retain];
    }
}




- (NSDrawer *)drawer {
    return [[drawer retain] autorelease];
}

- (void)setDrawer:(NSDrawer *)value {
    if (drawer != value) {
        [drawer release];
        drawer = [value retain];
    }
}


@end
