//
//  MActionButton.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/16.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MActionButton.h"
#import "MActionButtonCell.h"

@implementation MActionButton

- (id)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect])
	{
		[self setPullsDown:YES];
	}
	
	return self;
}

+ (Class)cellClass
{
	return [MActionButtonCell class];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if (self = [super initWithCoder:decoder])
	{
		if (![[self cell] isKindOfClass:[MActionButtonCell class]])
		{
			MActionButtonCell *cell = [[MActionButtonCell alloc] initTextCell:@"" pullsDown:YES];
			[self setCell:cell];
			[cell release];
		}
	}
	
	return self;
}

@end
