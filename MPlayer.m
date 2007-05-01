//
//  MPlayer.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/11/09.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import "MPlayer.h"
#import "MServer.h"
#import "MGenericGame.h"
#import "MServerListManager.h"

@implementation MPlayer

+ (MPlayer *)createPlayer
{
	return [NSEntityDescription insertNewObjectForEntityForName:@"Player"
										 inManagedObjectContext:[[NSApp delegate] managedObjectContext]];
}

// Derived properties
- (NSAttributedString *)attributedName 
{
    NSAttributedString * tmpValue;
    
    [self willAccessValueForKey: @"attributedName"];
    tmpValue = [self primitiveValueForKey: @"attributedName"];
    [self didAccessValueForKey: @"attributedName"];
    
	if (tmpValue == nil) {
        MGenericGame *game = [[self parentServer] game];
		tmpValue = [game processName:[self name]];
		[self setPrimitiveValue:tmpValue forKey:@"attributedName"];
    }
	
    return tmpValue;
}

- (void)setAttributedName:(NSAttributedString *)value 
{
    [self willChangeValueForKey: @"attributedName"];
    [self setPrimitiveValue: value forKey: @"attributedName"];
    [self didChangeValueForKey: @"attributedName"];
}

// Property acessors
- (NSString *)name 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"name"];
    tmpValue = [self primitiveValueForKey: @"name"];
    [self didAccessValueForKey: @"name"];
    
    return tmpValue;
}

- (void)setName:(NSString *)value 
{
    [self willChangeValueForKey: @"name"];
    [self setPrimitiveValue: value forKey: @"name"];
    [self didChangeValueForKey: @"name"];
}

- (NSNumber *)ping 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"ping"];
    tmpValue = [self primitiveValueForKey: @"ping"];
    [self didAccessValueForKey: @"ping"];
    
    return tmpValue;
}

- (void)setPing:(NSNumber *)value 
{
    [self willChangeValueForKey: @"ping"];
    [self setPrimitiveValue: value forKey: @"ping"];
    [self didChangeValueForKey: @"ping"];
}

- (NSNumber *)score 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"score"];
    tmpValue = [self primitiveValueForKey: @"score"];
    [self didAccessValueForKey: @"score"];
    
    return tmpValue;
}

- (void)setScore:(NSNumber *)value 
{
    [self willChangeValueForKey: @"score"];
    [self setPrimitiveValue: value forKey: @"score"];
    [self didChangeValueForKey: @"score"];
}


- (MServer *)parentServer 
{
    id tmpObject;
    
    [self willAccessValueForKey: @"parentServer"];
    tmpObject = [self primitiveValueForKey: @"parentServer"];
    [self didAccessValueForKey: @"parentServer"];
    
    return tmpObject;
}

- (void)setParentServer:(MServer *)value 
{
    [self willChangeValueForKey: @"parentServer"];
    [self setPrimitiveValue: value
                     forKey: @"parentServer"];
    [self didChangeValueForKey: @"parentServer"];
}

@end
