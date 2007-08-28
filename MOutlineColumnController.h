//
//  MOutlineColumnController.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/08/26.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSString *const MQueryStarted = @"QueryStarted";
NSString *const MQueryEnded = @"QueryEnded";


@interface MOutlineColumnController : NSObject {
	NSTableColumn *tableColumn;
	NSTimer *heartbeatTimer;
}

- (id)initWithTableColumn:(NSTableColumn *)column;

@end
