//
//  MOutlineCell.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/03/31.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MOutlineCell : NSTextFieldCell {
	@private
	NSProgressIndicator *progressIndicator;
}

- (NSImage *)image;
- (NSString *)title;
- (NSAttributedString *)attributedTitle;
- (NSProgressIndicator *)progressIndicator;
- (void)setProgressIndicator:(NSProgressIndicator *)value;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (NSSize)cellSize;

@end
