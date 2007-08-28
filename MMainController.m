//
//  MMainController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/12/21.
//  Copyright 2006 Maracuja Software. All rights reserved.
//
#import "MMainController.h"
#import "KBGradientOutlineView.h"
#import "MOutlineView.h"
#import "MOutlineCell.h"
//#import "MComparableAttributedString.h"
//#import "AMButtonBarItem.h"
//#import "CTGradient_AMButtonBar.h"
#import "MServerList.h"
#import "MServersController.h"
#import "MQStatTask.h"
#import "MQStatXMLParser.h"
#import "MDictionaryToArrayTransformer.h"

#define THINSPLITVIEW_SAVE_NAME @"thinsplitview"

@implementation MMainController

+ (void)initialize
{
	// Register Dictionary To Array ValueTransformer
	MDictionaryToArrayTransformer *dictToArray = [[MDictionaryToArrayTransformer new] autorelease];
	[NSValueTransformer setValueTransformer:dictToArray forName:@"DictionaryToArrayTransformer"];
		
}

- (void)awakeFromNib
{
	// hack to load some classes that set up preference values
	[MQStatTask class]; [MQStatXMLParser class];
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
	
	//Set the tableview as the nextResponder
	[gamesOutlineView setNextResponder:serversTableView];
	
	// Insert custom cell types into the outline view
    NSTableColumn *tableColumn = [gamesOutlineView tableColumnWithIdentifier:@"gamesColumn"];
	outlineColumnController = [[MOutlineColumnController alloc] initWithTableColumn:tableColumn];
    MOutlineCell *outlineCell = [[[MOutlineCell alloc] init] autorelease];
	[outlineCell setEditable: NO];
    [tableColumn setDataCell:outlineCell];
	[splitView setNeedsDisplay:YES];
	
	// Order the outline view
	NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"game" ascending:YES];
	[serverTreeController setSortDescriptors:[NSArray arrayWithObject:desc]];
	[serverTreeController setSelectionIndexPath:[NSIndexPath indexPathWithIndex:0]];
	[desc release];
	
	// Reset the ThinSplitView splitter position to the saved state
	[splitView loadLayoutWithName:THINSPLITVIEW_SAVE_NAME];
	
	// Register as observer to NSWindow terminate notification
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(applicationWillTerminate:) 
												 name:NSApplicationWillTerminateNotification object:NSApp];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(queryTerminated:) 
												 name:MQueryTerminatedNotification object:nil];
	
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
	
	if ([menuItem action] == @selector(copyAddress:)){
		return ([[serversController selectedObjects] count] > 0);
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
	MServerList *currentServerList = [[serverTreeController selectedObjects] objectAtIndex:0];
	[currentServerList terminateQuery];
}

- (IBAction)playGame:(id)sender
{
	NSLog(@"%@", [serverTreeController selectionIndexPaths]);
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
		[addServerWindowController setServersController:serversController];
	}
	
	[addServerWindowController runModalSheetForWindow:mainWindow];	
}

- (IBAction)refreshSelectedServers:(id)sender
{
	NSArray *selServers = [serversController selectedObjects];
	MServerList *currentServerList = [[serverTreeController selectedObjects] objectAtIndex:0];
	BOOL ret;
	if([selServers count] > 0)
		ret = [currentServerList refreshServers:selServers];
	else
		ret = [currentServerList refreshServers:nil];
	if(ret){
		[[NSNotificationCenter defaultCenter] postNotificationName:MQueryStarted object:self];
	}
}

- (IBAction)refreshServerList:(id)sender
{
	MServerList *currentServerList = [[serverTreeController selectedObjects] objectAtIndex:0];
	if([currentServerList refreshServers:nil]){ // talvez o melhor seja passar todos em vez de nil
		[[NSNotificationCenter defaultCenter] postNotificationName:MQueryStarted object:self];
	}
}

- (IBAction)reloadServerList:(id)sender
{
	MServerList *currentServerList = [[serverTreeController selectedObjects] objectAtIndex:0];
	if([currentServerList reload]){
		[[NSNotificationCenter defaultCenter] postNotificationName:MQueryStarted object:self];
	}
}

- (IBAction)reloadCurrentServerListFromStore:(id)sender
{
	MServerList *currentServerList = [[serverTreeController selectedObjects] objectAtIndex:0];
	NSFetchRequest *fr = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
	NSEntityDescription *ed = [NSEntityDescription entityForName:@"Server" inManagedObjectContext:context];
	[fr setEntity:ed];
	NSPredicate *p = [NSPredicate predicateWithFormat:@"ANY inServerLists.gameServerType like %@", [currentServerList gameServerType]];
	[fr setPredicate:p];
	NSError *error = nil;
	//NSLog(@"%d",[[context executeFetchRequest:fr error:&error] count]);
	//
	//	//[serversController setManagedObjectContext:context];
	////	[serversController setEntityName:@"Server"];
	[serversController setFetchPredicate:p];
	[context setStalenessInterval:1.0];
	//[serversController fetch:self];
		[serversController fetchWithRequest:fr merge:NO error:&error];
	//	if(error != nil)
	//		NSLog(@"%@", error);
	//[context setStalenessInterval:10.0];
	[context refreshObject:currentServerList mergeChanges:YES];
	[currentServerList setNeedsReload:NO];
	[fr release];
}

#pragma mark -
#pragma mark NSWindow delegate methods

- (void)windowWillClose:(NSNotification *)aNotification
{
	[splitView storeLayoutWithName:THINSPLITVIEW_SAVE_NAME];
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
	
	[splitView storeLayoutWithName:THINSPLITVIEW_SAVE_NAME];
}

- (void)queryTerminated:(id)sl
{
	[[NSNotificationCenter defaultCenter] postNotificationName:MQueryEnded object:self];
}

//#pragma mark Ouline View Delegate Methods
//- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
//{
//	if ([(MOutlineView *)gamesOutlineView mouseOverRow] == [outlineView rowForItem:item])
//		NSLog(@"%d could be highlighted", [outlineView rowForItem:item]);
//	else NSLog(@"%d shouldn't be highlighted", [outlineView rowForItem:item]);
//	
//	NSLog(@"cell address %@",cell);
//}
//
//- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
//{
//	// If the row is selected and the current drawing isn't being used to create a drag image,
//	// colour the text white; otherwise, colour it black
////	int rowIndex = [outlineView rowForItem:item];
////	NSColor *fontColor = ( [[outlineView selectedRowIndexes] containsIndex:rowIndex] && 
////						   ([outlineView editedRow] != rowIndex) && 
////						   (![[(KBGradientOutlineView *)outlineView draggedRows] containsIndex:rowIndex]) ) ?
////		[NSColor whiteColor] : [NSColor blackColor];
////	[cell setTextColor:fontColor];
//}
//
//- (void)outlineViewSelectionDidChange:(NSNotification *)notification
//{
	//MServerList *currentServerList = [[serverTreeController selectedObjects] objectAtIndex:0];
//	if([currentServerList needsReload]){
//		[self reloadCurrentServerListFromStore:self];
//	}
//}

//- (void)serveListNeedsReload:(NSNotification *)notification
//{
//	MServerList *currentServerList = [[serverTreeController selectedObjects] objectAtIndex:0];
//	MServerList *sl = [notification object];
//	if(sl ==  currentServerList){
//		[self reloadCurrentServerListFromStore:self];
//	}
//}

@end
