//
//  MPlayer.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 06/11/09.
//  Copyright 2006 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MServer;

@interface MPlayer : NSManagedObject {

}

+ (MPlayer *)createPlayer;

// Derived properties
- (NSAttributedString *)attributedName;
- (void)setAttributedName:(NSAttributedString *)value;

// Property acessors
- (NSString *)name;
- (void)setName:(NSString *)value;

- (NSNumber *)ping;
- (void)setPing:(NSNumber *)value;

- (NSNumber *)score;
- (void)setScore:(NSNumber *)value;

- (MServer *)parentServer;
- (void)setParentServer:(MServer *)value;

@end
