//
//  MActionButtonCell.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/16.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MActionButtonCell.h"


@implementation MActionButtonCell

- (id)initTextCell:(NSString *)stringValue pullsDown:(BOOL)pullDown
{
	if (self = [super initTextCell:stringValue pullsDown:YES])
	{
		buttonCell = [[NSButtonCell alloc] initImageCell:[NSImage imageNamed:@"Action.tiff"]];
		[buttonCell setButtonType:NSPushOnPushOffButton];
		[buttonCell setImagePosition:NSImageOnly];
		[buttonCell setBordered:NO];
		
		[self setUsesItemFromMenu:NO];
		[self synchronizeTitleAndSelectedItem];
	}
	
	return self;
}

- (void)dealloc
{
	[buttonCell release];
	
	[super dealloc];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[buttonCell drawWithFrame:cellFrame inView:controlView];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[buttonCell highlight:flag withFrame:cellFrame inView:controlView];
	[super highlight:flag withFrame:cellFrame inView:controlView];
}

- (void)setImage:(NSImage *)img
{
	[buttonCell setImage:img];
}

- (void)setAlternateImage:(NSImage *)img
{
	[buttonCell setAlternateImage:img];
}

- (void)setEnabled:(BOOL)flag
{
	[buttonCell setEnabled:flag];
}

- (void)performClick:(id)sender
{
	[buttonCell performClick:sender];
	[super performClick:sender];
}

@end
