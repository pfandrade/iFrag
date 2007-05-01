//
//  MThinSplitView.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/12/24.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import "MThinSplitView.h"

@interface MThinSplitView(Private)

- (NSString*)defaultsKey;
- (void)restoreSplitterPosition;
- (void)saveSplitterPosition;
- (float)relevantDimensionForView:(NSView*)inView;
- (void)setRelevantDimensionForView:(NSView*)inView to:(float)inSize;

@end

@implementation MThinSplitView

- (float)dividerThickness
{
	return (float) 1; //1 px
}

- (void)drawDividerInRect:(NSRect)aRect
{
	[[NSColor grayColor] set];
	NSRectFill(aRect);
}

#pragma mark Mouse Events

- (void)mouseDown:(NSEvent *)theEvent 
{
	NSPoint clickLocation = [self convertPoint:[theEvent locationInWindow] fromView:0];
	NSRect dragHandleFrame = [self convertRect:[resizeHandle dragHandleFrame] fromView:resizeHandle];
		
	if ([self mouse:clickLocation inRect:dragHandleFrame]){
		inResizeMode = YES;
		[[self window] disableCursorRects];
		[[NSCursor resizeLeftRightCursor] push]; 
		initialClickDeltaX = [[[self subviews] objectAtIndex:0] frame].size.width -  clickLocation.x;
	} else {
		inResizeMode = NO; //doesn't seem necessary
		[super mouseDown:theEvent];
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if(inResizeMode){
		inResizeMode = NO;
		[[NSCursor resizeLeftRightCursor] pop];
		[[self window] enableCursorRects];
	}
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if ( !inResizeMode ) {
		[super mouseDragged:theEvent];
		return;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSSplitViewWillResizeSubviewsNotification object:self];
	
	NSPoint newDragLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSView *sourceList = [[self subviews] objectAtIndex:0]; 
	NSRect newFrame = [sourceList frame];
	
	newFrame.size.width = (newDragLocation.x + initialClickDeltaX);
	
	id delegate = [self delegate];
	if( delegate && [delegate respondsToSelector:@selector( splitView:constrainSplitPosition:ofSubviewAt: )] ) {
		float new = [delegate splitView:self constrainSplitPosition:newFrame.size.width ofSubviewAt:0];
		newFrame.size.width = new;
	}
	
	if( delegate && [delegate respondsToSelector:@selector( splitView:constrainMinCoordinate:ofSubviewAt: )] ) {
		float min = [delegate splitView:self constrainMinCoordinate:0. ofSubviewAt:0];
		newFrame.size.width = MAX( min, newFrame.size.width );
	}
	
	if( delegate && [delegate respondsToSelector:@selector( splitView:constrainMaxCoordinate:ofSubviewAt: )] ) {
		float max = [delegate splitView:self constrainMaxCoordinate:0. ofSubviewAt:0];
		newFrame.size.width = MIN( max, newFrame.size.width );
	}
	
	[sourceList setFrame:newFrame];
	[self adjustSubviews];

	[[NSNotificationCenter defaultCenter] postNotificationName:NSSplitViewDidResizeSubviewsNotification object:self];
}

#pragma mark Splitter Position saving methods


- (NSString*)ccd__keyForLayoutName: (NSString*)name
{
	return [NSString stringWithFormat: @"CCDNSSplitView Layout %@", name];
}

- (void)storeLayoutWithName: (NSString*)name
{
	NSString*		key = [self ccd__keyForLayoutName: name];
	NSMutableArray*	viewRects = [NSMutableArray array];
	NSEnumerator*	viewEnum = [[self subviews] objectEnumerator];
	NSView*			view;
	NSRect			frame;
	
	while( (view = [viewEnum nextObject]) != nil )
	{
		
		if( [self isSubviewCollapsed: view] )
			frame = NSZeroRect;
		else
			frame = [view frame];
		
		[viewRects addObject: NSStringFromRect( frame )];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject: viewRects forKey: key];
}

- (void)loadLayoutWithName: (NSString*)name
{
	NSString*		key = [self ccd__keyForLayoutName: name];
	NSMutableArray*	viewRects = [[NSUserDefaults standardUserDefaults] objectForKey: key];
	NSArray*		views = [self subviews];
	int				i, count;
	NSRect			frame;
	
	count = MIN( [viewRects count], [views count] );
	
	for( i = 0; i < count; i++ )
	{
		frame = NSRectFromString( [viewRects objectAtIndex: i] );
		if( NSIsEmptyRect( frame ) )
		{
			frame = [[views objectAtIndex: i] frame];
			if( [self isVertical] )
				frame.size.width = 0;
			else
				frame.size.height = 0;
		}
		
		
		[[views objectAtIndex: i] setFrame: frame];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:NSSplitViewDidResizeSubviewsNotification object:self];
}

@end
