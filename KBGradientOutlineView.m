#import "KBGradientOutlineView.h"
#import "NSBezierPath_AMShading.h"	// For gradient highlighting


// We override (and may call) an undocumented private NSTableView method,
// so we need to declare that here
@interface NSObject (NSTableViewPrivateMethods)
- (id)_highlightColorForCell:(NSCell *)cell;
@end


@implementation KBGradientOutlineView

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
	[nc addObserver:self
		   selector:@selector(windowDidChangeKeyNotification:)
			   name:NSWindowDidResignKeyNotification
			 object:newWindow];
	
	[nc removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
	[nc addObserver:self
		   selector:@selector(windowDidChangeKeyNotification:)
			   name:NSWindowDidBecomeKeyNotification
			 object:newWindow];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)windowDidChangeKeyNotification:(NSNotification *)notification
{
	[self setNeedsDisplay:YES];
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect
{
	if (!usesGradientSelection)
	{
		[super highlightSelectionInClipRect:clipRect];
		return;
	}
	
	NSColor *topLineColor, *bottomLineColor, *gradientStartColor, *gradientEndColor;
	
	// Color will depend on whether or not we are the first responder
	NSResponder *firstResponder = [[self window] firstResponder];
	if ( (![firstResponder isKindOfClass:[NSView class]]) ||
		 (![(NSView *)firstResponder isDescendantOf:self]) ||
		 (![[self window] isKeyWindow]) ||
		 ([self usesDisabledGradientSelectionOnly]) )
	{
		topLineColor = [NSColor colorWithDeviceRed:(173.0/255.0) green:(187.0/255.0) blue:(209.0/255.0) alpha:1.0];
		bottomLineColor = [NSColor colorWithDeviceRed:(150.0/255.0) green:(161.0/255.0) blue:(183.0/255.0) alpha:1.0];
		gradientStartColor = [NSColor colorWithDeviceRed:(168.0/255.0) green:(183.0/255.0) blue:(205.0/255.0) alpha:1.0];
		gradientEndColor = [NSColor colorWithDeviceRed:(157.0/255.0) green:(174.0/255.0) blue:(199.0/255.0) alpha:1.0];
	}
	else
	{
		topLineColor = [NSColor colorWithCalibratedRed:(61.0/255.0) green:(123.0/255.0) blue:(218.0/255.0) alpha:1.0];
		bottomLineColor = [NSColor colorWithCalibratedRed:(31.0/255.0) green:(92.0/255.0) blue:(207.0/255.0) alpha:1.0];
		gradientStartColor = [NSColor colorWithCalibratedRed:(89.0/255.0) green:(153.0/255.0) blue:(209.0/255.0) alpha:1.0];
		gradientEndColor = [NSColor colorWithCalibratedRed:(33.0/255.0) green:(94.0/255.0) blue:(208.0/255.0) alpha:1.0];
	}
	
	NSIndexSet *selRows = [self selectedRowIndexes];
	int rowIndex = [selRows firstIndex];
	int endOfCurrentRunRowIndex, newRowIndex;
	NSRect highlightRect;
	
	while (rowIndex != NSNotFound)
	{
		if ([self selectionGradientIsContiguous])
		{
			newRowIndex = rowIndex;
			do {
				endOfCurrentRunRowIndex = newRowIndex;
				newRowIndex = [selRows indexGreaterThanIndex:endOfCurrentRunRowIndex];
			} while (newRowIndex == endOfCurrentRunRowIndex + 1);
			
			highlightRect = NSUnionRect([self rectOfRow:rowIndex],[self rectOfRow:endOfCurrentRunRowIndex]);
		}
		else
		{
			newRowIndex = [selRows indexGreaterThanIndex:rowIndex];
			highlightRect = [self rectOfRow:rowIndex];
		}
		
		if ([self hasBreakBetweenGradientSelectedRows])
			highlightRect.size.height -= 1.0;
		
		[topLineColor set];
		NSRectFill(highlightRect);
		
		highlightRect.origin.y += 1.0;
		highlightRect.size.height-=1.0;
		[bottomLineColor set];
		NSRectFill(highlightRect);
		
		highlightRect.size.height -= 1.0;
			
		[[NSBezierPath bezierPathWithRect:highlightRect] linearGradientFillWithStartColor:gradientStartColor
																				 endColor:gradientEndColor];
		
		rowIndex = newRowIndex;
	}
}

- (id)_highlightColorForCell:(NSCell *)cell
{
	if (!usesGradientSelection)
		return [super _highlightColorForCell:cell];
	return nil;
}

- (void)selectRow:(int)row byExtendingSelection:(BOOL)extend
{
	[super selectRow:row byExtendingSelection:extend];
	
	// If we are using a contiguous gradient, we need to force a redraw of more than
	// just the current row - all selected rows will need redrawing
	if ([self usesGradientSelection]&&[self selectionGradientIsContiguous])
		[self setNeedsDisplay:YES];
}

- (void)selectRowIndexes:(NSIndexSet *)rowIndexes byExtendingSelection:(BOOL)extend
{
	[super selectRowIndexes:rowIndexes byExtendingSelection:extend];
	
	// If we are using a contiguous gradient, we need to force a redraw of more than
	// just the current row - all selected rows will need redrawing
	if ([self usesGradientSelection]&&[self selectionGradientIsContiguous])
		[self setNeedsDisplay:YES];
} 

- (void)deselectRow:(int)row;
{
	[super deselectRow:row];
	
	// If we are using a contiguous gradient, we need to force a redraw of more than
	// just the current row in case multiple are selected, as selected rows will need redrawing
	if ([self usesGradientSelection]&&[self selectionGradientIsContiguous])
		[self setNeedsDisplay:YES];
}

- (NSImage *)dragImageForRowsWithIndexes:(NSIndexSet *)dragRows tableColumns:(NSArray *)tableColumns 
								   event:(NSEvent*)dragEvent offset:(NSPointPointer)dragImageOffset
{
	// We need to save the dragged row indexes so that the delegate can choose how to colour the
	// text depending on whether it is being used for a drag image or not (eg. selected row may
	// have white text, but we still want to colour it black when drawing the drag image)
	draggedRows = dragRows;
	
	NSImage *image = [super dragImageForRowsWithIndexes:dragRows tableColumns:tableColumns
										event:dragEvent offset:dragImageOffset];
	
	draggedRows = nil;
	return image;
}

- (NSIndexSet *)draggedRows
{
	return draggedRows;
}

- (void)setUsesGradientSelection:(BOOL)flag
{
	usesGradientSelection = flag;
	[self setNeedsDisplay:YES];
}

- (BOOL)usesGradientSelection
{
	return usesGradientSelection;
}

- (void)setSelectionGradientIsContiguous:(BOOL)flag
{
	selectionGradientIsContiguous = flag;
	[self setNeedsDisplay:YES];
}

- (BOOL)selectionGradientIsContiguous
{
	return selectionGradientIsContiguous;
}

- (void)setUsesDisabledGradientSelectionOnly:(BOOL)flag
{
	usesDisabledGradientSelectionOnly = flag;
	[self setNeedsDisplay:YES];
}

- (BOOL)usesDisabledGradientSelectionOnly
{
	return usesDisabledGradientSelectionOnly;
}

- (void)setHasBreakBetweenGradientSelectedRows:(BOOL)flag
{
	hasBreakBetweenGradientSelectedRows = flag;
	[self setNeedsDisplay:YES];
}

- (BOOL)hasBreakBetweenGradientSelectedRows
{
	return hasBreakBetweenGradientSelectedRows;
}

@end