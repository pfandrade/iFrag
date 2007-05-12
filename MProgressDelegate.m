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

- (id) init {
	self = [super init];
	if (self != nil) {
		progressIndicator = [CToxicProgressIndicator new];
		[progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
		[progressIndicator setDisplayedWhenStopped:NO];
		[progressIndicator setHidden:YES];
		[progressIndicator setUsesThreadedAnimation:YES];
		[(CToxicProgressIndicator *)progressIndicator setStepCount:0];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder 
{
	self = [super init];
	if(self != nil){
		progressIndicator = [[coder decodeObjectForKey:@"MProgressIndicator"] retain];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:progressIndicator forKey:@"MProgressIndicator"];
}

- (NSProgressIndicator *)progressIndicator {
    return [[progressIndicator retain] autorelease];
}

- (void)setProgressIndicator:(NSProgressIndicator *)value {
    if (progressIndicator != value) {
        [progressIndicator release];
        progressIndicator = [value retain];
    }
}

- (void)started
{
	[progressIndicator setHidden:NO];
	[progressIndicator setNeedsDisplay:YES];
	[progressIndicator startAnimation:self];
	[progressIndicator setIndeterminate:YES];
}

- (void)startedProcessing:(unsigned)nItems
{
	[self started];
	if(nItems < 10) //it's not worth it :
		return;
	[progressIndicator setMinValue:1];
	[progressIndicator setMaxValue:(double)nItems];
	[progressIndicator setDoubleValue:1];
	[progressIndicator stopAnimation:self];
	[progressIndicator setIndeterminate:NO];
}

- (void)incrementByOne
{
	[progressIndicator incrementBy:1];
}

- (void)processed:(unsigned)nItem
{
	[progressIndicator setDoubleValue:(double)nItem];
}

- (void)finished
{
	[progressIndicator displayIfNeeded];
	[progressIndicator setIndeterminate:YES];
	[progressIndicator setHidden:YES];
	[progressIndicator stopAnimation:self];
	[progressIndicator setDoubleValue:0];
}

@end
