//
//  MToolbarController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/12/21.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import "MToolbarController.h"

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
		[item setTarget:serversController];
		[item setAction:@selector(serverInfo:)];
    } else if ( [itemIdentifier isEqualToString:MPlayersDrawerIdentifier] ) {
		[item setLabel:@"Players"];
		[item setPaletteLabel:[item label]];
		[item setImage:[NSImage imageNamed:@"Drawer-Right.tiff"]];
		[item setTarget:playersDrawer];
		[item setAction:@selector(toggle:)];
	} else if ( [itemIdentifier isEqualToString:MReloadServerList] ) {
		[item setLabel:@"Update"];
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
		MDeleteServer, nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:MPlayGame,
		MRefreshServerList,
		MReloadServerList,
		NSToolbarFlexibleSpaceItemIdentifier,
		MServerInfoItemIdentifier,
		MPlayersDrawerIdentifier, nil];
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
