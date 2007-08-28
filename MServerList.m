//
//  MServerList.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/11/11.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import "MGenericGame.h"
#import "MServerList.h"
#import "MQuery.h"
#import "MServer.h"
#import "MProgressDelegate.h"
#import "MPlayer.h"
#import "MRules.h"

@implementation MServerList

+ (void)initialize
{
	[self setKeys:[NSArray arrayWithObjects:@"name", @"icon", @"progressDelegate", nil] 
triggerChangeNotificationsForDependentKey:@"infoDict"];
}

+ (id)createServerListForGame:(MGenericGame *)theGame inContext:(NSManagedObjectContext *)context
{
	MServerList *sl =  [NSEntityDescription insertNewObjectForEntityForName:@"ServerList"
													 inManagedObjectContext:context];
	
	[sl setGameServerType:[theGame serverTypeString]];
	return sl;
}

- (void) dealloc {
	[progressDelegate release];
	[currentQuery release];
	[super dealloc];
}

- (void)insertServers:(NSArray *)servers
{
	//to be executed in the main thread!
//	NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
//	[context processPendingChanges];
//	[[context undoManager] disableUndoRegistration];
	
//	[context refreshObject:self mergeChanges:YES];
	//NSEnumerator *enumerator = [objectIDs objectEnumerator];
//	NSManagedObjectID *objID;
//	id obj;
	
//	// this is for trying to speed up this loop
//	SEL nextObj_sel = @selector(nextObject);
//	SEL objWithID_sel = @selector(objectWithID:);
//	SEL refreshObj_sel = @selector(refreshObject:mergeChanges:);
//	IMP nextObj_imp = [enumerator methodForSelector:nextObj_sel];
//	IMP objWithID_imp = [context methodForSelector:objWithID_sel];
//	IMP refreshObj_imp =[context methodForSelector:refreshObj_sel];
//	
//	while(objID = nextObj_imp(enumerator, nextObj_sel)){
//		obj = objWithID_imp(context, objWithID_sel, objID);
//		refreshObj_imp(context, refreshObj_sel, obj, NO);
//	}
	
//	NSFetchRequest *fr = [[NSFetchRequest alloc] init];
//	[fr setEntity:[NSEntityDescription entityForName:@"Server" inManagedObjectContext:context]];
//	[fr setPredicate:[NSPredicate predicateWithFormat:@"" argumentArray:
//	[context setStalenessInterval:10.0];
//	[context refreshObject:self mergeChanges:YES];
//	NSLog(@"%d", [[[self valueForKey:@"servers"] valueForKey:@"name"] count]);
//	[context processPendingChanges];
//	[[context undoManager] enableUndoRegistration];
//	MServerList *mainThreadSL = [context objectWithID:[self objectID]];
//	[context refreshObject:mainThreadSL mergeChanges:YES];
//	[mainThreadSL setNeedsReload:YES];
//	[[NSNotificationCenter defaultCenter] postNotificationName:MServerListNeedsReloadNotification object:mainThreadSL];
	
	NSManagedObjectContext *context = [self managedObjectContext];
	[context processPendingChanges];
	[[context undoManager] disableUndoRegistration];
	MServer *currentServer;
	NSMutableDictionary *currentServerDict;
	NSEnumerator *serverEnum = [servers objectEnumerator];
	NSMutableSet *serversToAdd = [NSMutableSet new];
	
	while(currentServerDict = [serverEnum nextObject]){
		NSMutableArray *playersDicts = [currentServerDict valueForKey:@"players"];
		NSEnumerator *playerEnum = [playersDicts objectEnumerator];
		NSMutableSet *players = [NSMutableSet new];
		MPlayer *currentPlayer;
		MRules *currentRules;
		NSMutableDictionary *currentPlayerDict;
		// change the players key to NSManagedObjects
		while(currentPlayerDict = [playerEnum nextObject]){
			currentPlayer = [MPlayer createPlayerInContext:context];
			[currentPlayer setValuesForKeysWithDictionary:currentPlayerDict];
			[players addObject:currentPlayer];
		}
		[currentServerDict setObject:players forKey:@"players"];
		[players release]; players = nil;
		// change the rules key to NSManagedObject
		currentRules = [MRules createRulesInContext:context];
		
		[currentRules setRules:[currentServerDict valueForKey:@"rules"]];
		[currentServerDict setObject:currentRules forKey:@"rules"];
		
		// get the server
		currentServer = [MServer createServerWithAddress:[currentServerDict valueForKey:@"address"] inContext:context];
		if([[currentServer objectID] isTemporaryID]){
			[currentServer setValuesForKeysWithDictionary:currentServerDict];
		
		}else{
			// delete current players and rules
			MRules *rulesToDelete = [currentServer valueForKey:@"rules"];
			[currentServer setValue:nil forKey:@"rules"];
			NSSet *playersToDelete = [currentServer mutableSetValueForKey:@"players"];
			[currentServer setValue:nil forKey:@"players"];
			[context deleteObject:rulesToDelete];
			NSEnumerator *ptdEnum = [[playersToDelete allObjects] objectEnumerator];
			MPlayer *p;
			while(p = [ptdEnum nextObject]){
				[context deleteObject:p];
			}
			
			[currentServer setValuesForKeysWithDictionary:currentServerDict];
		}
		[serversToAdd addObject:currentServer];
	}
	
	[self addServers:serversToAdd];
	[serversToAdd release];
	[context processPendingChanges];
	[[context undoManager] enableUndoRegistration];
}

#pragma mark Accessors

- (NSString *)gameServerType 
{
	NSString * tmpValue;
	[self willAccessValueForKey: @"gameServerType"];
	tmpValue = [self primitiveValueForKey: @"gameServerType"];
	[self didAccessValueForKey: @"gameServerType"];
	
    return tmpValue;
}

- (void)setGameServerType:(NSString *)value 
{
	
	[self willChangeValueForKey: @"gameServerType"];
	[self setPrimitiveValue: [value uppercaseString] forKey: @"gameServerType"];
	[self didChangeValueForKey: @"gameServerType"];
	
}


- (MGenericGame *)game 
{
	MGenericGame *tmpValue;
	[self willAccessValueForKey: @"game"];
	tmpValue = [self primitiveValueForKey: @"game"];
	[self didAccessValueForKey: @"game"];
	if(tmpValue == nil) {
		[self setPrimitiveValue:tmpValue forKey:@"game"];
		NSString *gameClassName = [MGenericGame gameClassNameWithServerTypeString:[self gameServerType]];
		if(gameClassName != nil){
			Class gameClass = objc_getClass([gameClassName UTF8String]);
			tmpValue = (gameClass != nil) ? [gameClass new] : [MGenericGame new];
		}
		[self setPrimitiveValue:tmpValue forKey:@"game"];		
	}
	
    return tmpValue;
}

- (void)setGame:(MGenericGame *)value 
{
	
	[self willChangeValueForKey: @"game"];
	[self setPrimitiveValue: value forKey: @"game"];
	[self didChangeValueForKey: @"game"];
	
}


#pragma mark Temporary attributes

- (BOOL)busyFlag 
{	
	BOOL tmp;
	[self willAccessValueForKey: @"busyFlag"];
	tmp = busyFlag;
	[self didAccessValueForKey: @"busyFlag"];
	return tmp;
}

- (void)setBusyFlag:(BOOL)value 
{
	[self willChangeValueForKey: @"busyFlag"];
	busyFlag = value;
	[self didChangeValueForKey: @"busyFlag"];
}

- (BOOL)needsReload {
    return needsReload;
}

- (void)setNeedsReload:(BOOL)value {
    if (needsReload != value) {
        needsReload = value;
    }
}

- (MProgressDelegate *)progressDelegate 
{
	MProgressDelegate *pd;
	[self willAccessValueForKey: @"progressDelegate"];
    pd = progressDelegate;
	[self didAccessValueForKey: @"progressDelegate"];
	return pd;
}

- (void)setProgressDelegate:(MProgressDelegate *)value 
{
	if(value != progressDelegate){
		[progressDelegate release];
		[self willChangeValueForKey: @"progressDelegate"];
		progressDelegate = [value retain];
		[self didChangeValueForKey: @"progressDelegate"];
	}
}

#pragma mark Derived attributes

- (NSString *)name
{
	NSString * tmpValue;
	
	[self willAccessValueForKey: @"name"];
	tmpValue = [[self game] name];
	[self didAccessValueForKey: @"name"];
	
    return tmpValue;
	
}

- (void)setName:(NSString *)value
{
	
	[self willChangeValueForKey: @"name"];
	//do nothing game.name is read-only
	[self didChangeValueForKey: @"name"];
	
}

- (NSImage *)icon
{
	NSImage * tmpValue;
	
	[self willAccessValueForKey: @"icon"];
	tmpValue = [[self game] icon];
	[self didAccessValueForKey: @"icon"];
	
	return tmpValue;
}

- (void)setIcon:(NSImage *)value
{
	
	[self willChangeValueForKey: @"icon"];
	//do nothing game.icon is read-only
	[self didChangeValueForKey: @"icon"];
	
}

- (NSDictionary *)infoDict
{
	return [self dictionaryWithValuesForKeys:
		[NSArray arrayWithObjects:@"name", @"icon", @"progressDelegate", nil]];
}

- (void)setInfoDict:(NSDictionary *)infoDict
{
	[self setValuesForKeysWithDictionary:infoDict];
}

#pragma mark Modifiers

- (void)addServersObject:(MServer *)value 
{   
	
	NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
	
	[self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation 
				   usingObjects:changedObjects];
	[[self primitiveValueForKey: @"servers"] addObject: value];
	[self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation 
				  usingObjects:changedObjects];
	[changedObjects release];
	
}

- (void)removeServersObject:(MServer *)value 
{
	
	NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
	
	[self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation 
				   usingObjects:changedObjects];
	[[self primitiveValueForKey: @"servers"] removeObject: value];
	[self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation 
				  usingObjects:changedObjects];
	[changedObjects release];
	
}


- (void)addServers:(NSSet *)inServers
{	
	
	NSEnumerator *server_enum = [inServers objectEnumerator];
	MServer *server;
	
	[self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation 
				   usingObjects:inServers];
	while((server = [server_enum nextObject])){
		[[self primitiveValueForKey: @"servers"] addObject: server];		
	}
	[self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation 
				  usingObjects:inServers];
	
}

- (void)removeServers:(NSSet *)inServers
{
	
	NSEnumerator *server_enum = [[inServers allObjects] objectEnumerator];
	MServer *server;
	[self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation 
				   usingObjects:inServers];
	while((server = [server_enum nextObject])){
		[[self primitiveValueForKey: @"servers"] removeObject: server];
	}
	[self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation 
				  usingObjects:inServers];
	
}

-(BOOL)reload
{
	//if we are busy return
	if([self busyFlag])
		return NO;
	[self setBusyFlag:YES];
	
	MProgressDelegate *pd = [[MProgressDelegate new] autorelease];
	[self setProgressDelegate:pd];
	currentQuery = [MQuery new];
	
	[currentQuery reloadServerList:self];
	return YES;
}

-(BOOL)refreshServers:(NSArray *)inServers
{
	if(inServers == nil){ // refresh the entire list
		inServers = [self valueForKey:@"servers"];
	}
	
	if([self busyFlag] || [inServers count] == 0)
		return NO;
	[self setBusyFlag:YES];
		
	MProgressDelegate *pd = [[MProgressDelegate new] autorelease];
	[self setProgressDelegate:pd];
	currentQuery = [MQuery new];
	
	[currentQuery refreshGameServers:inServers inServerList:self];
	return YES;

}


- (void)terminateQuery
{
	[currentQuery terminate];
}

- (void)queryTerminated
{
	[self setProgressDelegate:nil];
	[self setBusyFlag:NO];
	[currentQuery release]; currentQuery = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:MQueryTerminatedNotification object:self];
}

@end
