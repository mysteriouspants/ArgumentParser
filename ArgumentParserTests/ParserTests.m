//
//  ParserTests.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/16/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "ParserTests.h"

#import "FSArgumentSignature.h"
#import "FSArgumentParser.h"
#import "FSArgumentPackage.h"
#import "FSArgumentPackage_Private.h"

@implementation ParserTests

- (void)testCommonCases
{
    NSArray * t0 =
    [NSArray arrayWithObjects:@"-cfg=file.txt", @"--verbose", @"refridgerator", nil];
    
    FSArgumentSignature * conflate = [FSArgumentSignature argumentSignatureWithFormat:@"[-c --conflate]"];
    FSArgumentSignature * file = [FSArgumentSignature argumentSignatureWithFormat:@"[-f --file]="];
    FSArgumentSignature * goober = [FSArgumentSignature argumentSignatureWithFormat:@"[-g --goober]"];
    FSArgumentSignature * verbose = [FSArgumentSignature argumentSignatureWithFormat:@"[-v --verbose]"];
    
    NSSet * s0 =
    [NSSet setWithObjects:conflate, file, goober, verbose, nil];
    
    FSArgumentParser * parser = [[FSArgumentParser alloc] initWithArguments:t0 signatures:s0];
    FSArgumentPackage * retVal = [parser parse];
    
    STAssertEquals([retVal countOfSignature:conflate], 1UL, @"Conflation was set only once.");
    STAssertTrue([retVal booleanValueForSignature:conflate], @"Conflation is on, dude.");
    STAssertEquals([retVal countOfSignature:file], 1UL, @"File was set only once.");
    STAssertEqualObjects([retVal firstObjectForSignature:file], @"file.txt", @"The files don't match.");
    STAssertEquals([retVal countOfSignature:goober], 1UL, @"Goober was set only once.");
    STAssertTrue([retVal booleanValueForSignature:goober], @"Goobering all over the place.");
    STAssertEquals([retVal countOfSignature:verbose], 1UL, @"Verbosity is on.");
    STAssertTrue([retVal booleanValueForSignature:verbose], @"Verbosity is on.");
    STAssertEquals([[retVal uncapturedValues] count], 1UL, @"There is an uncaptured refridgerator.");
    STAssertEqualObjects([[retVal uncapturedValues] lastObject], @"refridgerator", @"There is an uncaptured refridgerator.");
    
    
    NSLog(@"retVal = %@", [retVal prettyDescription]);
}

@end
