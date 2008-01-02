//
//  MSmartServerList.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/11/13.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MSmartServerList.h"
#import "MGenericGame.h"

static NSImage *icon;

@implementation MSmartServerList

@dynamic archivedPredicate;
@dynamic name;

+ (void)initialize
{
	[self setKeys:[NSArray arrayWithObjects:@"name", @"icon", nil] 
triggerChangeNotificationsForDependentKey:@"infoDict"];
}


+ (MSmartServerList *)createSmartServerListInContext:(NSManagedObjectContext *)context
{
	return [NSEntityDescription insertNewObjectForEntityForName:@"SmartServerList"
										 inManagedObjectContext:context];
}

- (void)awakeFromFetch
{
	[super awakeFromFetch];
	[[self parent] addObserver:self
					forKeyPath:@"servers" 
					   options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld 
					   context:NULL];
}

- (void)willSave
{
	[super willSave];
	if([self isDeleted]){
		[[self parent] removeObserver:self
						   forKeyPath:@"servers"];
	}
}

- (MServerList *)parent 
{
    id tmpObject;
    
    [self willAccessValueForKey:@"parent"];
    tmpObject = [self primitiveValueForKey:@"parent"];
    [self didAccessValueForKey:@"parent"];
    
    return tmpObject;
}

- (void)setParent:(MServerList *)value 
{
    [self willChangeValueForKey:@"parent"];
	[[self primitiveValueForKey:@"parent"] removeObserver:self forKeyPath:@"servers"];
    [self setPrimitiveValue:value forKey:@"parent"];
	[[self primitiveValueForKey:@"parent"] addObserver:self forKeyPath:@"servers" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self didChangeValueForKey:@"parent"];
}

- (NSPredicate *)predicate 
{
    NSPredicate * tmpValue;
    
    [self willAccessValueForKey:@"predicate"];
    tmpValue = [self primitiveValueForKey:@"predicate"];
    [self didAccessValueForKey:@"predicate"];
    if(tmpValue == nil){
		NSData *predicateData = [self valueForKey:@"archivedPredicate"];
		if(predicateData != nil){
			tmpValue = [NSKeyedUnarchiver unarchiveObjectWithData:predicateData];
			[self setPrimitiveValue:tmpValue forKey:@"predicate"];
		}
	}
    return tmpValue;
}

- (void)setPredicate:(NSPredicate *)value 
{
    [self willChangeValueForKey:@"predicate"];
    [self setPrimitiveValue:value forKey:@"predicate"];
    [self didChangeValueForKey:@"predicate"];
	[self setValue:[NSKeyedArchiver archivedDataWithRootObject:value] forKey:@"archivedPredicate"];
}

- (NSImage *)icon
{
	if(icon == nil){
//		icon = [[NSImage imageNamed:@"Smart Folder"] retain];
		icon = [[NSImage imageNamed:@"NSFolderSmart"] retain];
	}
	return icon;
}

- (BOOL)isLeaf
{
	return YES;
}

- (void)setIsLeaf:(BOOL)value
{
	// do nothing
}

- (NSDictionary *)infoDict
{
	return [self dictionaryWithValuesForKeys:
			[NSArray arrayWithObjects:@"name", @"icon", nil]];
}

- (void)setInfoDict:(NSDictionary *)infoDict
{
	[self setValuesForKeysWithDictionary:infoDict];
}

- (NSSet *)smartLists
{
	return nil;
}

- (void)setSmartLists
{
	// do nothing
}

- (MGenericGame *)game
{
	return [[self parent] game];
}

- (void)setGame:(MGenericGame *)game
{
	//do nothing
}

- (NSSet *)servers
{
	if(filteredServersCache == nil){
		NSSet *parentServers = [[self parent] servers];
		NSLog(@"self predicate %@", [self predicate]);
		NSSet *fs = [parentServers filteredSetUsingPredicate:[self predicate]];
		filteredServersCache = [[NSMutableSet alloc] initWithSet:fs];
	}
	return [[filteredServersCache copy] autorelease];
}

- (void)setServers:(NSSet *)value
{
	// hammer time! can't touch this!
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

	if(filteredServersCache == nil){
		// if the user hasn't opened this smart list
		// don't bother calculating this stuff, when he opens (if he'll ever open)
		// filtered servers will be calculated in the getter
		return;
	}
	
	if([keyPath isEqualToString:@"servers"]){
		// check deleted Servers
		if([[change objectForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeRemoval ||
		   [[change objectForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeReplacement){
			NSArray *removedServers = [change objectForKey:NSKeyValueChangeOldKey];

			for (MServer *s in removedServers) {
				[filteredServersCache removeObject:s];
			}
		}
		if([[change objectForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeInsertion ||
		   [[change objectForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeReplacement){
			NSArray *newServers = [change objectForKey:NSKeyValueChangeNewKey];
			
			NSArray *filteredNewServers = [newServers filteredArrayUsingPredicate:[self predicate]];
			[filteredServersCache addObjectsFromArray:filteredNewServers];
		}
	}
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


// coalesce these into one @interface SmartServerList (CoreDataGeneratedPrimitiveAccessors) section
@interface SmartServerList (CoreDataGeneratedPrimitiveAccessors)

- (NSData *)primitivePredicateData;
- (void)setPrimitivePredicateData:(NSData *)value;

- (UNKNOWN_TYPE)primitivePredicate;
- (void)setPrimitivePredicate:(UNKNOWN_TYPE)value;

- (NSString *)primitiveName;
- (void)setPrimitiveName:(NSString *)value;

- (MServerList)primitiveParent;
- (void)setPrimitiveParent:(MServerList)value;

@end

- (NSData *)predicateData 
{
    NSData * tmpValue;
    
    [self willAccessValueForKey:@"predicateData"];
    tmpValue = [self primitivePredicateData];
    [self didAccessValueForKey:@"predicateData"];
    
    return tmpValue;
}

- (void)setPredicateData:(NSData *)value 
{
    [self willChangeValueForKey:@"predicateData"];
    [self setPrimitivePredicateData:value];
    [self didChangeValueForKey:@"predicateData"];
}

- (BOOL)validatePredicateData:(id *)valueRef error:(NSError **)outError 
{
    // Insert custom validation logic here.
    return YES;
}


- (BOOL)validatePredicate:(id *)valueRef error:(NSError **)outError 
{
    // Insert custom validation logic here.
    return YES;
}

- (NSString *)name 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"name"];
    tmpValue = [self primitiveName];
    [self didAccessValueForKey:@"name"];
    
    return tmpValue;
}

- (void)setName:(NSString *)value 
{
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveName:value];
    [self didChangeValueForKey:@"name"];
}

- (BOOL)validateName:(id *)valueRef error:(NSError **)outError 
{
    // Insert custom validation logic here.
    return YES;
}


- (BOOL)validateParent:(id *)valueRef error:(NSError **)outError 
{
    // Insert custom validation logic here.
    return YES;
}

#endif

