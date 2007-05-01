//
//  MInnerSplitView.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/01/13.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define FILTERBAR_SIZE	23

@interface MInnerSplitView : NSSplitView {
	BOOL isSplitterAnimating;
	BOOL filterBarHidden;
}

- (float)dividerThickness;
- (void)drawDividerInRect:(NSRect)aRect;
- (void)setSplitterPosition:(float)newSplitterPosition animate:(BOOL)animate;
- (float)splitterPosition;
- (BOOL)isSplitterAnimating;
- (BOOL)isFilterBarHidden;
- (void)toggleFilterBar;
- (void)hideFilterBar;
- (void)showFilterBar;

@end
