//
//  MRules.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/21.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MServer;

@interface MRules : NSManagedObject {

}

+ (MRules *)createRulesInContext:(NSManagedObjectContext *)context;

- (NSDictionary *)rules;
- (void)setRules:(NSDictionary *)value;

- (NSData *)archivedRules;
- (void)setArchivedRules:(NSData *)value;

- (MServer *)parentServer;
- (void)setParentServer:(MServer *)value;



@end
