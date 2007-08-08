//
//  MTableHeaderView.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/07/23.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MTableHeaderView.h"


@implementation MTableHeaderView

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	//NSLog(@"%d",[theEvent buttonMask]);
	//if([theEvent type] == NSRightMouseDown || [theEvent buttonMask] == NSLeftMouseDownMask&NSControlKeyMask)
		return [self columnsMenu];
	//return nil;
}

- (NSMenu *)columnsMenu {
    return [[columnsMenu retain] autorelease];
}

- (void)setColumnsMenu:(NSMenu *)value {
    if (columnsMenu != value) {
        [columnsMenu release];
        columnsMenu = [value retain];
    }
}


@end
