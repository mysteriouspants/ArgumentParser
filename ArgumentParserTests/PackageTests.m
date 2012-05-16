//
//  PackageTests.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/16/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "PackageTests.h"

#import "FSArgumentSignature.h"
#import "FSCountedArgument.h"
#import "FSValuedArgument.h"

#import "FSArgumentPackage.h"
#import "FSArgumentPackage_Private.h"

@implementation PackageTests

- (void)testCountedArguments
{
    FSArgumentSignature * verbose = [FSArgumentSignature argumentSignatureWithFormat:@"[-v --verbose]"];
    FSArgumentPackage * package = [[FSArgumentPackage alloc] init];
    
    STAssertEquals([package booleanValueForSignature:verbose], (bool)false, @"Verbosity hasn't been enabled yet!");
    STAssertEquals([package countOfSignature:verbose], 0UL, @"Verbosity should be zero.");
    
    [package incrementCountOfSignature:verbose];
    
    STAssertEquals([package booleanValueForSignature:verbose], (bool)true, @"Verbosity has been set!");
    STAssertEquals([package countOfSignature:verbose], 1UL, @"Verbosity should be one");
    
    [package incrementCountOfSignature:verbose];
    
    STAssertEquals([package booleanValueForSignature:verbose], (bool)true, @"Verbosity has been set twice.");
    STAssertEquals([package countOfSignature:verbose], 2UL, @"Verbosity has been set twice.");
}

- (void)testValuedArguments
{
    FSArgumentSignature * file = [FSArgumentSignature argumentSignatureWithFormat:@"[-f --file]="];
    FSArgumentPackage * package = [[FSArgumentPackage alloc] init];
    
    STAssertEquals([package countOfSignature:file], 0UL, @"No files.");
    STAssertNil([package firstObjectForSignature:file], @"No files.");
    STAssertNil([package lastObjectForSignature:file], @"No files.");
    
    NSUInteger expectedCount = 0;
    for (NSString * value in [NSSet setWithObjects:@"file0.txt", @"file1.txt", @"file2.txt", nil]) {
        [package addObject:value toSignature:file]; ++expectedCount;
        
        STAssertEquals([package countOfSignature:file], expectedCount, @"Count mismatch.");
        if (expectedCount == 1) STAssertEqualObjects([package firstObjectForSignature:file], value, @"File mismatch.");
        STAssertEqualObjects([package objectAtIndex:expectedCount-1 forSignature:file], value, @"File mismatch.");
        STAssertEqualObjects([package lastObjectForSignature:file], value, @"File mismatch.");
    }
}

@end
