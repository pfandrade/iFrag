//
//  MTableView.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/06/22.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MTableView : NSTableView {
	NSMutableArray *copiedItemsCache;
}

- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (BOOL)validateUserInterfaceItem:(id)item;

@end
