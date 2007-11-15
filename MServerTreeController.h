//
//  MServerTreeController.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/11/15.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MServerList;
@class MSmartServerList;

@interface MServerTreeController : NSTreeController {

}

- (MServerList *)selectedServerList;
- (MSmartServerList *)selectedSmartServerList;

- (BOOL)isServerListSelected;

@end
