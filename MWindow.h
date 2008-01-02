//
//  MWindow.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 12/26/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MWindow : NSWindow {
	IBOutlet NSButton *addNewServerButton;
	IBOutlet NSButton *addNewSmartListButton;
}

- (void)toggleAlternateButtons;

@end
