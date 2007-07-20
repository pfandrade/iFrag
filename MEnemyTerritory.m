//
//  MEnemyTerritory.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/07/17.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MEnemyTerritory.h"

// this game name is not used anymore, we now use the bundleName
static NSString *const _gameName			= @"Wolfenstein Enemy Territory";
static NSString *const _bundleIdentifier	= @"com.activision.rtcw_et";
static NSString *const _serverTypeString	= @"woets";
static NSString *const _masterServerFlag	= @"woetm";
static NSString *const _masterServerAddress = @"etmaster.idsoftware.com";
static NSString *const _defaultGameType		= @"etmain";
static NSString *const _defaultServerPort	= @"27960";

@interface MEnemyTerritory (Private)

+ (NSColor *)colorForChar:(char)c;

@end

@implementation MEnemyTerritory

+ (BOOL)isInstalled {
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	
	return ([ws absolutePathForAppBundleWithIdentifier:_bundleIdentifier] != nil);
}

+ (NSAttributedString *)processName:(NSString *)name {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSArray *slices = [name componentsSeparatedByString:@"^"];
	NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] init];
	NSEnumerator *str_enum = [slices objectEnumerator];
	
	NSString *currentString, *subString;
	
	currentString = [str_enum nextObject];	//skip the first string
	if([currentString length] > 0) [attribString appendAttributedString:[[[NSAttributedString alloc] initWithString:currentString] autorelease]];
	int len, aux = 0, signal = 0;
	NSColor *color = [NSColor blackColor]; //default color
	while((currentString = [str_enum nextObject])){
		if ((len = [currentString length]) < 2){
			if(++aux % 2 != 0){
				[attribString appendAttributedString:
					[[[NSAttributedString alloc] initWithString:@"^"
													 attributes:[NSDictionary dictionaryWithObject:color
																							forKey:NSForegroundColorAttributeName]] autorelease]];
				signal = 1;
				continue;
			}
			signal = 0;
			continue;
		}
		aux = 0;
		if(signal != 1){
			color = [self colorForChar:[currentString characterAtIndex:0]];
			subString = [currentString substringFromIndex:1];
		}else{
			subString = currentString;
		}
		[attribString appendAttributedString:
			[[[NSAttributedString alloc] initWithString:subString
											 attributes:[NSDictionary dictionaryWithObject:color
																					forKey:NSForegroundColorAttributeName]] autorelease]];
	}
	[pool release];
	return [attribString autorelease];
}

+ (NSError *)connectToServer:(MServer *)server {
	//TODO:
	return nil;
}

#pragma mark Overriden Instance Methods

- (id) init {
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	
	NSString *bundleName = [[[ws absolutePathForAppBundleWithIdentifier:_bundleIdentifier] lastPathComponent] stringByDeletingPathExtension];
		
	self = [super initWithGameName:[NSString stringWithString:bundleName]
					 andBundlePath:[[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:_bundleIdentifier]];
	if (self != nil) {
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

+ (NSString *)defaultGameType
{
	return _defaultGameType;
}

+ (NSString *)defaultServerPort
{
	return _defaultServerPort;
}

//private
+ (NSColor *)colorForChar:(char)c
{
	switch(c){
		case '0':case 'p':
			return [NSColor blackColor];
		case '1':case 'q':
			return [NSColor redColor];
		case '2':case 'r':
			return [NSColor greenColor];
		case '3':case 's':
			return [NSColor yellowColor];
		case '4':case 't':
			return [NSColor blueColor];
		case '5':case'u':
			return [NSColor colorWithCalibratedRed:0.18 green:1.0 blue:1.0 alpha:1.0]; //brightBlue
		case '6':case 'v':
			return [NSColor purpleColor];
		case '7':case 'w':
			return [NSColor lightGrayColor];
		case '8':case 'x':
			return [NSColor orangeColor];
		case '9':case 'y':case '*':
			return [NSColor grayColor];
		case 'a':
			return [NSColor colorWithCalibratedRed:0.9 green:0.6 blue:0.3 alpha:1.0];//lightOrange - a
		case 'b':
			return [NSColor colorWithCalibratedRed:0.06 green:0.4 blue:0.3 alpha:1.0];//turquoise - b
		case 'c':
			return [NSColor colorWithCalibratedRed:0.04 green:0.07 blue:0.31 alpha:1.0];//purple - c 
		case 'd':
			return [NSColor colorWithCalibratedRed:0.01 green:0.35 blue:1.0 alpha:1.0];//ligthBlue - d
		case 'e':
			return [NSColor colorWithCalibratedRed:0.4 green:0.1 blue:0.65 alpha:1.0];//darkPurple - e
		case 'f':
			return [NSColor colorWithCalibratedRed:0.31 green:0.59 blue:0.75 alpha:1.0]; //babyBlue - f
		case 'g':
			return [NSColor colorWithCalibratedRed:0.74 green:0.84 blue:0.72 alpha:1.0]; //verylightGreen - g 
		case 'h':
			return [NSColor colorWithCalibratedRed:0.08 green:0.30 blue:0.17 alpha:1.0];//darkGreen - h
		case 'i':case '+':
			return [NSColor colorWithCalibratedRed:0.49 green:0.03 blue:0.13 alpha:1.0];//darkRed - i 
		case 'j': case '?':
			return [NSColor colorWithCalibratedRed:0.56 green:0.14 blue:0.24 alpha:1.0]; //claret - j
		case 'k':case '@':
			return [NSColor colorWithCalibratedRed:0.45 green:0.20 blue:0.7 alpha:1.0];//brown - k
		case 'l':
			return [NSColor colorWithDeviceRed:0.65 green:0.56 blue:0.36 alpha:1.0];//lightBrown - l
		case 'm':case '-':
			return [NSColor colorWithDeviceRed:0.33 green:0.36 blue:0.14 alpha:1.0]; //olive - m
		case 'n':
			return [NSColor colorWithDeviceRed:0.68 green:0.67 blue:0.59 alpha:1.0];// beige - n
		case 'o': case '/':
			return [NSColor colorWithDeviceRed:0.75 green:0.75 blue:0.50 alpha:1.0]; //beige2 - o
		default:
			return [NSColor blackColor];
	}
}

@end
