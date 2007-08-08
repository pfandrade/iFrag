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

- (void)syncObjectsFromStore:(NSArray *)objectIDs
{
	//to be executed in the main thread!
	NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
	[context processPendingChanges];
	[[context undoManager] disableUndoRegistration];
	
	NSEnumerator *enumerator = [objectIDs objectEnumerator];
	NSManagedObjectID *objID;
	id obj;
	
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

-(void)reload
{
	//if we are busy return
	if([self busyFlag])
		return;
	[self setBusyFlag:YES];
	
	MProgressDelegate *pd = [[MProgressDelegate new] autorelease];
	[self setProgressDelegate:pd];
	currentQuery = [MQuery new];
	
	[currentQuery reloadServerList:self];
}

-(void)refreshServers:(NSArray *)inServers
{
	if(inServers == nil){ // refresh the entire list
		inServers = [self valueForKey:@"servers"];
	}
	
	if([self busyFlag] || [inServers count] == 0)
		return;
	[self setBusyFlag:YES];
		
	MProgressDelegate *pd = [[MProgressDelegate new] autorelease];
	[self setProgressDelegate:pd];
	currentQuery = [MQuery new];
	
	[currentQuery refreshGameServers:inServers inServerList:self];

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
}

@end
