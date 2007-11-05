//
//  MToolbarController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/12/21.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import "MToolbarController.h"
#import "MMainController.h"

@implementation MToolbarController

- (void)awakeFromNib
{
	NSWindow *mainWindow = [[NSApp delegate] mainWindow];
	// Set the toolbar
	if([mainWindow toolbar] == nil){
		NSToolbar *mainToolbar = [[NSToolbar alloc] initWithIdentifier:@"mainToolbar"];
		[mainToolbar setDelegate:self];
		[mainToolbar setAllowsUserCustomization:YES];
		[mainToolbar setAutosavesConfiguration:YES];
		[mainWindow setToolbar:mainToolbar];
		[mainToolbar autorelease];
	}
	
}
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
	 itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	if ( [itemIdentifier isEqualToString:MServerInfoItemIdentifier] ) {
		[item setLabel:@"Inspector"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Get Info.tiff"]];
		[item setTarget:mainController];
		[item setAction:@selector(toggleInspector:)];
    } else if ( [itemIdentifier isEqualToString:MPlayersDrawerIdentifier] ) {
		[item setLabel:@"Players"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Drawer-Right.tiff"]];
		[item setTarget:mainController];
		[item setAction:@selector(togglePlayers:)];
	} else if ( [itemIdentifier isEqualToString:MReloadServerList] ) {
		[item setLabel:@"Get New List"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Update.tiff"]];
		[item setTarget:mainController];
		[item setAction:@selector(reloadServerList:)];
	} else if ( [itemIdentifier isEqualToString:MRefreshServerList] ) {
		[item setLabel:@"Refresh"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Refresh.tiff"]];
		[item setTarget:mainController];
		[item setAction:@selector(refreshSelectedServers:)];
	} else if ( [itemIdentifier isEqualToString:MAddServer] ) {
		[item setLabel:@"Add"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Add.tiff"]];
		[item setTarget:mainController];
		[item setAction:@selector(addServer:)];
	} else if ( [itemIdentifier isEqualToString:MDeleteServer] ) {
		[item setLabel:@"Remove"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Remove.tiff"]];
		[item setTarget:mainController];
		[item setAction:@selector(removeServers:)];
	}else if ( [itemIdentifier isEqualToString:MPlayGame] ) {
		[item setLabel:@"Play"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Play.tiff"]];
		[item setTarget:mainController];
		[item setAction:@selector(playGame:)];
    }else if ( [itemIdentifier isEqualToString:MStopQuery] ) {
		[item setLabel:@"Stop"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Stop.tiff"]];
		[item setTarget:mainController];
		[item setAction:@selector(stopQuery:)];
    }else if ( [itemIdentifier isEqualToString:MSearchField] ) {
		NSRect fRect = [searchField frame];
		[item setLabel:@"Search"];
		[item setPaletteLabel:[item label]];
		[item setView:searchField];
		[item setMinSize:fRect.size];
		[item setMaxSize:fRect.size];
    }
	
    return [item autorelease];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:NSToolbarSeparatorItemIdentifier,
		NSToolbarSpaceItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier,
		MPlayersDrawerIdentifier,
		MServerInfoItemIdentifier,
		MReloadServerList,
		MRefreshServerList,
		MPlayGame,
		MAddServer,
		MDeleteServer,
		MStopQuery,
		MSearchField,
		nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:MPlayGame,
		NSToolbarSpaceItemIdentifier,
		MRefreshServerList,
		MReloadServerList,
		MStopQuery,
		NSToolbarFlexibleSpaceItemIdentifier,
		MServerInfoItemIdentifier,
		MPlayersDrawerIdentifier,
		MSearchField,
		nil];
}

// Toolbar Icon Validator
- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
//	if ([[toolbarItem itemIdentifier] isEqual:MReloadServerList]){
//		if([[[serverLists objectAtIndex:[gamesOutlineView selectedRow]] name] isEqualToString:@"Favorites"]){
//			return NO;
//		}
//	}
	return YES;
}

@end
