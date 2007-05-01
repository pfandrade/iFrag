//
//  MFavorites.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/01/28.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MFavorites.h"
#import "MServer.h"

NSString *const _gameName			= @"Favorites";
NSString *const _bundleIdentifier	= @"com.maracujasoftware.Favorites";
NSString *const _serverTypeString	= @"fav";
NSString *const _masterServerFlag	= @"fav";
NSString *const _masterServerAddress = @"Favorites.ifrag.com";
NSString *const _defaultGameType	= @"basefav";

@implementation MFavorites

+ (BOOL)isInstalled {
	//Favorites is always installed
	return YES;
}

+ (NSAttributedString *)processName:(NSString *)name {
	return [[[NSAttributedString alloc] initWithString:name] autorelease];
}

+ (NSError *)connectToServer:(MServer *)server {
	NSString *gameClassName = [MGenericGame gameClassNameWithServerTypeString:[server serverType]];
	Class gameClass = objc_getClass([gameClassName UTF8String]);
	return [gameClass connectToServer:server];
}

- (id) init {
	self = [super initWithGameName:[NSString stringWithString:_gameName]
												andBundlePath:@"!Favorites doesn't have a bundlePath!" ];
	if (self != nil) {
		icon = [[NSImage imageNamed:@"Folder"] retain];
		bundleIdentifier = _bundleIdentifier;
	}
	return self;
}


+ (NSString *)serverTypeString {
    return _serverTypeString;
}

+ (NSString *)masterServerFlag {
    return _masterServerFlag;
}

+ (NSString *)masterServerAddress {
    return _masterServerAddress;
}

+ (NSString *)defaultGameType{
	return _defaultGameType;
}
@end
