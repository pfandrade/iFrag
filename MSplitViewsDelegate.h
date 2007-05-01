//
//  MSplitViewsDelegate.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/01/13.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MMainController.h"
#import "MInnerSplitView.h"

@interface MSplitViewsDelegate : NSObject {
	IBOutlet id mainController;
}

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview;
- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset;
- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset;
//- (float)splitView:(NSSplitView *)sender constrainSplitPosition:(float)proposedPosition ofSubviewAt:(int)offset;
- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize;
- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification;
@end
