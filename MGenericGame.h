//
//  MGenericGame.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/01/27.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MServer;

@interface MGenericGame : NSObject <NSCopying> {
	NSString *name;
	NSString *version;
	NSString *bundleIdentifier;
	NSString *bundlePath;
	NSImage *icon;
}

#pragma mark Class Methods
+ (NSString *)gameClassNameWithServerTypeString:(NSString *)sts;
+ (NSArray *)installedGames;

#pragma mark Init Methods
- (id)initWithGameName:(NSString *)name andBundlePath:(NSString *)path;

#pragma mark Accessor Methods
- (NSString *)name;
- (void)setName:(NSString *)value;

- (NSString *)version;
- (void)setVersion:(NSString *)value;

- (NSString *)bundlePath;
- (void)setBundlePath:(NSString *)value;

- (NSImage *)icon;
- (void)setIcon:(NSImage *)value;

- (NSString *)bundleIdentifier;
- (void)setBundleIdentifier:(NSString *)value;

- (NSAttributedString *)processName:(NSString *)name;
- (NSError *)connectToServer:(MServer *)server;

- (NSString *)serverTypeString;
- (NSString *)masterServerFlag;
- (NSString *)masterServerAddress;
- (NSString *)defaultGameType;

- (NSComparisonResult)compare:(MGenericGame *)game;
@end

@interface MGenericGame (Abstract)

#pragma mark Abstract Class Methods
+ (BOOL)isInstalled;
+ (NSAttributedString *)processName:(NSString *)name;
+ (NSError *)connectToServer:(MServer *)server;
+ (NSString *)serverTypeString;
+ (NSString *)masterServerFlag;
+ (NSString *)masterServerAddress;
+ (NSString *)defaultGameType;

@end