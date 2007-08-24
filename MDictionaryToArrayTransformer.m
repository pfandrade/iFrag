//
//  MDictionaryToArrayTransformer.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/08/13.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MDictionaryToArrayTransformer.h"

@implementation MDictionaryToArrayTransformer

+ (Class)transformedValueClass;
{
    return [NSMutableArray class];
}

+ (BOOL)allowsReverseTransformation;
{
    return YES;
}

- (id)transformedValue:(id)value {
    NSMutableArray *array = [NSMutableArray array];
	NSEnumerator *keyEnum = [[value allKeys] objectEnumerator];
	NSString *key;
	
	while(key = [keyEnum nextObject]){
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
            key, @"key",
            [value valueForKey:key], @"value", nil]];
    }
	
    return array;
}

- (id)reverseTransformedValue:(id)value {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	NSEnumerator *keyEnum = [[value allKeys] objectEnumerator];
	NSDictionary *keyValuePair;
	
    while(keyValuePair = [keyEnum nextObject]) {
        [dictionary setValue:[keyValuePair valueForKey:@"value"]
                      forKey:[keyValuePair valueForKey:@"key"]];
    }
	
    return dictionary;
}
@end
