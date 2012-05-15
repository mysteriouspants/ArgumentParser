//
//  ArgumentNormalizerTests.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/15/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "ArgumentNormalizerTests.h"
#import "FSMutableAttributedArray.h"
#import "NSArray+FSArgumentsNormalizer.h"

@implementation ArgumentNormalizerTests

- (void)testNormalizer
{
    NSArray * inputs =
    [NSArray arrayWithObjects:
     [NSArray arrayWithObjects:@"-cfg", @"--file", @"foo", @"--", @"--asplode", nil],
     [NSArray arrayWithObjects:@"-cfg", @"--file=foo", @"--", @"--asplode", nil], nil];
    
    NSArray * expectedOutputs =
    [NSArray arrayWithObjects:
     [NSNull null], nil];
    
    [inputs enumerateObjectsUsingBlock:^(NSArray * input, NSUInteger idx, BOOL *stop) {
        FSMutableAttributedArray * actualResult = [input fsargs_normalize];
        NSLog(@"%@: %@", [input componentsJoinedByString:@" "], actualResult);
    }];
    
}

@end
