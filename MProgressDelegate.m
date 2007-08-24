//
//  MProgressDelegate.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/01.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MProgressDelegate.h"
#import "CToxicProgressIndicator.h"

@implementation MProgressDelegate

+ (MProgressDelegate *)progressDelegate
{
	MProgressDelegate *pd = [[MProgressDelegate alloc] init];
	return [pd autorelease];
}

- (double)minValue {
    return minValue;
}

- (void)setMinValue:(double)value {
    if (minValue != value) {
        minValue = value;
    }
}

- (double)maxValue {
    return maxValue;
}

- (void)setMaxValue:(double)value {
    if (maxValue != value) {
        maxValue = value;
    }
}

- (double)doubleValue {
    return doubleValue;
}

- (void)setDoubleValue:(double)value {
    if (doubleValue != value) {
        doubleValue = value;
    }
}

- (BOOL)isRunning {
    return isRunning;
}

- (void)setIsRunning:(BOOL)value {
    if (isRunning != value) {
        isRunning = value;
    }
}

- (void)started
{
	[self setIsRunning:YES];
//	[progressIndicator startAnimation:self];
}

- (void)startedProcessing:(unsigned)nItems
{
	[self started];
	if(nItems < 10) //it's not worth it :
		return;
	[self setMaxValue:(double)nItems];
	[self setDoubleValue:1];
}

- (void)incrementByOne
{
	doubleValue += 1;
}

- (void)processed:(unsigned)nItem
{
	doubleValue = nItem;
}

- (void)finished
{
	[self setIsRunning:NO];
	//[progressIndicator stopAnimation:self];
	doubleValue = 0;
}

@end
