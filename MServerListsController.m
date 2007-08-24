//
//  MServerListsController.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/05/01.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MServerListsController.h"
#import "MGenericGame.h"
#import "MServerList.h"
#import "MServersController.h"

extern NSString *iFragPBoardType;

@interface NSObject (private)
- (id)observedObject;
@end


@implementation MServerListsController

- (void)awakeFromNib
{
	[self refreshInstalledGames];
	NSEnumerator *iter = [[self arrangedObjects] objectEnumerator];
	id sl;
	while(sl = [iter nextObject]){
		[sl addObserver:self
			 forKeyPath:@"servers" 
				options:NSKeyValueObservingOptionOld
				context:NULL];
	}
	[serverListsOutlineView registerForDraggedTypes:[NSArray arrayWithObject:iFragPBoardType]];
}

- (void)refreshInstalledGames
{
	NSArray *serverLists = [self arrangedObjects];
	if([serverLists count] == 0){ //Favorites is always installed, so this means it hasn't been initialized
		NSError *error;
		[self fetchWithRequest:nil merge:NO error:&error];
		serverLists = [self arrangedObjects];
	}
	NSArray *installedGames = [MGenericGame installedGames];
	
	NSArray *installedGamesStrings	= [installedGames valueForKey:@"serverTypeString"];
	NSArray *serverListsStrings		= [serverLists valueForKey:@"gameServerType"];
	NSString *gameString;
	int i;
	for( i = 0 ; i < [installedGamesStrings count]; i++){
		gameString = [installedGamesStrings objectAtIndex:i];
		
		if(![serverListsStrings containsObject:[gameString uppercaseString]]){ //if we don't have this game yet
			[self addObject:[MServerList createServerListForGame:[installedGames objectAtIndex:i] inContext:[self managedObjectContext]]];
		}
	}
//TODO: retirar os jogos que ja nao estao instalados	
//	NSEnumerator *existing_SLs = [[serverLists allValues] objectEnumerator];
//	NSString *errorDesc;
//	NSString *recoveryDesc;
//	NSArray *recoveryOpts;
//	NSDictionary *userInfo;
//	
//	while(current_sl = [existing_SLs nextObject]){
//		if(![inst_games containsObject:[current_sl game]]){
//			// Let's try and ask what to do
//			errorDesc = [NSString stringWithFormat:@"%@ appears to no longer be installed.", [current_sl name]];
//			recoveryDesc = @"It will be removed from the list.";
//			recoveryOpts = [NSArray arrayWithObjects:@"OK", nil];
//			userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:errorDesc,recoveryDesc,recoveryOpts,nil]
//												   forKeys:[NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedRecoverySuggestionErrorKey,NSLocalizedRecoveryOptionsErrorKey,nil]];
//			[delegate willRemoveGame:[current_sl game] reason:[NSError errorWithDomain:MIFragErrorDomain code:MEGNLI userInfo:userInfo]];
//			[self uninstallServerListForGame:[current_sl game]];
//		}
//	}
	
	//save changes
	NSError *error = nil;
	[[self managedObjectContext] save:&error];
	if(error != nil)
		NSLog(@"Save Error :%@", error);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	// test to see if a server was removed, and if so see if it should be deleted
	if([keyPath isEqualToString:@"servers"]){
		if([[change objectForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeRemoval){
			//if the servers isn't in any serverList, remove it
			NSArray *removedServers = [change objectForKey:NSKeyValueChangeOldKey];
			NSEnumerator *serverEnum = [removedServers objectEnumerator];
			id server;
			
			while(server = [serverEnum nextObject]){
				//server no longer is contained in any serverlist
				if([[server valueForKey:@"inServerLists"] count] == 0){
					[moc deleteObject:server];
				}
			}
		}
	}

	// always save chages
	NSError *error = nil;
	[moc save:&error];
	if(error != nil){
		NSLog(@"%@", error);
	}
}

#pragma mark -
#pragma mark NSOutlineView Hacks for Drag and Drop

- (id)outlineView:(NSOutlineView *)olv child:(int)index ofItem:(id)item 
{
    return nil;
}
- (BOOL)outlineView:(NSOutlineView *)olv isItemExpandable:(id)item 
{
    return NO;
}
- (int)outlineView:(NSOutlineView *)olv numberOfChildrenOfItem:(id)item 
{
    return 0;
}
- (id)outlineView:(NSOutlineView *)olv objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item 
{
	return nil;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView 
				  validateDrop:(id <NSDraggingInfo>)info 
				  proposedItem:(id)item 
			proposedChildIndex:(int)childIndex
{
	id targetNode = [item observedObject];
	BOOL isOnDropTypeProposal = childIndex==NSOutlineViewDropOnItemIndex;
	BOOL targetNodeIsValid = NO;
	
	if(targetNode == nil) {
		// we dont accept drop on the root
		return NSDragOperationNone;
	}
	
	if(isOnDropTypeProposal) {
		targetNodeIsValid = [serversController canPasteIntoServerList:targetNode fromPasteboard:[info draggingPasteboard]];
	}
		
	return targetNodeIsValid ? (NSDragOperationCopy | NSDragOperationMove) : NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView*)olv 
		 acceptDrop:(id <NSDraggingInfo>)info 
			   item:(id)targetItem 
		 childIndex:(int)childIndex 
{
    id targetNode = [targetItem observedObject];
	[serversController pasteIntoServerList:targetNode fromPasteboard:[info draggingPasteboard]];
    return YES;
}



//- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
//{
//	return NO;
//}

@end
