//
//  MFavorites.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/01/28.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MFavorites.h"
#import "MServer.h"

static NSString *const _gameName			= @"Favorites";
static NSString *const _bundleIdentifier	= @"com.maracujasoftware.Favorites";
static NSString *const _serverTypeString	= @"fav";
static NSString *const _masterServerFlag	= @"fav";
static NSString *const _masterServerAddress = @"Favorites.ifrag.com";
static NSString *const _defaultGameType		= @"basefav";
static NSString *const _defaultServerPort	= @"55555";

@implementation MFavorites

+ (BOOL)isInstalled {
	//Favorites is always installed
	return YES;
}

+ (NSAttributedString *)processName:(NSString *)name {
	return [[[NSAttributedString alloc] initWithString:name] autorelease];
}

- (id) init {
	self = [super initWithGameName:[NSString stringWithString:_gameName]
												andBundlePath:@"!Favorites doesn't have a bundlePath!" ];
	if (self != nil) {
		icon = [[NSImage imageNamed:@"Favorites"] retain];
		[icon setSize:NSMakeSize(32,32)];
		bundleIdentifier = _bundleIdentifier;
	}
	return self;
}


- (NSError *)launchWithServer:(MServer *)server andPassword:(NSString *)pass {
	NSString *gameClassName = [MGenericGame gameClassNameWithServerTypeString:[server serverType]];
	Class gameClass = objc_getClass([gameClassName UTF8String]);
	return [gameClass launchWithServer:server andPassword:pass];
}

- (NSString *)serverTypeString {
    return _serverTypeString;
}

- (NSString *)masterServerFlag {
    return _masterServerFlag;
}

- (NSString *)masterServerAddress {
    return _masterServerAddress;
}

- (NSString *)defaultGameType{
	return _defaultGameType;
}

- (NSString *)defaultServerPort
{
	return _defaultServerPort;
}

@end
