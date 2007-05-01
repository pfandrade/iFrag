//
//  MComparableAttributedString.h
//  iFrag
//
//  Created by Paulo Filipe Andrade on 07/03/10.
//  Copyright 2007 Maracuja Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAttributedString (Comparable)

- (NSComparisonResult)compare:(NSAttributedString *)aString;
- (NSComparisonResult)compare:(NSAttributedString *)aString options:(unsigned)mask;
- (NSComparisonResult)compare:(NSAttributedString *)aString options:(unsigned)mask range:(NSRange)range;

@end
