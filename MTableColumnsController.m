//
//  MTableColumnsController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/07/22.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MTableColumnsController.h"
#import "MTableHeaderView.h"

NSString *const MColumnsForGames = @"Columns For Games";

typedef enum _MColumnPosition {
	MGameColumn			= 0,
	MServerNameColumn	= 1,
	MMODColumn			= 2,
	MMapColumn			= 3,
	MPingColumn			= 4,
	MPlayersColumn		= 5
} MColumnPosition;

@interface MTableColumnsController (Private)

- (void)load;
- (void)save;
- (NSArray *)availableTableColumns;
- (void)selectedServerListChanged:(NSNotification *)aNotification;

@end

@implementation MTableColumnsController

- (id) init {
	self = [super init];
	if (self != nil) {
		[self load];
		availableTableColumnsIdentifiers = [[NSArray arrayWithObjects:@"game.icon",@"attributedName",@"gameType",@"map",@"ping",@"fullness",nil] retain];
	}
	return self;
}

#pragma mark Private Methods

- (void)load
{
	id defaults = [NSUserDefaults standardUserDefaults];
	NSData *archivedData = [defaults dataForKey:MColumnsForGames];
	if( archivedData == nil){
		columnsForGames = [[NSMutableDictionary alloc] init];
	}else{
		columnsForGames = [[NSKeyedUnarchiver unarchiveObjectWithData:archivedData] retain];
	}
}

- (void)save
{
	if(columnsForGames != nil){
		[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:columnsForGames]
												  forKey:MColumnsForGames];
	}
}

- (NSArray *)availableTableColumns
{
	static NSArray *availableTableColumns = nil;
	
	if(availableTableColumns == nil){
		NSDictionary *availableTableColumnsDict = [NSDictionary dictionaryWithObjects:
			[NSArray arrayWithObjects:@"Game",@"Server Name",@"MOD",@"Map",@"Ping",@"Players",nil]
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
				[tc setWidth:[serversTableView rowHeight]];
				[tc setSortDescriptorPrototype:[[[NSSortDescriptor alloc] initWithKey:@"game.name" ascending:YES] autorelease]];
				[tc setDataCell:[[[NSImageCell alloc] init] autorelease]];
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

#pragma mark Logic

- (void)awakeFromNib
{	
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
	
	MTableHeaderView *mthv = [[MTableHeaderView alloc] initWithFrame:[[serversTableView headerView] frame]];
	[mthv setColumnsMenu:columnsMenu];
	[serversTableView setHeaderView:[mthv autorelease]];
	[self selectedServerListChanged:nil];
}

- (void)selectedServerWillChange:(NSNotification *)aNotification
{
	id selectedServerList = [serverListsController selection];
	
	/*protect this code against valueMarkers*/
	if([selectedServerList valueForKey:@"name"] == NSNoSelectionMarker ||
	   [selectedServerList valueForKey:@"name"] == NSMultipleValuesMarker ||
	   [selectedServerList valueForKey:@"name"] == NSNotApplicableMarker)
		return;

	[columnsForGames setObject:[serversTableView sortDescriptors] 
						forKey:[NSString stringWithFormat:@"%@_SortDescriptors",[selectedServerList valueForKey:@"name"]]];
	[self save];
}

- (void)selectedServerListChanged:(NSNotification *)aNotification
{
	id selectedServerList = [serverListsController selection];
	NSMutableArray *gameColumns;
	
	/*protect this code against valueMarkers*/
	if([selectedServerList valueForKey:@"name"] == NSNoSelectionMarker ||
	   [selectedServerList valueForKey:@"name"] == NSMultipleValuesMarker ||
	   [selectedServerList valueForKey:@"name"] == NSNotApplicableMarker)
		return;
	
	if((gameColumns = [columnsForGames objectForKey:[selectedServerList valueForKey:@"name"]]) == nil){
		//this game doesn't have columns saved yet, let's create some new ones	
		gameColumns = [[self availableTableColumns] mutableCopy];
		if(![[selectedServerList valueForKey:@"name"] isEqualToString:@"Favorites"]){
			//only the Favorites list needs the game column
			[gameColumns removeObjectAtIndex:MGameColumn];
		}
		[columnsForGames setObject:gameColumns forKey:[selectedServerList valueForKey:@"name"]];
		[gameColumns release];
	}
	
	/* remove currentColumns */
	NSEnumerator *currentColumnsEnum = [[serversTableView tableColumns] objectEnumerator];
	NSTableColumn *tc;
	while(tc = [currentColumnsEnum nextObject]){
		[serversTableView removeTableColumn:tc];
	}
	/*add the new ones */
	NSEnumerator *columnsToAddEnum = [gameColumns objectEnumerator];
	while(tc = [columnsToAddEnum nextObject]){
		/*we need to rebind after unarchiving stuff*/
		[tc bind:@"value" 
		toObject:serversController 
	 withKeyPath:[NSString stringWithFormat:@"arrangedObjects.%@",[tc identifier]] 
		 options:nil];
		[serversTableView addTableColumn:tc];
	}
	[serversTableView setSortDescriptors:
		[columnsForGames objectForKey:
			[NSString stringWithFormat:@"%@_SortDescriptors",
				[selectedServerList valueForKey:@"name"]]]];
}

- (void)tableColumnsDidChange:(NSNotification *)aNotification
{
	id selectedServerList = [serverListsController selection];
	/*protect this code against valueMarkers*/
	if([selectedServerList valueForKey:@"name"] == NSNoSelectionMarker ||
	   [selectedServerList valueForKey:@"name"] == NSMultipleValuesMarker ||
	   [selectedServerList valueForKey:@"name"] == NSNotApplicableMarker)
		return;

	[columnsForGames setObject:[[[serversTableView tableColumns] mutableCopy] autorelease] forKey:[selectedServerList valueForKey:@"name"]];
	[self save];
}

- (IBAction)toggleColumn:(id)sender
{
	id selectedServerList = [serverListsController selection];
	NSTableColumn *tc;
	NSMutableArray *gameColumns = [columnsForGames objectForKey:[selectedServerList valueForKey:@"name"]];
	NSString *identifier = [availableTableColumnsIdentifiers objectAtIndex:[sender tag]];
	NSEnumerator *en;
	
	if([sender state] == NSOnState){
		en = [gameColumns objectEnumerator];
		while(tc = [en nextObject]){
			if([[tc identifier] isEqualToString:identifier]){
				[gameColumns removeObject:tc];
				[serversTableView removeTableColumn:tc];
				break;
			}
		}
		[sender setState:NSOffState];
	}
	else{
		en = [[self availableTableColumns] objectEnumerator];
		while(tc = [en nextObject]){
			if([[tc identifier] isEqualToString:identifier]){
				[gameColumns addObject:tc];
				/*we need to rebind after unarchiving stuff*/
				[tc bind:@"value" 
				toObject:serversController 
			 withKeyPath:[NSString stringWithFormat:@"arrangedObjects.%@",[tc identifier]] 
				 options:nil];				
				[serversTableView addTableColumn:tc];
				break;
			}
		}
		[sender setState:NSOnState];
	}
	[self save];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	NSString *identifier = [availableTableColumnsIdentifiers objectAtIndex:[menuItem tag]];
	if([serversTableView tableColumnWithIdentifier:identifier] != nil){
		[menuItem setState:NSOnState];
	}
	else{
		[menuItem setState:NSOffState];
	}
	return YES;
}

@end
