//
//  MTableHeaderView.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/07/23.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MTableHeaderView : NSTableHeaderView {
	NSMenu *columnsMenu;
}

- (NSMenu *)columnsMenu;
- (void)setColumnsMenu:(NSMenu *)value;

@end
