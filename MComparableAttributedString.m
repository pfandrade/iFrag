//
//  MComparableAttributedString.m
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/03/10.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import "MComparableAttributedString.h"


@implementation NSAttributedString (Comparable)

- (NSComparisonResult)compare:(NSAttributedString *)aString
{
	return [[self string] compare:[aString string]];
}

- (NSComparisonResult)compare:(NSAttributedString *)aString options:(unsigned)mask
{
	return [[self string] compare:[aString string] options:mask];
}

- (NSComparisonResult)compare:(NSAttributedString *)aString options:(unsigned)mask range:(NSRange)range
{
	return [[self string] compare:[aString string] options:mask range:range];
}

@end
