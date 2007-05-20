//
//  MServersController.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/05.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MServersController : NSArrayController {
	IBOutlet id infoWindow;
	IBOutlet id serversTableView;
}

#pragma mark Actions

- (IBAction)serverInfo:(id)sender;

@end
