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
    
    STAssertTrue([package booleanValueForSignature:verbose] == false, @"Verbosity hasn't been enabled yet!");
    STAssertTrue([package countOfSignature:verbose] == 0, @"Verbosity should be zero.");
    
    [package incrementCountOfSignature:verbose];
    
    STAssertTrue([package booleanValueForSignature:verbose] == true, @"Verbosity has been set!");
    STAssertTrue([package countOfSignature:verbose] == 1, @"Verbosity should be one");
    
    [package incrementCountOfSignature:verbose];
    
    STAssertTrue([package booleanValueForSignature:verbose] == true, @"Verbosity has been set twice.");
    STAssertTrue([package countOfSignature:verbose], @"Verbosity has been set twice.");
}

@end
