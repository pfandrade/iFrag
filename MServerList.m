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

@dynamic smartLists;
@dynamic servers;

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

- (void)mergeChanges:(NSNotification *)saveChangesNotification
{
	NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
	[context processPendingChanges];
	[[context undoManager] disableUndoRegistration];
	[context mergeChangesFromContextDidSaveNotification:saveChangesNotification];
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

- (BOOL)isLeaf
{
	NSSet *ssl = [self smartLists];
	if(ssl == nil || [ssl count] == 0){
		return YES;
	}
	return NO;
}
@end

#if 0
/*
 *
 * You do not need any of these.  
 * These are templates for writing custom functions that override the default CoreData functionality.
 * You should delete all the methods that you do not customize.
 * Optimized versions will be provided dynamically by the framework.
 *
 *
 */


// coalesce these into one @interface MServerList (CoreDataGeneratedPrimitiveAccessors) section
@interface MServerList (CoreDataGeneratedPrimitiveAccessors)

- (NSString *)primitiveGameServerType;
- (void)setPrimitiveGameServerType:(NSString *)value;

- (UNKNOWN_TYPE)primitiveGame;
- (void)setPrimitiveGame:(UNKNOWN_TYPE)value;

- (NSMutableSet*)primitiveSmartLists;
- (void)setPrimitiveSmartLists:(NSMutableSet*)value;

- (NSMutableSet*)primitiveServers;
- (void)setPrimitiveServers:(NSMutableSet*)value;

@end

- (NSString *)gameServerType 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"gameServerType"];
    tmpValue = [self primitiveGameServerType];
    [self didAccessValueForKey:@"gameServerType"];
    
    return tmpValue;
}

- (void)setGameServerType:(NSString *)value 
{
    [self willChangeValueForKey:@"gameServerType"];
    [self setPrimitiveGameServerType:value];
    [self didChangeValueForKey:@"gameServerType"];
}

- (BOOL)validateGameServerType:(id *)valueRef error:(NSError **)outError 
{
    // Insert custom validation logic here.
    return YES;
}

- (UNKNOWN_TYPE)game 
{
    UNKNOWN_TYPE tmpValue;
    
    [self willAccessValueForKey:@"game"];
    tmpValue = [self primitiveGame];
    [self didAccessValueForKey:@"game"];
    
    return tmpValue;
}

- (void)setGame:(UNKNOWN_TYPE)value 
{
    [self willChangeValueForKey:@"game"];
    [self setPrimitiveGame:value];
    [self didChangeValueForKey:@"game"];
}

- (BOOL)validateGame:(id *)valueRef error:(NSError **)outError 
{
    // Insert custom validation logic here.
    return YES;
}


- (void)addSmartListsObject:(NSManagedObject *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"smartLists" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveSmartLists] addObject:value];
    [self didChangeValueForKey:@"smartLists" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removeSmartListsObject:(NSManagedObject *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"smartLists" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveSmartLists] removeObject:value];
    [self didChangeValueForKey:@"smartLists" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)addSmartLists:(NSSet *)value 
{    
    [self willChangeValueForKey:@"smartLists" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveSmartLists] unionSet:value];
    [self didChangeValueForKey:@"smartLists" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeSmartLists:(NSSet *)value 
{
    [self willChangeValueForKey:@"smartLists" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveSmartLists] minusSet:value];
    [self didChangeValueForKey:@"smartLists" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addServersObject:(MServer *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveServers] addObject:value];
    [self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removeServersObject:(MServer *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveServers] removeObject:value];
    [self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)addServers:(NSSet *)value 
{    
    [self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveServers] unionSet:value];
    [self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeServers:(NSSet *)value 
{
    [self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveServers] minusSet:value];
    [self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

#endif


