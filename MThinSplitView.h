//
//  MThinSplitView.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/12/24.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MDragHandleButton.h"

@interface MThinSplitView : NSSplitView {
	IBOutlet MDragHandleButton *resizeHandle;
	//Handle Resizing Auxiliar Variables
	BOOL inResizeMode;
	float initialClickDeltaX;
}

- (float)dividerThickness;
- (void)drawDividerInRect:(NSRect)aRect;

#pragma mark Splitter Position saving methods

- (void)loadLayoutWithName: (NSString*)name;
- (void)storeLayoutWithName: (NSString*)name;

@end
