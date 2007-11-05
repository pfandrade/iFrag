//
//  MOutlineCell.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/03/31.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MProgressDelegate;

@interface MOutlineCell : NSTextFieldCell {
}

- (NSImage *)image;
- (NSString *)title;
- (NSAttributedString *)attributedTitle;
- (MProgressDelegate *)progressDelegate;

- (double)spinnerPosition;
- (void)setSpinnerPosition:(double)value;

@end
