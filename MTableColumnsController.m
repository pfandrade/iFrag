//
//  MTableColumnsController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/07/22.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MTableColumnsController.h"
#import "MTableHeaderView.h"
#import "MServerTreeController.h"


typedef enum _MColumnPosition {
	MGameColumn			= 0,
	MServerNameColumn	= 1,
	MMODColumn			= 2,
	MPunkbuster			= 3,
	MPrivate			= 4,
	MMapColumn			= 5,
	MPingColumn			= 6,
	MPlayersColumn		= 7
} MColumnPosition;

@interface NSTableView (ApplePrivate)
- (void)_readPersistentTableColumns;
- (void)_writePersistentTableColumns;
@end


@interface MTableColumnsController (Private)

- (void)load;
- (void)save;
- (NSArray *)availableTableColumns;
- (void)selectedServerListChanged:(NSNotification *)aNotification;
- (NSMutableDictionary *)defaultTableColumnsVisibilityForGame:(NSString *)gameName;
- (void)setTableColumnsVisibilityFromDictionary:(NSDictionary *)visbility;
- (void)setTableColumns:(NSArray *)tableColumns;

@end

@implementation MTableColumnsController

- (id) init {
	self = [super init];
	if (self != nil) {
		[self load];
		availableTableColumnsIdentifiers = [[NSArray arrayWithObjects:@"game.icon",@"attributedName",@"gameType",@"isPunkbusterEnabled",@"isPrivate",@"map",@"ping",@"fullness",nil] retain];
	}
	return self;
}

#pragma mark Private Methods

- (void)load
{
	[serversTableView _readPersistentTableColumns];
}

- (void)save
{
	[serversTableView _writePersistentTableColumns];
}

- (NSArray *)availableTableColumns
{
	static NSArray *availableTableColumns = nil;
	
	if(availableTableColumns == nil){
		NSDictionary *availableTableColumnsDict = [NSDictionary dictionaryWithObjects:
			[NSArray arrayWithObjects:@"Game",@"Server Name",@"MOD",@"PunkBuster",@"Private",@"Map",@"Ping",@"Players",nil]
																			  forKeys:availableTableColumnsIdentifiers];
		NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[availableTableColumnsIdentifiers count]];
		NSEnumerator *tcie = [availableTableColumnsIdentifiers objectEnumerator];
		NSString *identifier;
		NSTableColumn *tc;
		
		while(identifier = [tcie nextObject]){
			tc = [[NSTableColumn alloc] init];
			[[tc headerCell] setStringValue:[availableTableColumnsDict valueForKey:identifier]];
			[tc setIdentifier:identifier];
			[tc setEditable:NO];
			[tc setWidth:100.0];
			[tc setSortDescriptorPrototype:[[[NSSortDescriptor alloc] initWithKey:identifier ascending:YES] autorelease]];
			
			if([identifier isEqualToString:@"ping"] || [identifier isEqualToString:@"fullness"]){
				[[tc headerCell] setAlignment:NSRightTextAlignment];
				[[tc dataCell] setAlignment:NSRightTextAlignment];
				[tc setWidth:50.0];
			}
			
			if([identifier isEqualToString:@"attributedName"]){
				[tc setWidth:250.0];
			}
			
			if([identifier isEqualToString:@"game.icon"]){
				NSImage *gameHeader = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"game_header"]];
				[[tc headerCell] setImage:gameHeader];
				[gameHeader release];
				[tc setWidth:[serversTableView rowHeight]];
				[tc setResizingMask:NSTableColumnNoResizing];
				[tc setSortDescriptorPrototype:[[[NSSortDescriptor alloc] initWithKey:@"game.name" ascending:YES] autorelease]];
				[tc setDataCell:[[[NSImageCell alloc] init] autorelease]];
			}
			
			if([identifier isEqualToString:@"isPunkbusterEnabled"] || [identifier isEqualToString:@"isPrivate"]){
				NSImage *header = ([identifier isEqualToString:@"isPunkbusterEnabled"]) 
				? [NSImage imageNamed:@"punk_header.tif"] : [NSImage imageNamed:@"NSLockLockedTemplate"];
				[[tc headerCell] setImage:header];
				[[tc headerCell] setAlignment:NSCenterTextAlignment];
				[tc setWidth:15.0];
				[tc setResizingMask:NSTableColumnNoResizing];
				NSButtonCell *switchButtonCell = [[NSButtonCell alloc] init];
				[switchButtonCell setButtonType:NSSwitchButton];
				[switchButtonCell setControlSize:NSMiniControlSize];
				[switchButtonCell setEditable:NO];
				[switchButtonCell setSelectable:NO];
				[switchButtonCell setEnabled:NO];
				[tc setDataCell:[switchButtonCell autorelease]];
			}

			[tc bind:@"value" 
			toObject:serversController 
		 withKeyPath:[NSString stringWithFormat:@"arrangedObjects.%@",identifier] 
			 options:nil];
			[tempArray addObject:tc];
			[tc release];
		}
		availableTableColumns = [tempArray copy];
		[tempArray release];
	}
	return availableTableColumns;
}

- (NSMutableDictionary *)defaultTableColumnsVisibilityForGame:(NSString *)gameName
{
	int tcCount = [availableTableColumnsIdentifiers count];
	NSMutableArray *visibility = [[NSMutableArray alloc] initWithCapacity:tcCount];
	int i = 0;
	for(; i< tcCount; i++){
		if(i == MGameColumn)
			[visibility addObject:[NSNumber numberWithBool:NO]];
		else
			[visibility addObject:[NSNumber numberWithBool:YES]];
	}
	NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithObjects:visibility forKeys:availableTableColumnsIdentifiers];

	if([gameName isEqualToString:@"Favorites"]){
		[ret setObject:[NSNumber numberWithBool:YES] forKey:@"game.icon"];
	}
	[visibility release];
	return [ret autorelease];
}

- (void)setTableColumnsVisibilityFromDictionary:(NSDictionary *)visibility
{
	for (NSString *identifier in [visibility allKeys]) {
		BOOL b = [[visibility objectForKey:identifier] boolValue];
		[[serversTableView tableColumnWithIdentifier:identifier] setHidden:!b];
	}
}

- (void)setTableColumns:(NSArray *)tableColumns
{
	//remove current columns
	NSArray *tCs = [[serversTableView tableColumns] copy];
	for (NSTableColumn *tc in tCs) {
		[serversTableView removeTableColumn:tc];
	}
	[tCs release];
	
	//add tableColumns
	for (NSTableColumn *tc in tableColumns) {
		[serversTableView addTableColumn:tc];
	}
	
}
#pragma mark Logic

- (void)awakeFromNib
{	
	//set available tableColumns
	[self setTableColumns:[self availableTableColumns]];
	[serversTableView setAutosaveTableColumns:YES];
	
	//set the header view
	MTableHeaderView *mthv = [[MTableHeaderView alloc] initWithFrame:[[serversTableView headerView] frame]];
	[mthv setColumnsMenu:columnsMenu];
	[serversTableView setHeaderView:[mthv autorelease]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(selectedServerWillChange:)
												 name:NSOutlineViewSelectionIsChangingNotification
											   object:serverListsOutlineView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(selectedServerListChanged:)
												 name:NSOutlineViewSelectionDidChangeNotification
											   object:serverListsOutlineView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(save)
												 name:NSApplicationWillTerminateNotification
											   object:NSApp];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tableColumnsDidChange:)
												 name:NSTableViewColumnDidMoveNotification
											   object:serversTableView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tableColumnsDidChange:)
												 name:NSTableViewColumnDidResizeNotification
											   object:serversTableView];
	
	[self selectedServerListChanged:nil];
}

- (void)selectedServerWillChange:(NSNotification *)aNotification
{
//	id selectedServerList = [serverListsController selection];
//	
//	/*protect this code against valueMarkers*/
//	if([selectedServerList valueForKey:@"name"] == NSNoSelectionMarker ||
//	   [selectedServerList valueForKey:@"name"] == NSMultipleValuesMarker ||
//	   [selectedServerList valueForKey:@"name"] == NSNotApplicableMarker)
//		return;
//	
//	[columnsForGames setObject:[serversTableView sortDescriptors] 
//						forKey:[NSString stringWithFormat:@"%@_SortDescriptors",[selectedServerList valueForKey:@"name"]]];
//	[self save];
}

- (void)selectedServerListChanged:(NSNotification *)aNotification
{
	id selectedServerList = [serverListsController selection];
	/*protect this code against valueMarkers*/
	if([selectedServerList valueForKey:@"name"] == NSNoSelectionMarker ||
	   [selectedServerList valueForKey:@"name"] == NSMultipleValuesMarker ||
	   [selectedServerList valueForKey:@"name"] == NSNotApplicableMarker)
		return;
	
	if([[NSUserDefaults standardUserDefaults] objectForKey:
			[NSString stringWithFormat:@"NSTableView Columns %@",[selectedServerList valueForKey:@"name"]]] != nil){ //If information for this game has already been saved
		[serversTableView setAutosaveName:[selectedServerList valueForKey:@"name"]];
		[self load];
	}else{
		[serversTableView setAutosaveName:[selectedServerList valueForKey:@"name"]];
		[self setTableColumnsVisibilityFromDictionary:[self defaultTableColumnsVisibilityForGame:[selectedServerList valueForKey:@"name"]]];
		[self save];
	}
}

- (void)tableColumnsDidChange:(NSNotification *)aNotification
{
	//nothing
}

- (IBAction)toggleColumn:(id)sender
{
	id selectedServerList = [serverListsController selection];
	
	NSMutableDictionary *gameColumns = [columnsForGames objectForKey:[selectedServerList valueForKey:@"name"]];
	NSString *identifier = [availableTableColumnsIdentifiers objectAtIndex:[sender tag]];
	NSTableColumn *tc = [serversTableView tableColumnWithIdentifier:identifier];
		
	if([sender state] == NSOnState){
		[gameColumns setObject:[NSNumber numberWithBool:NO] forKey:identifier];
		[tc setHidden:YES];
		[sender setState:NSOffState];
	}
	else{
		[gameColumns setObject:[NSNumber numberWithBool:YES] forKey:identifier];
		[tc setHidden:NO];
		[sender setState:NSOnState];
	}
	[self save];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	NSString *identifier = [availableTableColumnsIdentifiers objectAtIndex:[menuItem tag]];
	if([[serversTableView tableColumnWithIdentifier:identifier] isHidden]){
		[menuItem setState:NSOffState];
	}
	else{
		[menuItem setState:NSOnState];
	}
	return YES;
}

@end
