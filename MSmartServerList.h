//
//  MSmartServerList.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/11/13.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MServerList;

@interface MSmartServerList : NSManagedObject {
	NSMutableSet *filteredServersCache;
}

@property (retain) NSData * archivedPredicate;
@property (retain) NSPredicate * predicate;
@property (retain) NSString * name;
@property (retain) MServerList * parent;


+ (MSmartServerList *)createSmartServerListInContext:(NSManagedObjectContext *)context;
- (NSImage *)icon;

#pragma mark Derived attributes

- (NSDictionary *)infoDict;
- (void)setInfoDict:(NSDictionary *)infoDict;

- (NSSet *)servers;
- (void)setServers:(NSSet *)value;

@end

