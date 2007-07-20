//
//  MServersController.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/05.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MServersController : NSArrayController {
	IBOutlet id serversTableView;
	NSMutableArray *copiedItemsCache;
}

- (BOOL)canCut;
- (BOOL)canCopy;
- (BOOL)canPaste;

- (void)pasteIntoServerList:(id)sl fromPasteboard:(NSPasteboard *)pb;
- (BOOL)canPasteIntoServerList:(id)sl fromPasteboard:(NSPasteboard *)pb;

@end
