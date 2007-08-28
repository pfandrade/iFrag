//
//  MOutlineCell.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/03/31.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MOutlineCell.h"

#define DEG2RAD  0.017453292519943295
#define PIECHART_STEPS 8

const static float heightPercentage = 0.45;
const static float lineWidth = 2.0;
const static double stepAngle = 360.0 / PIECHART_STEPS;

static double spinnerPosition = 0;

@interface MOutlineCell (Private)

- (void)drawIndeterminateIndicaterInRect:(NSRect)aRect;
- (void)drawPieChartInRect:(NSRect)aRect;

@end

@implementation MOutlineCell


- (double)spinnerPosition
{
	return spinnerPosition;
}

- (void)setSpinnerPosition:(double)value
{
	if (spinnerPosition != value) {
		spinnerPosition = value;
		if (spinnerPosition > 1.0) {
			spinnerPosition = 1.0;
		} else if (spinnerPosition < 0.0) {
			spinnerPosition = 0.0;
		}
	}
}

#pragma mark -

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

- (MProgressDelegate *)progressDelegate {
	id ret = [[self objectValue] valueForKey:@"progressDelegate"];
    return ([ret isEqual:[NSNull null]]) ? nil : ret;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSImage *image = [self image];
    
	/** Take care of the Image Rectangle **/
	if (image != nil) {
		NSSize	imageSize = [image size];
        NSRect	imageFrame;

        NSDivideRect(cellFrame, &imageFrame, &cellFrame, imageSize.width + 3, NSMinXEdge);
		
		imageFrame.origin.x += 3;
        imageFrame.size = imageSize;
		
        if ([controlView isFlipped])
            imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
        else
            imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
		
        [image compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
    }
	
    [super drawWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSMutableAttributedString *drawString = [[self attributedTitle] mutableCopy];
	NSRect	aRect;
	
	id pd = [self progressDelegate];
	
	if ([pd isRunning]){
		float diameter = floor(heightPercentage * cellFrame.size.height);
		NSSize	indicatorSize = NSMakeSize(diameter,diameter);
		//we subtract 8 to leave 4 pixels on each side
		NSDivideRect(cellFrame, &cellFrame, &aRect,(cellFrame.size.width - indicatorSize.width - 8), NSMinXEdge);
		
		aRect.origin.x += 4;
		
		aRect.origin.y += ceil((aRect.size.height - indicatorSize.height) / 2);
		
		aRect.size.width -= 8;
		aRect.size.height = indicatorSize.height;
		
		/** draw the indicator **/
		if([pd doubleValue] <= [pd minValue]){
			[self drawIndeterminateIndicaterInRect:aRect];
		}else{
			[self drawPieChartInRect:aRect];
		}
	
	}
	
	/** Draw the string **/
	// Vertically center the string
	float stringHeight = [drawString size].height;
	cellFrame.origin.y += (cellFrame.size.height - stringHeight) / 2.0;
	//cellFrame.size.height = stringHeight;
	
	// Add some padding
	cellFrame.origin.x += 5;
	cellFrame.size.width -= 5;
	
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
	[drawString release];
}

//- (NSSize)cellSize {
//    NSSize cellSize = [super cellSize];
//	NSImage *image = [self image];
//	NSProgressIndicator *progressInd = [self progressIndicator];
//    cellSize.width += (image ? [image size].width + 3 : 0);
//	cellSize.width += (![progressInd isHidden] ? ceil(cellSize.height * heightPercentage)  + 3 : 0);
//    return cellSize;
//}

- (void)drawIndeterminateIndicaterInRect:(NSRect)aRect
{
	int step = round([self spinnerPosition]/(5.0/60.0));
	float cellSize = aRect.size.width;
	NSPoint center = aRect.origin;
	center.x += aRect.size.width/2.0;
	center.y += aRect.size.height/2.0;
	float outerRadius;
	float innerRadius;
	float strokeWidth = cellSize*0.08;
	if (cellSize >= 32.0) {
		outerRadius = cellSize*0.38;
		innerRadius = cellSize*0.23;
	} else {
		outerRadius = cellSize*0.48;
		innerRadius = cellSize*0.27;
	}
	float a; // angle
	NSPoint inner;
	NSPoint outer;
	[NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
	[NSBezierPath setDefaultLineWidth:strokeWidth];
	a = (270+(step* 30))*DEG2RAD;
	
	int i;
	for (i = 0; i < 12; i++) {
		[[NSColor colorWithCalibratedWhite:MIN(sqrt(i)*0.25, 0.8) alpha:1.0] set];
		outer = NSMakePoint(center.x+cos(a)*outerRadius, center.y+sin(a)*outerRadius);
		inner = NSMakePoint(center.x+cos(a)*innerRadius, center.y+sin(a)*innerRadius);
		[NSBezierPath strokeLineFromPoint:inner toPoint:outer];
		a -= 30*DEG2RAD;
	}	
}

- (void)drawPieChartInRect:(NSRect)aRect
{
	[NSGraphicsContext saveGraphicsState];
	
	NSRect theBounds = aRect;
	id pd = [self progressDelegate];
	
	// Clip to the border of the pie chart...
	NSBezierPath *thePath = [NSBezierPath bezierPathWithOvalInRect:theBounds];
	[thePath setLineWidth:lineWidth];
	[thePath addClip];
	
	theBounds = NSInsetRect(theBounds, lineWidth / 2.0f, lineWidth / 2.0f);
	
	NSPoint theCenter = {
		.x = theBounds.origin.x + theBounds.size.width / 2.0f,
		.y = theBounds.origin.y + theBounds.size.height / 2.0f,
	};
	
	double theAngle = ([pd doubleValue] - [pd minValue]) / ([pd maxValue] - [pd minValue]) * 360.0;

	theAngle = floor(theAngle / stepAngle) * stepAngle;
		
	// Draw piechart wedge.
	if (theAngle != 0.0)
	{
		thePath = [NSBezierPath bezierPath];
		[thePath moveToPoint:theCenter];
		//[thePath lineToPoint:NSMakePoint(theCenter.x, theBounds.origin.y + theBounds.size.height)];
		[thePath appendBezierPathWithArcWithCenter:theCenter radius:theBounds.size.width / 2.0f startAngle:270.0f endAngle:270.0f + theAngle];
		[thePath lineToPoint:theCenter];
		[thePath closePath];
		[thePath setLineCapStyle:NSRoundLineCapStyle];
		[thePath setLineJoinStyle:NSRoundLineJoinStyle];
		
		NSColor *color = [NSColor colorWithCalibratedRed:0.506f green:0.635f blue:0.827f alpha:1.0f];
		[color set];
		[thePath fill];
		
		if (theAngle != 360.0f)
		{
			[thePath setLineWidth:lineWidth];
			[thePath stroke];
		}
	}
	
	// Draw piechart border...
	thePath = [NSBezierPath bezierPathWithOvalInRect:theBounds];
	[thePath setLineWidth:lineWidth];
	[thePath stroke];
	
	[NSGraphicsContext restoreGraphicsState];
}

@end
