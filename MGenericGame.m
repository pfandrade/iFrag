//
//  MGenericGame.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/01/27.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MGenericGame.h"
#import "MServer.h"

#import "MFavorites.h"
#import "MQuake3.h"

#define SERVERTYPESTRINGS	[[NSArray arrayWithObjects:@"FAV",			@"Q3S", nil] retain]
#define GAMECLASSNAMES		[[NSArray arrayWithObjects:@"MFavorites",	@"MQuake3", nil] retain]

static NSArray *_serverTypeStrings; 
static NSArray *_gameClassNames;
static NSDictionary *_gwsts;

@implementation MGenericGame

#pragma mark Class Accessor Methods
+ (NSArray *)serverTypeStrings {
	if(_serverTypeStrings == nil)
		_serverTypeStrings = SERVERTYPESTRINGS;
	return _serverTypeStrings;
}

+ (NSArray *)gameClassNames{
	if(_gameClassNames == nil)
		_gameClassNames = GAMECLASSNAMES;
	return _gameClassNames;
}

#pragma mark Class Methods
+ (NSString *)gameClassNameWithServerTypeString:(NSString *)sts {
	if(_gwsts == nil)
		_gwsts = [[NSDictionary dictionaryWithObjects:[self gameClassNames] forKeys:[self serverTypeStrings]] retain];
	return [_gwsts objectForKey:sts];
}

+ (NSArray *)installedGames {
	NSMutableArray *inst_games = [[NSMutableArray alloc] init];
	
	NSEnumerator *game_enumerator =[[self gameClassNames] objectEnumerator];
	NSString *gameClassName;
	id game;
	while(gameClassName = [game_enumerator nextObject]){
		game = objc_getClass([gameClassName UTF8String]);
		if([game isInstalled]){
			[inst_games addObject:[[game new] autorelease]];
		}
	}
	return [inst_games autorelease];
}

+ (NSAttributedString *)processName:(NSString *)name
{
	return [[[NSAttributedString alloc] initWithString:name] autorelease];
}

#pragma mark Overriden Methods
- (id)initWithGameName:(NSString *)inName andBundlePath:(NSString *)path {
	self = [super init];
	if (self != nil) {
		name = [inName retain];
		bundlePath = [path retain];
	}
	return self;
}

- (void)dealloc {
	[name release];
	[version release];
	[bundlePath release];
	[icon release];
	[super dealloc];
}

- (BOOL)isEqual:(id)anObject
{
	if([anObject isKindOfClass:[self class]]){
		return [[self bundleIdentifier] isEqualToString:[anObject bundleIdentifier]];
	}
	return NO;
}

- (unsigned)hash
{
	return [bundleIdentifier hash];
}

#pragma mark Accessor Methods
- (NSString *)name {
    return [[name retain] autorelease];
}

- (void)setName:(NSString *)value {
    if (name != value) {
        [name release];
        name = [value copy];
    }
}

- (NSString *)version {
	if(version == nil){
		NSDictionary *gameInfo = [NSDictionary dictionaryWithContentsOfFile:
		[NSString stringWithFormat:@"%@%s",bundlePath,"/Contents/Info.plist"]];
		if(!(gameInfo != nil && 
			(version = [[gameInfo objectForKey:@"CFBundleVersion"] retain]) != nil)){
			version = @"Not Found!";
		}
	}
    return [[version retain] autorelease];
}

- (void)setVersion:(NSString *)value {
    if (version != value) {
        [version release];
        version = [value copy];
    }
}

- (NSString *)bundlePath {
    return [[bundlePath retain] autorelease];
}

- (void)setBundlePath:(NSString *)value {
    if (bundlePath != value) {
        [bundlePath release];
        bundlePath = [value copy];
    }
}

- (NSImage *)icon {
	if(icon == nil){
		NSWorkspace *ws = [NSWorkspace sharedWorkspace];
		icon = [[ws iconForFile:bundlePath] retain];
	}
    return [[icon retain] autorelease];
}

- (void)setIcon:(NSImage *)value {
    if (icon != value) {
        [icon release];
        icon = [value copy];
    }
}

- (NSString *)bundleIdentifier {
    return [[bundleIdentifier retain] autorelease];
}

- (void)setBundleIdentifier:(NSString *)value {
    if (bundleIdentifier != value) {
        [bundleIdentifier release];
        bundleIdentifier = [value retain];
    }
}



- (NSAttributedString *)processName:(NSString *)inName {
	return [[self class] processName:inName];
}

- (NSError *)connectToServer:(MServer *)server {
	return [[self class] connectToServer:server];
}

- (NSString *)serverTypeString{
	return [[self class] serverTypeString];
}

- (NSString *)masterServerFlag{
	return [[self class] masterServerFlag];
}

- (NSString *)masterServerAddress{
	return [[self class] masterServerAddress];
}

- (NSString *)defaultGameType {
	return [[self class] defaultGameType];
}

#pragma mark Copy methods

- (id)copyWithZone:(NSZone *)zone
{
	id newGG = [[MGenericGame alloc] initWithGameName:[[[self name] copy] autorelease] 
										andBundlePath:[[[self bundlePath] copy] autorelease]];
	[(MGenericGame *)newGG setName:[self name]];
	[newGG setBundleIdentifier:[self bundleIdentifier]];
	[newGG setIcon:[[self icon] copy]];
	
	return newGG;
}

@end
