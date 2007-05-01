//
//  MDragHandleButton.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/01/13.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MDragHandleButton.h"


@implementation MDragHandleButton

- (void)resetCursorRects
{
	[self addCursorRect:[self dragHandleFrame] cursor:[NSCursor resizeLeftRightCursor]];
}

- (NSRect)dragHandleFrame
{
	NSRect location = [self frame];
	/* next is the location of the SplitterHandle image
	 * note that this view uses flipped coordinates!
	 * the image is 15x23, I'll use a frame inside that Rect */
	location.origin.x = (location.origin.x + location.size.width) - 14;
	location.origin.y = 3;
	location.size.width = 14;
	location.size.height = 20;
	
	return location;
}

@end
