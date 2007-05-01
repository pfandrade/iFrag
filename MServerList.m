//
//  MServerList.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/11/11.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import "MServerList.h"
#import "MQuery.h"
#import "MServer.h"

@implementation MServerList

+ (void)initialize
{
	[self setKeys:[NSArray arrayWithObjects:@"servers",nil] triggerChangeNotificationsForDependentKey:@"serverArray"];
}

+ (id)createServerListForGame:(MGenericGame *)theGame
{
	MServerList *sl =  [NSEntityDescription insertNewObjectForEntityForName:@"ServerList"
													 inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
	
	[sl setGameServerType:[theGame serverTypeString]];
	return sl;
}

- (void)awakeFromFetch {
	[self setPrimitiveValue:[NSNumber numberWithBool:NO] forKey:@"busyFlag"];
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
		NSString *gameClassName = [MGenericGame gameClassNameWithServerTypeString:[self gameServerType]];
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

- (BOOL)trySetBusyFlag
{
	NSManagedObjectContext *context = [self managedObjectContext];
	
	if(![context tryLock])//if we can't lock we're busy
		return NO;
	//we have the lock
	
	if([[self busyFlag] boolValue]){
		[context unlock];
		return NO;
	}
	[self setBusyFlag:[NSNumber numberWithBool:YES]];
	[context unlock];
	return YES;
}

- (MServer *)serverWithAddress:(NSString *)address
{
	NSManagedObjectContext *context = [self managedObjectContext];
	NSManagedObjectModel *model = [[self entity] managedObjectModel];

	NSError *error = nil;
	NSDictionary *substitutionDictionary = [NSDictionary dictionaryWithObjectsAndKeys: address, @"ADDR", nil];
	NSFetchRequest *fetchRequest =
		[model fetchRequestFromTemplateWithName:@"serverWithAddress"
						  substitutionVariables:substitutionDictionary];
	NSEntityDescription *ed = [NSEntityDescription entityForName:@"Server" inManagedObjectContext:context];
	[fetchRequest setEntity:ed];
	
	[context lock];
	NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
	[context unlock];
	if ([results count] == 0){
		return nil;
	}
	
	return [results objectAtIndex:0];
}

- (NSString *)name
{
	return [[self game] name];
}

- (NSImage *)icon
{
	return [[self game] icon];
}


#pragma mark Modifiers

- (void)addServersObject:(MServer *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
	NSManagedObjectContext *context = [self managedObjectContext];
	MServer *existingServer = [self serverWithAddress:[value address]];
	//test to see if they are the same
	if([[existingServer objectID] isEqual:[value objectID]])
		return;
    [context lock];
	if(existingServer != nil){
		[context deleteObject:existingServer];
	}
    [self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey: @"servers"] addObject: value];
    [self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [context unlock];
	NSError *error = nil;
	[context save:&error];
	NSLog(@"Error %@",error);
    [changedObjects release];
}

- (void)removeServersObject:(MServer *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    NSManagedObjectContext *context = [self managedObjectContext];
	
	[context lock];
    [self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey: @"servers"] removeObject: value];
    [self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [context unlock];
	NSError *error = nil;
	[context save:&error];
	NSLog(@"Error %@",error);
    [changedObjects release];
}


- (void)addServers:(NSSet *)inServers
{	
	NSManagedObjectContext *context = [self managedObjectContext];
	
	NSEnumerator *server_enum = [inServers objectEnumerator];
	MServer *server, *existingServer;
	
	[context lock];
    [self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:inServers];
	while((server = [server_enum nextObject])){
		existingServer = [self serverWithAddress:[server address]];
		if([[existingServer objectID] isEqual:[server objectID]])
			continue;
		if(existingServer != nil){
			[context deleteObject:existingServer];
		}		
		[[self primitiveValueForKey: @"servers"] addObject: server];		
	}
	[self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueUnionSetMutation usingObjects:inServers];
	[context unlock];
	
	NSError *error = nil;
	[context save:&error];
	NSLog(@"Error %@",error);
}

- (void)removeServers:(NSSet *)inServers
{
    NSManagedObjectContext *context = [self managedObjectContext];
	
	NSEnumerator *server_enum = [[inServers allObjects] objectEnumerator];
	MServer *server;
	[context lock];
    [self willChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:inServers];
	while((server = [server_enum nextObject])){
		[[self primitiveValueForKey: @"servers"] removeObject: server];
	}
    [self didChangeValueForKey:@"servers" withSetMutation:NSKeyValueMinusSetMutation usingObjects:inServers];
    [context unlock];
	NSError *error = nil;
	[context save:&error];
	NSLog(@"Error %@",error);
}

-(void)reloadWithProgressDelegate:(id)delegate
{
	if(![self trySetBusyFlag])
		return;
	MQuery *q = [[MQuery new] autorelease];
	[q setProgressDelegate:delegate];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(queryDidTerminate:)
												 name:MQueryDidTerminateNotification 
											   object:q];
	[NSThread detachNewThreadSelector:@selector(reloadServerList:) toTarget:q withObject:self];
}

-(void)refreshServers:(NSArray *)inServers withProgressDelegate:(id)delegate
{
	if(![self trySetBusyFlag])
		return;
	MQuery *q = [[MQuery new] autorelease];
	[q setProgressDelegate:delegate];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(queryDidTerminate:)
												 name:MQueryDidTerminateNotification 
											   object:q];
	[NSThread detachNewThreadSelector:@selector(refreshGameServers:) toTarget:q withObject:inServers];
}

- (void)queryDidTerminate:(NSNotification *)n
{
    NSManagedObjectContext *context = [self managedObjectContext];
	[context lock];
	[self setBusyFlag:[NSNumber numberWithBool:NO]];
	[context unlock];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MQueryDidTerminateNotification object:nil];
}

@end
