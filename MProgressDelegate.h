//
//  MProgressDelegate.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/04/01.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MProgressDelegate : NSObject {
	double minValue, maxValue, doubleValue;
	BOOL isRunning;
}

+ (MProgressDelegate *)progressDelegate;

- (double)minValue;
- (void)setMinValue:(double)value;

- (double)minValue;
- (void)setMinValue:(double)value;

- (double)minValue;
- (void)setMinValue:(double)value;

- (BOOL)isRunning;
- (void)setIsRunning:(BOOL)value;

- (void)started;
- (void)startedProcessing:(unsigned)nItems;
- (void)incrementByOne;
- (void)processed:(unsigned)nItems;
- (void)finished;

@end
