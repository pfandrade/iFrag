//
//  MOutlineColumnController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/08/26.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MOutlineColumnController.h"
#import "MOutlineCell.h"

const static NSTimeInterval animationDelay = 5.0/60.0;
static int concurrentQueries = 0;

@interface MOutlineColumnController (Private)
- (NSTimer *)heartbeatTimer;
- (void)setHeartbeatTimer:(NSTimer *)value;
- (void)animate:(NSTimer *)aTimer;
@end


@implementation MOutlineColumnController

- (id)initWithTableColumn:(NSTableColumn *)column
{
	if (self = [super init]) {
		tableColumn = column;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:[[tableColumn tableView] window]];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(startAnimation:) 
													 name:MQueryStarted 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(stopAnimation:) 
													 name:MQueryEnded
												   object:nil];
		
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[heartbeatTimer invalidate];
	[heartbeatTimer release];
	[super dealloc];
}

- (NSTimer *)heartbeatTimer
{
	return heartbeatTimer;
}

- (void)setHeartbeatTimer:(NSTimer *)value
{
	if (heartbeatTimer != value) {
		id old = heartbeatTimer;
		heartbeatTimer = [value retain];
		[old invalidate];
		[old release];
	}
}


- (void)windowWillClose:(NSNotification *)aNotification
{
	[heartbeatTimer invalidate];
	tableColumn = nil;
}

- (void)startAnimation:(NSNotification *)aNotification
{
	if ([self heartbeatTimer] == nil) {
		[self setHeartbeatTimer:[NSTimer scheduledTimerWithTimeInterval:animationDelay  target:self selector:@selector(animate:) userInfo:NULL repeats:YES]];
		[[NSRunLoop currentRunLoop] addTimer:[self heartbeatTimer] forMode:NSEventTrackingRunLoopMode];
	}
	concurrentQueries++;
}

- (void)stopAnimation:(NSNotification *)aNotification
{
	if(!(--concurrentQueries)){
		[[self heartbeatTimer] invalidate];
		[self setHeartbeatTimer:nil];
		[self animate:nil];
	}
}

- (void)animate:(NSTimer *)aTimer
{
	NSTableView *tableView = [tableColumn tableView];
	if ([[tableView window] isVisible]) {
		MOutlineCell *cell = (MOutlineCell *)[tableColumn dataCell];
		double value = fmod(([cell spinnerPosition] + animationDelay), 1.0);
		[cell setSpinnerPosition:value];
		// redraw column
		int columnIndex = [[tableView tableColumns] indexOfObject:tableColumn];
		NSRect redrawRect = [tableView rectOfColumn:columnIndex];
		[tableView setNeedsDisplayInRect:redrawRect];
	}
}

@end
