//
//  MInspectorWindowController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/06/05.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MInspectorWindowController.h"


@implementation MInspectorWindowController

- (NSArrayController *)serversArrayController {
    return [[serversArrayController retain] autorelease];
}

- (void)setServersArrayController:(NSArrayController *)value {
    if (serversArrayController != value) {
        [serversArrayController release];
        serversArrayController = [value retain];
    }
}

@end
