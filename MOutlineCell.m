//
//  MOutlineCell.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/03/31.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MOutlineCell.h"

const static float heightPercentage = 0.55;


@implementation MOutlineCell

- (NSImage *)image {
	id ret = [[self objectValue] valueForKey:@"icon"];
    return ([ret isEqual:[NSNull null]]) ? nil : ret;
}

- (NSString *)title {
	return [[self attributedTitle] string];
}

- (NSAttributedString *)attributedTitle {
	static NSDictionary *info = nil;
	
    if (nil == info) {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];
        info = [[NSDictionary alloc] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, nil];
        [style release];
    }
	
	NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[[self objectValue] valueForKey:@"name"] attributes:info];
	return [attString autorelease];
}

- (NSProgressIndicator *)progressIndicator {
	id ret = [[[self objectValue] valueForKey:@"progressDelegate"] valueForKey:@"progressIndicator"];
    return ([ret isEqual:[NSNull null]]) ? nil : ret;
}


- (NSRect)imageFrameForCellFrame:(NSRect)cellFrame {
    NSImage *image = [self image]; 
	if (image != nil) {
        NSRect imageFrame;
        imageFrame.size = [image size];
        imageFrame.origin = cellFrame.origin;
        imageFrame.origin.x += 3;
        imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
        return imageFrame;
    }
    else
        return NSZeroRect;
}

- (NSRect)progressIndicatorFrameForCellFrame:(NSRect)cellFrame {
	NSProgressIndicator *progressInd = [self progressIndicator];
	
    if (progressInd != nil) {
        NSRect indicatorFrame;
        indicatorFrame.size.width = ceil(cellFrame.size.height * heightPercentage);	// use 55% of the height
		indicatorFrame.size.height = indicatorFrame.size.width;		// make it a square
        indicatorFrame.origin = cellFrame.origin;
        indicatorFrame.origin.x = (cellFrame.origin.x + cellFrame.size.width) - (indicatorFrame.size.width + 3);
        indicatorFrame.origin.y += ceil((cellFrame.size.height - indicatorFrame.size.height) / 2);
        return indicatorFrame;
    }
    else
        return NSZeroRect;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSImage *image = [self image];
	NSProgressIndicator *progressInd = [self progressIndicator];
	NSRect	aRect; //auxiliar rect to pass do NSDivideRect, it's not used
    
	/** Take care of the Image Rectangle **/
	if (image != nil) {
        NSRect	imageFrame = [self imageFrameForCellFrame:cellFrame];

        NSDivideRect(cellFrame, &aRect, &cellFrame, imageFrame.size.width + 3, NSMinXEdge);
        if ([self drawsBackground]) {
            [[self backgroundColor] set];
            NSRectFill(imageFrame);
        }
		
        if ([controlView isFlipped])
            imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
        else
            imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
		
        [image compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
    }
	
	NSRect auxCellFrame = cellFrame;
	/** Take care of the Progress Indicator Rectangle **/
	if(progressInd != nil){
		NSRect	indicatorFrame = [self progressIndicatorFrameForCellFrame:cellFrame];
				
        NSDivideRect(cellFrame, &cellFrame, &aRect,(cellFrame.size.width - indicatorFrame.size.width - 9), NSMinXEdge);
        if ([self drawsBackground]) {
            [[self backgroundColor] set];
            NSRectFill(indicatorFrame);
        }
		
		[progressInd setFrame:indicatorFrame];
		if([progressInd superview] == nil){
			[controlView addSubview:progressInd];
		}
		[progressInd setNeedsDisplay:YES];
	}
	
	if([progressInd isHidden]){
		auxCellFrame.size.width -= 6;
		cellFrame = auxCellFrame;
	}
    [super drawWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSMutableAttributedString *drawString = [[self attributedTitle] mutableCopy];

	// Vertically center the string
	float stringHeight = [drawString size].height;
	cellFrame.origin.y += (cellFrame.size.height - stringHeight) / 2.0;
	cellFrame.size.height = stringHeight;
	
	// Add some padding
	cellFrame.origin.x += 5;
	
	if([self isHighlighted]){
		[drawString addAttribute:NSForegroundColorAttributeName 
						   value:[NSColor whiteColor] 
						   range:NSMakeRange(0,[drawString length])];
	}else{
		[drawString addAttribute:NSForegroundColorAttributeName 
						   value:[NSColor blackColor] 
						   range:NSMakeRange(0,[drawString length])];
	}
	[drawString drawInRect:cellFrame];
	[drawString autorelease];
}

- (NSSize)cellSize {
    NSSize cellSize = [super cellSize];
	NSImage *image = [self image];
	NSProgressIndicator *progressInd = [self progressIndicator];
    cellSize.width += (image ? [image size].width + 3 : 0);
	cellSize.width += (![progressInd isHidden] ? ceil(cellSize.height * heightPercentage)  + 3 : 0);
    return cellSize;
}

@end
