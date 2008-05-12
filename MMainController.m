//
//  MMainController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/12/21.
//  Copyright 2006 Maracuja Software. All rights reserved.
//
#import "MMainController.h"
#import "MOutlineView.h"
#import "MOutlineCell.h"
#import "MServerList.h"
#import "MServersController.h"
#import "MQStatTask.h"
#import "MQStatXMLParser.h"
#import "MGenericGame.h"
#import "MInspectorWindowController.h"
#import "MDrawerController.h"
#import "MAddServerController.h"
#import "MOutlineColumnController.h"
#import "MSmartListEditorController.h"
#import "MSmartServerList.h"
#import "MServerListsController.h"
#import "MServerTreeController.h"
#import "MWindow.h"

@implementation MMainController

- (void)awakeFromNib
{
	// hack to load some classes that set up preference values
	[MQStatTask class]; [MQStatXMLParser class];
	
	// set doubleClick action for NSTableView and NSOutlineView
	[serversTableView setTarget:self];
	[serversTableView setDoubleAction:@selector(playGame:)];
	[gamesOutlineView setTarget:self];
	[gamesOutlineView setDoubleAction:@selector(editSmartList:)];
	
	//Set the tableview as the nextResponder
	[gamesOutlineView setNextResponder:serversTableView];
	
	// Insert custom cell types into the outline view
    NSTableColumn *tableColumn = [gamesOutlineView tableColumnWithIdentifier:@"gamesColumn"];
	outlineColumnController = [[MOutlineColumnController alloc] initWithTableColumn:tableColumn];
//  MOutlineCell *outlineCell = [[[MOutlineCell alloc] init] autorelease];
//	[outlineCell setEditable: NO];
//    [tableColumn setDataCell:outlineCell];
//	[splitView setNeedsDisplay:YES];
	
	// Order the outline view
	NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"game" ascending:YES];
	[serverTreeController setSortDescriptors:[NSArray arrayWithObject:desc]];
	[serverTreeController setSelectionIndexPath:[NSIndexPath indexPathWithIndex:0]];
	[desc release];
	
	// Reset the ThinSplitView splitter position to the saved state
//	[splitView loadLayoutWithName:THINSPLITVIEW_SAVE_NAME];
	
	// Register as observer to NSWindow terminate notification
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(applicationWillTerminate:) 
												 name:NSApplicationWillTerminateNotification object:NSApp];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(queryTerminated:) 
												 name:MQueryTerminatedNotification object:nil];
	
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
	
	if ([menuItem action] == @selector(copyAddress:)){
		return ([[serversController selectedObjects] count] > 0);
	}
	
	return YES;
}

#pragma mark -
#pragma mark Actions
- (void)copyAddress:(id)sender
{
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
	[pb declareTypes:types owner:self];
	
	NSEnumerator *iter = [[serversController selectedObjects] objectEnumerator];
	NSMutableString *addresses = [[NSMutableString alloc] init];
	id s = [iter nextObject];
	[addresses appendString:[s valueForKey:@"address"]];
	while(s = [iter nextObject]){
		[addresses appendFormat:@"\n%@",[s valueForKey:@"address"]];
	}
	[pb setString:addresses forType:NSStringPboardType];
}

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
		[[inspectorWindowController window] setFrameAutosaveName:@"inspectorWindow"];
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

- (IBAction)stopQuery:(id)sender
{
	MServerList *currentServerList = [serverTreeController selectedServerList];
	[currentServerList terminateQuery];
}

- (IBAction)playGame:(id)sender
{
	MServer *s = [[serversController selectedObjects] objectAtIndex:0];
	[[s game] connectToServer:s];
}

- (IBAction)addToFavorites:(id)sender
{
	MServerList *currentServerList = [serverTreeController selectedServerList];;
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


- (IBAction)refreshSelectedServers:(id)sender
{
	NSArray *selServers = [serversController selectedObjects];
	MServerList *currentServerList = [serverTreeController selectedServerList];
	
	BOOL ret;
	if([selServers count] > 0){
		ret = [currentServerList refreshServers:selServers];
	}else{
		if([serverTreeController isServerListSelected]){
			ret = [currentServerList refreshServers:nil];
		}else{
			MSmartServerList *currentSmartServerList = [serverTreeController selectedSmartServerList];
			ret = [currentServerList refreshServers:[[currentSmartServerList servers] allObjects]];
		}
	}
	if(ret){
		[[NSNotificationCenter defaultCenter] postNotificationName:MQueryStarted object:self];
	}
}

- (IBAction)refreshServerList:(id)sender
{
	MServerList *currentServerList = [serverTreeController selectedServerList];
	
	if([serverTreeController isServerListSelected]){
		if([currentServerList refreshServers:nil]){ // talvez o melhor seja passar todos em vez de nil
			[[NSNotificationCenter defaultCenter] postNotificationName:MQueryStarted object:self];
		}
	}else{
		MSmartServerList *currentSmartServerList = [serverTreeController selectedSmartServerList];
		if([currentServerList refreshServers:[[currentSmartServerList servers] allObjects]]){
			[[NSNotificationCenter defaultCenter] postNotificationName:MQueryStarted object:self];
		}
	}
}

- (IBAction)reloadServerList:(id)sender
{
	MServerList *currentServerList = [[serverTreeController selectedObjects] objectAtIndex:0];
	if([currentServerList reload]){
		[[NSNotificationCenter defaultCenter] postNotificationName:MQueryStarted object:self];
	}
}

- (IBAction)addServer:(id)sender
{
	if (addServerWindowController == nil) { 
		addServerWindowController = [[MAddServerController alloc] initWithWindowNibName:@"AddServerDialog"];
		[addServerWindowController setServerListsTreeController:serverTreeController];
		[addServerWindowController setServersController:serversController];
	}
	
	[addServerWindowController runModalSheetForWindow:mainWindow];	
}

- (IBAction)addSmartList:(id)sender
{
	if (smartListEditorWindowController == nil) { 
		smartListEditorWindowController = [[MSmartListEditorController alloc] initWithWindowNibName:@"SmartListEditorDialog"];
	}
	[smartListEditorWindowController setServerList:[serverTreeController selectedServerList]];
	[smartListEditorWindowController runModalSheetForWindow:mainWindow];
	
	//this is a little hack to get the alternate button back to the default "+" button
	[mainWindow toggleAlternateButtons];
}

- (IBAction)editSmartList:(id)sender
{
	MSmartServerList *ssl = [serverTreeController selectedSmartServerList];
	if(ssl == nil){
		return;
	}
	
	if (smartListEditorWindowController == nil) { 
		smartListEditorWindowController = [[MSmartListEditorController alloc] initWithWindowNibName:@"SmartListEditorDialog"];
	}
	[smartListEditorWindowController setServerList:[serverTreeController selectedServerList]];
	[smartListEditorWindowController setSmartServerList:ssl];
	[smartListEditorWindowController runModalSheetForWindow:mainWindow];
}

#pragma mark -
#pragma mark NSWindow delegate methods

- (void)windowWillClose:(NSNotification *)aNotification
{
	// I'm sure I'll be using this method for something
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[NSApp delegate] windowWillReturnUndoManager:window];
}

#pragma mark Notification Handlers

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
}

- (void)queryTerminated:(id)sl
{
	[[NSNotificationCenter defaultCenter] postNotificationName:MQueryEnded object:self];
}

#pragma mark -
#pragma mark NSOutlineView delegate methods

- (NSString *)outlineView:(NSOutlineView *)ov 
		   toolTipForCell:(NSCell *)cell 
					 rect:(NSRectPointer)rect 
			  tableColumn:(NSTableColumn *)tc 
					 item:(id)item 
			mouseLocation:(NSPoint)mouseLocation
{
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView 
shouldShowCellExpansionForTableColumn:(NSTableColumn *)tableColumn 
			   item:(id)item
{
	return NO;
}
@end
