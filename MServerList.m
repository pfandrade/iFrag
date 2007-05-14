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

@implementation MServerList

+ (void)initialize
{
	[self setKeys:[NSArray arrayWithObjects:@"name", @"icon", @"progressDelegate", nil] triggerChangeNotificationsForDependentKey:@"infoDict"];
}

+ (id)createServerListForGame:(MGenericGame *)theGame inContext:(NSManagedObjectContext *)context
{
	MServerList *sl =  [NSEntityDescription insertNewObjectForEntityForName:@"ServerList"
													 inManagedObjectContext:context];
	
	[sl setGameServerType:[theGame serverTypeString]];
	return sl;
}

- (void)syncObjectsFromStore:(NSSet *)objectIDs
{
	//to be executed in the main thread!
	NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
	[context processPendingChanges];
	[[context undoManager] disableUndoRegistration];
	
	NSEnumerator *enumerator = [objectIDs objectEnumerator];
	NSManagedObjectID *objID;
	id obj;
	
	while(objID = [enumerator nextObject]){
		obj = [context objectWithID:objID];
		[context refreshObject:obj mergeChanges:NO];
		
	}
	[context processPendingChanges];
	[[context undoManager] enableUndoRegistration];
}

- (void)refreshServersFromStore:(NSArray *)objectIDs
{
	//to be executed in the main thread!
	NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
	[context processPendingChanges];
	[[context undoManager] disableUndoRegistration];
	
	MServerList *mainThreadServerList = (MServerList *)[context objectWithID:[self objectID]];
	NSEnumerator *enumerator = [objectIDs objectEnumerator];
	NSManagedObjectID *objID;
	MServer *server;

	while(objID = [enumerator nextObject]){
		server = (MServer *)[context objectWithID:objID];
		[context refreshObject:server mergeChanges:YES];
		
	}
	
	[context refreshObject:mainThreadServerList mergeChanges:NO];
	[context processPendingChanges];
	[[context undoManager] enableUndoRegistration];
}

- (void)awakeFromFetch {
	[self setPrimitiveValue:[NSNumber numberWithBool:NO] forKey:@"busyFlag"];
}

- (void)willSave
{
    MProgressDelegate *progressDelegate = [self primitiveValueForKey:@"progressDelegate"];
    if (progressDelegate != nil) {
        [self setPrimitiveValue:[NSKeyedArchiver archivedDataWithRootObject: progressDelegate]
						 forKey:@"serializedProgressDelegate"];
    }
    else {
        [self setPrimitiveValue:nil forKey:@"serializedProgressDelegate"];
    }
    [super willSave];
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

- (BOOL)validateGameServerType: (id *)valueRef error:(NSError **)outError 
{
    // Insert custom validation logic here.
    return YES;
}

- (MGenericGame *)game 
{
	MGenericGame *tmpValue;
	[self willAccessValueForKey: @"game"];
	tmpValue = [self primitiveValueForKey: @"game"];
	[self didAccessValueForKey: @"game"];
	if(tmpValue == nil) {
		NSString *gameType = [self gameServerType];
		NSString *gameClassName = [MGenericGame gameClassNameWithServerTypeString:gameType];
		@try {
			Class gameClass = objc_getClass([gameClassName UTF8String]);
			tmpValue = [gameClass new];
		}
		@catch (NSException * e) {
			tmpValue = [MGenericGame new];
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

//should use trySetBusyFlag
- (NSNumber *)busyFlag 
{
	NSNumber * tmpValue;
	
	[self willAccessValueForKey: @"busyFlag"];
	tmpValue = [self primitiveValueForKey: @"busyFlag"];
	[self didAccessValueForKey: @"busyFlag"];
	
    return tmpValue;
}

//should use trySetBusyFlag
- (void)setBusyFlag:(NSNumber *)value 
{
	
	[self willChangeValueForKey: @"busyFlag"];
	[self setPrimitiveValue: value forKey: @"busyFlag"];
	[self didChangeValueForKey: @"busyFlag"];
	
}

- (NSData *)serializedProgressDelegate 
{
	NSData * tmpValue;
	
	[self willAccessValueForKey: @"serializedProgressDelegate"];
	tmpValue = [self primitiveValueForKey: @"serializedProgressDelegate"];
	[self didAccessValueForKey: @"serializedProgressDelegate"];
	
	
    return tmpValue;
}

- (void)setSerializedProgressDelegate:(NSData *)value 
{
	
	[self willChangeValueForKey: @"serializedProgressDelegate"];
	[self setPrimitiveValue: value forKey: @"serializedProgressDelegate"];
	[self didChangeValueForKey: @"serializedProgressDelegate"];
	
}

- (MProgressDelegate *)progressDelegate 
{
	MProgressDelegate *tmpValue;
	
	[self willAccessValueForKey: @"progressDelegate"];
	tmpValue = [self primitiveValueForKey: @"progressDelegate"];
	[self didAccessValueForKey: @"progressDelegate"];
	if (tmpValue == nil) {
		NSData *delegateData = [self valueForKey:@"serializedProgressDelegate"];
		if (delegateData != nil) {
			tmpValue = [NSKeyedUnarchiver unarchiveObjectWithData:delegateData];
			[self setPrimitiveValue:tmpValue forKey:@"progressDelegate"];
		}
	}
	
    return tmpValue;
}

- (void)setProgressDelegate:(MProgressDelegate *)value 
{
	
	[self willChangeValueForKey: @"progressDelegate"];
	[self setPrimitiveValue: value forKey: @"progressDelegate"];
	[self didChangeValueForKey: @"progressDelegate"];
	
}

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

- (MServer *)serverWithAddress:(NSString *)address
{
	NSManagedObjectContext *context = [self managedObjectContext];
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:[NSEntityDescription entityForName:@"Server"
								   inManagedObjectContext:context]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"inServerList = %@ AND address LIKE %@", self, address];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *results = [context executeFetchRequest:request error:&error];
	if ([results count] == 0){
		return nil;
	}
	
	return [results objectAtIndex:0];
}

- (NSDictionary *)infoDict
{
	return [self dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"name", @"icon", @"progressDelegate", nil]];
}

- (void)setInfoDict:(NSDictionary *)infoDict
{
	[self setValuesForKeysWithDictionary:infoDict];
}

#pragma mark Modifiers

- (void)addServersObject:(MServer *)value 
{   
	
	NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
	
	MServer *existingServer = [self serverWithAddress:[value address]];
	//test to see if they are the same
	if([[existingServer objectID] isEqual:[value objectID]])
		return;
	
	if(existingServer != nil){
		[[self managedObjectContext] deleteObject:existingServer];
	}
	[self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
	[[self primitiveValueForKey: @"servers"] addObject: value];
	[self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
	[changedObjects release];
	
}

- (void)removeServersObject:(MServer *)value 
{
	
	NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
	
	[self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
	[[self primitiveValueForKey: @"servers"] removeObject: value];
	[self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
	[changedObjects release];
	
}


- (void)addServers:(NSSet *)inServers
{	
	
	NSEnumerator *server_enum = [inServers objectEnumerator];
	MServer *server, *existingServer;
	
	[self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:inServers];
	while((server = [server_enum nextObject])){
		existingServer = [self serverWithAddress:[server address]];
		if([[existingServer objectID] isEqual:[server objectID]])
			continue;
		if(existingServer != nil){
			[[self managedObjectContext] deleteObject:existingServer];
		}		
		[[self primitiveValueForKey: @"servers"] addObject: server];		
	}
	[self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:inServers];
	
}

- (void)removeServers:(NSSet *)inServers
{
	
	NSEnumerator *server_enum = [[inServers allObjects] objectEnumerator];
	MServer *server;
	[self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:inServers];
	while((server = [server_enum nextObject])){
		[[self primitiveValueForKey: @"servers"] removeObject: server];
	}
	[self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:inServers];
	
}

-(void)reload
{
	//if we are busy return
	if([[self busyFlag] boolValue])
		return;
	[self setBusyFlag:[NSNumber numberWithBool:YES]];
	
	MProgressDelegate *pd = [[MProgressDelegate new] autorelease];
	[self setProgressDelegate:pd];
	MQuery *q = [[MQuery new] autorelease];
	[q setProgressDelegate:pd];
	
	NSPort *port = [NSPort port];
	[port setDelegate:self];
	[[NSRunLoop currentRunLoop] addPort:port forMode:NSDefaultRunLoopMode];
	
	NSArray *threadArgs = [NSArray arrayWithObjects:[self objectID], port, nil];
	[NSThread detachNewThreadSelector:@selector(reloadServerList:) toTarget:q withObject:threadArgs];
}

-(void)refreshServers:(NSArray *)inServers
{
	if([[self busyFlag] boolValue])
		return;
	[self setBusyFlag:[NSNumber numberWithBool:YES]];
	
	if(inServers == nil){ // refresh the entire list
		inServers = [self valueForKey:@"servers"];
	}
	
	MProgressDelegate *pd = [[MProgressDelegate new] autorelease];
	[self setProgressDelegate:pd];
	MQuery *q = [[MQuery new] autorelease];
	[q setProgressDelegate:pd];
	
	
	NSPort *port = [NSPort port];
	[port setDelegate:self];
	[[NSRunLoop currentRunLoop] addPort:port forMode:NSDefaultRunLoopMode];
	
	//NOTA: aqui vai o inServers como argumento, em vez de [inServers valueForKey:@"objectID"]
	//ou um array com os address e outro com serverType para evitar iterar sobre o array duas vezes.
	//O inServers so vai ser usado para leitura!
	NSArray *threadArgs = [NSArray arrayWithObjects:[self objectID], inServers, port, nil];
	[NSThread detachNewThreadSelector:@selector(refreshGameServers:) toTarget:q withObject:threadArgs];
}

- (void)handlePortMessage:(NSPortMessage *)portMessage
{	
	unsigned int messageID = [portMessage msgid];
	if(messageID == kQueryTerminated){
		[self setBusyFlag:[NSNumber numberWithBool:NO]];
		[[self managedObjectContext] refreshObject:self mergeChanges:NO];
		//remove port from the runLoop
		[[NSRunLoop currentRunLoop] removePort:[portMessage receivePort] forMode:NSDefaultRunLoopMode];
		//TODO: Por aqui um save?
		return;
	}
}

@end
