//
//  MSplitViewsDelegate.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/01/13.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MSplitViewsDelegate.h"
#import "MMainController.h"
#import "MInnerSplitView.h"

#define SOURCELIST_MIN_SIZE 50
#define SOURCELIST_MAX_SIZE 250



@implementation MSplitViewsDelegate

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview{
	//TODO:para o caso do LRqqcoisa por YES?
	return NO;
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset
{
	if(sender == [mainController mainSplitView])
		return SOURCELIST_MAX_SIZE;
	if(sender == [mainController innerRigthSplitView])
		return FILTERBAR_SIZE;
		
	return MAXFLOAT; //Will never get here!
}

- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset
{
	if(sender == [mainController mainSplitView])
		return SOURCELIST_MIN_SIZE;
	if(sender == [mainController innerRigthSplitView])
		return FILTERBAR_SIZE;
	
	return 0; //Will never get here!
}

//- (float)splitView:(NSSplitView *)sender constrainSplitPosition:(float)proposedPosition ofSubviewAt:(int)offset
//{
//	
//}
//

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize 
{
	//Used to stop the top subview of innersplitview to resize when the window size changes
	if(sender == [mainController innerRigthSplitView]){
		if ([(MInnerSplitView *)sender isSplitterAnimating]){
			[sender setNeedsDisplay:YES];
            return;
		}
		
		float filterbarsize = ([(MInnerSplitView *)sender isFilterBarHidden]) ? -1 : FILTERBAR_SIZE;
		
		[(MInnerSplitView *)sender setSplitterPosition:filterbarsize animate:NO];
	} else {
		[sender adjustSubviews];
	}
}

@end
