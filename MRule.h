//
//  MRule.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/21.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MServer;

@interface MRule : NSManagedObject {

}

+ (MRule *)createRuleInContext:(NSManagedObjectContext *)context;

- (NSString *)name;
- (void)setName:(NSString *)value;

- (NSString *)value;
- (void)setValue:(NSString *)value;

- (MServer *)parentServer;
- (void)setParentServer:(MServer *)value;


@end
