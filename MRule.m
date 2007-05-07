//
//  MRule.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/21.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MRule.h"
#import "MServer.h"

@implementation MRule

+ (MRule *)createRuleInContext:(NSManagedObjectContext *)context
{
	return [NSEntityDescription insertNewObjectForEntityForName:@"Rule"
										 inManagedObjectContext:context];
}

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

- (NSString *)value 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"value"];
    tmpValue = [self primitiveValueForKey: @"value"];
    [self didAccessValueForKey: @"value"];
    
    return tmpValue;
}

- (void)setValue:(NSString *)value 
{
    [self willChangeValueForKey: @"value"];
    [self setPrimitiveValue: value forKey: @"value"];
    [self didChangeValueForKey: @"value"];
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
