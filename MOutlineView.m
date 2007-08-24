//
//  MOutlineView.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/06/28.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MOutlineView.h"


@implementation MOutlineView

- (void)awakeFromNib
{
	[[self window] setAcceptsMouseMovedEvents:YES];
	trackingTag = [self addTrackingRect:[self frame] owner:self userData:nil assumeInside:NO];
	mouseOverView = NO;
	mouseOverRow = -1;
	lastOverRow = -1;
}

- (void)dealloc
{
	[self removeTrackingRect:trackingTag];
	[super dealloc];
}

- (void)mouseEntered:(NSEvent*)theEvent
{
	mouseOverView = YES;
}

- (void)mouseMoved:(NSEvent*)theEvent
{
	id myDelegate = [self delegate];
	
	if (!myDelegate)
		return; // No delegate, no need to track the mouse.
	if (![myDelegate respondsToSelector:@selector(outlineView:willDisplayCell:forTableColumn:item:)])
		return; // If the delegate doesn't modify the drawing, don't track.
	
	if (mouseOverView) {
		mouseOverRow = [self rowAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
		
		if (lastOverRow == mouseOverRow)
			return;
		else {
			[self setNeedsDisplayInRect:[self rectOfRow:lastOverRow]];
			lastOverRow = mouseOverRow;
		}
		
		[self setNeedsDisplayInRect:[self rectOfRow:mouseOverRow]];
	}
}

- (void)mouseExited:(NSEvent *)theEvent
{
	mouseOverView = NO;
	[self setNeedsDisplayInRect:[self rectOfRow:mouseOverRow]];
	mouseOverRow = -1;
	lastOverRow = -1;
}

- (int)mouseOverRow
{
	return mouseOverRow;
}

- (BOOL)inLiveResize
{
	return NO;
}

- (void)viewDidEndLiveResize
{
	[super viewDidEndLiveResize];
	
	[self removeTrackingRect:trackingTag];
	trackingTag = [self addTrackingRect:[self frame] owner:self userData:nil assumeInside:NO];
}

@end
