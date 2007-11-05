//
//  MOutlineColumnController.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/08/26.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

static NSString *MQueryStarted = @"QueryStarted";
static NSString *MQueryEnded = @"QueryEnded";


@interface MOutlineColumnController : NSObject {
	NSTableColumn *tableColumn;
	NSTimer *heartbeatTimer;
}

- (id)initWithTableColumn:(NSTableColumn *)column;

@end
