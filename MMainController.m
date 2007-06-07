//
//  MMainController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/12/21.
//  Copyright 2006 Maracuja Software. All rights reserved.
//
#import "MMainController.h"
#import "KBGradientOutlineView.h"
#import "MOutlineCell.h"
#import "MComparableAttributedString.h"
#import "AMButtonBarItem.h"
#import "CTGradient_AMButtonBar.h"
#import "MNotifications.h"
#import "MServerList.h"
#import "MServersController.h"

#define THINSPLITVIEW_SAVE_NAME @"thinsplitview"

@implementation MMainController

- (void)awakeFromNib
{
	
	// Setup the Button Bar
//	[rightSplitView showFilterBar];
//	[filterBar setShowsBaselineSeparator:NO];
//	[filterBar setBackgroundGradient:[CTGradient blueButtonBarGradient]];
//	AMButtonBarItem *item = [[[AMButtonBarItem alloc] initWithIdentifier:@"all"] autorelease];
//	[item setTitle:@"All"];
//	[filterBar insertItem:item atIndex:0];
//	item = [[[AMButtonBarItem alloc] initWithIdentifier:@"world"] autorelease];
//	[item setTitle:@"World"];
//	[filterBar insertItem:item atIndex:1];
//	item = [[[AMButtonBarItem alloc] initWithIdentifier:@"lan"] autorelease];
//	[item setTitle:@"LAN"];
//	[filterBar insertItem:item atIndex:2];
	[rightSplitView hideFilterBar];
	
	// Set appearance options (like gradient) in the custom outlineView
	[(KBGradientOutlineView *)gamesOutlineView setUsesGradientSelection:YES];
	[(KBGradientOutlineView *)gamesOutlineView setSelectionGradientIsContiguous:YES];
	
	// Insert custom cell types into the outline view
    NSTableColumn *tableColumn = [gamesOutlineView tableColumnWithIdentifier:@"gamesColumn"];
    MOutlineCell *outlineCell = [[[MOutlineCell alloc] init] autorelease];
    [outlineCell setEditable: NO];
    [tableColumn setDataCell:outlineCell];
	[tableColumn setWidth:[[[splitView subviews] objectAtIndex:0] frame].size.width];
	[splitView setNeedsDisplay:YES];
	
	//order the outline view
	NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"game" ascending:YES];
	[serverTreeController setSortDescriptors:[NSArray arrayWithObject:desc]];
	[desc release];
	
	// Reset the ThinSplitView splitter position to the saved state
	[splitView loadLayoutWithName:THINSPLITVIEW_SAVE_NAME];
	
	// register as observer to NSWindow terminate notification
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(applicationWillTerminate:) 
												 name:NSApplicationWillTerminateNotification object:NSApp];
}

- (void)resizedSplitView:(id)theSplitview toSize:(float)newSize
{
	if(splitView == splitView){
		NSTableColumn *tc = [gamesOutlineView tableColumnWithIdentifier:@"gamesColumn"];
		[tc setWidth:newSize];
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == @selector(toggleInspector:)){
		if(![[inspectorWindowController window] isVisible])
			[menuItem setTitle:@"Show Inspector"];
		else
			[menuItem setTitle:@"Hide Inspector"];
	}
	
	if ([menuItem action] == @selector(togglePlayers:)){
		if(!([[playersDrawerController drawer] state] == NSDrawerOpenState))
			[menuItem setTitle:@"Show Players"];
		else
			[menuItem setTitle:@"Hide Players"];
	}
	
	return YES;
}

#pragma mark Accessor Methods
- (id)mainSplitView
{
	return [[splitView retain] autorelease];
}

- (id)innerRigthSplitView
{
	return [[rightSplitView retain] autorelease];
}

#pragma mark -
#pragma mark Actions

- (IBAction)showPreferences:(id)sender
{
	if (preferencesWindowController == nil) { 
		preferencesWindowController = [[NSWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
	}
	[[preferencesWindowController window] makeKeyAndOrderFront:nil];
}

- (IBAction)toggleInspector:(id)sender
{
	if (inspectorWindowController == nil) { 
		inspectorWindowController = [[MInspectorWindowController alloc] initWithWindowNibName:@"InspectorWindow"];
		[inspectorWindowController setServersArrayController:serversController];
	}
	
	NSWindow *inspectorWindow = [inspectorWindowController window];
	
	if([inspectorWindow isVisible]){
		[inspectorWindow orderOut:self];
	}else{
		[inspectorWindow orderFront:self];
	}	
}

- (IBAction)togglePlayers:(id)sender
{
	if (playersDrawerController == nil) { 
		playersDrawerController = [[MDrawerController alloc] initWithDrawerNibName:@"PlayersDrawer"];
		[[playersDrawerController drawer] setParentWindow:mainWindow];
		[playersDrawerController setServersArrayController:serversController];
	}
	
	[[playersDrawerController drawer] toggle:sender];
}

- (IBAction)playGame:(id)sender
{
	//TODO:
}

- (IBAction)addToFavorites:(id)sender
{
	MServerList *currentServerList = [[serverTreeController selectedObjects] objectAtIndex:0];
	if([[currentServerList name] isEqualToString:@"Favorites"]) 
		return;
	
	//servers to add
	NSArray *servers = [serversController selectedObjects];
	
	//lets get the Favorites list
	NSArray *serverLists = [serverListsController arrangedObjects];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"name like \"Favorites\""];
	
	MServerList *favoritesList = [[serverLists filteredArrayUsingPredicate:pred] objectAtIndex:0];
	//and add the servers
	[favoritesList addServers:[NSSet setWithArray:servers]];
	[[[NSApp delegate] managedObjectContext] save:nil];
}

- (IBAction)addServer:(id)sender
{
	if (addServerWindowController == nil) { 
		addServerWindowController = [[MAddServerController alloc] initWithWindowNibName:@"AddServerDialog"];
		[addServerWindowController setServerListsTreeController:serverTreeController];
	}
	
	[NSApp beginSheet:[addServerWindowController window]
	   modalForWindow:mainWindow
		modalDelegate:nil 
	   didEndSelector:nil 
		  contextInfo:nil];
	
}

- (IBAction)removeServers:(id)sender
{
//	NSArray *selServers = [serversDataSource selectedObjects];
//	if([selServers count] <= 0)
//		return;
//	
//	[currentServerList removeServers:[NSSet setWithArray:selServers]];
}

- (IBAction)refreshSelectedServers:(id)sender
{
	NSArray *selServers = [serversController selectedObjects];
	MServerList *currentServerList = [[serverTreeController selectedObjects] objectAtIndex:0];
	if([selServers count] > 0)
		[currentServerList refreshServers:selServers];
	else
		[currentServerList refreshServers:nil];
}

- (IBAction)refreshServerList:(id)sender
{
	MServerList *currentServerList = [[serverTreeController selectedObjects] objectAtIndex:0];
	[currentServerList refreshServers:nil]; // talvez o melhor seja passar todos em vez de nil
}

- (IBAction)reloadServerList:(id)sender
{
	MServerList *currentServerList = [[serverTreeController selectedObjects] objectAtIndex:0];
	[currentServerList reload];
}

#pragma mark -
#pragma mark NSWindow delegate methods

- (void)windowWillClose:(NSNotification *)aNotification
{
	[splitView storeLayoutWithName:THINSPLITVIEW_SAVE_NAME];
}

#pragma mark NSApp notification handlers

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	// delete any temporary files that were not deleted
	NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:NSTemporaryDirectory()];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.lastPathComponent like 'iFrag.*'"];
	NSEnumerator *filesToDelete = [[dirContents filteredArrayUsingPredicate:pred] objectEnumerator];
	NSString *file;
	while(file = [filesToDelete nextObject]){
		[[NSFileManager defaultManager] removeFileAtPath:[NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(),file] 
												 handler:nil];
	}
	
	[splitView storeLayoutWithName:THINSPLITVIEW_SAVE_NAME];
}

#pragma mark Ouline View Delegate Methods

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	// If the row is selected and the current drawing isn't being used to create a drag image,
	// colour the text white; otherwise, colour it black
	int rowIndex = [outlineView rowForItem:item];
	NSColor *fontColor = ( [[outlineView selectedRowIndexes] containsIndex:rowIndex] && 
						   ([outlineView editedRow] != rowIndex) && 
						   (![[(KBGradientOutlineView *)outlineView draggedRows] containsIndex:rowIndex]) ) ?
		[NSColor whiteColor] : [NSColor blackColor];
	[cell setTextColor:fontColor];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
//	[self setCurrentServerList:[serverLists objectAtIndex:[gamesOutlineView selectedRow]]];
//	NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
//	[context refreshObject:currentServerList mergeChanges:YES];
//	
//	[mainWindow setTitle:[NSString stringWithFormat:@"%@ (%d servers)",
//		[currentServerList name], 
//		[[currentServerList valueForKey:@"servers"] count]]];
//	[mainWindow displayIfNeeded];
	
	//TODO por aqui um refreshObjects:mergeChanges:NO !
}

@end
