//
//  AttributedArrayTests.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/15/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "AttributedArrayTests.h"
#import "FSMutableAttributedArray.h"

@implementation AttributedArrayTests

- (void)testAddition
{
    FSMutableAttributedArray * a = [FSMutableAttributedArray attributedArrayWithCapacity:2];
    
    [a addObject:@"one" withAttributes:nil];
    [a addObject:@"two" withAttributes:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
    
    STAssertEqualObjects(@"one", [a objectAtIndex:0], @"Goof.");
    STAssertNotNil([a attributesOfObjectAtIndex:0], @"This really shouldn't be nil.");
    STAssertTrue([[a attributesOfObjectAtIndex:0] count] == 0, @"Why is this not zero?");
    
    STAssertEqualObjects(@"two", [a objectAtIndex:1], @"Goof.");
    STAssertNotNil([a attributesOfObjectAtIndex:1], @"This really shouldn't be nil.");
    STAssertTrue([[a attributesOfObjectAtIndex:1] count] == 1, @"Why is this not one?");
}

@end
