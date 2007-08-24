//
//  MRules.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/21.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MRules.h"
#import "MServer.h"

@implementation MRules

+ (MRules *)createRulesInContext:(NSManagedObjectContext *)context
{
	return [NSEntityDescription insertNewObjectForEntityForName:@"Rules"
										 inManagedObjectContext:context];
}

- (NSDictionary *)rules 
{
    NSDictionary *tmpValue;
    
    [self willAccessValueForKey: @"rules"];
    tmpValue = [self primitiveValueForKey: @"rules"];
    [self didAccessValueForKey: @"rules"];
    if(tmpValue == nil){
		NSData *rulesData = [self valueForKey:@"archivedRules"];
		if(rulesData != nil){
			tmpValue = [NSKeyedUnarchiver unarchiveObjectWithData:rulesData];
			[self setPrimitiveValue:tmpValue forKey:@"rules"];
		}
	}
    return tmpValue;
}

- (void)setRules:(NSDictionary *)value 
{
    [self willChangeValueForKey: @"rules"];
    [self setPrimitiveValue: value forKey: @"rules"];
    [self didChangeValueForKey: @"rules"];
	[self setValue:[NSKeyedArchiver archivedDataWithRootObject:value] forKey:@"archivedRules"];
}


- (NSData *)archivedRules 
{
    NSData * tmpValue;
    
    [self willAccessValueForKey: @"archivedRules"];
    tmpValue = [self primitiveValueForKey: @"archivedRules"];
    [self didAccessValueForKey: @"archivedRules"];
    
    return tmpValue;
}

- (void)setArchivedRules:(NSData *)value 
{
    [self willChangeValueForKey: @"archivedRules"];
    [self setPrimitiveValue: value forKey: @"archivedRules"];
    [self didChangeValueForKey: @"archivedRules"];
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
