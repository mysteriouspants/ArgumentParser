//
//  SignatureFormatConstructionTests.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/14/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "SignatureFormatConstructionTests.h"

#import "FSArgumentSignature.h"
#import "FSCountedArgument.h"
#import "FSValuedArgument.h"

@implementation SignatureFormatConstructionTests

- (void)testArgumentConstruction
{
    NSDictionary * d =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNull null], @"",
     [FSValuedArgument valuedArgumentWithSwitches:[NSSet setWithObjects:@"f", @"file", nil] aliases:@"if" valuesPerInvocation:NSMakeRange(1, 1) shouldGrabBeyondBarrier:false], @"[-f --file if]={1,1:false}",
     [FSCountedArgument countedArgumentWithSwitches:[NSSet setWithObjects:@"v", @"verbose", nil] aliases:nil], @"[-v --verbose]"
     , nil];
    
    [d enumerateKeysAndObjectsUsingBlock:^(NSString * format, id expectedResult, BOOL *stop) {

        FSArgumentSignature * result = [FSArgumentSignature argumentSignatureWithFormat:format];
        
        if (expectedResult == [NSNull null])
            STAssertNil(result, @"Expectation of nil did not yield so.");
        else
            STAssertEqualObjects(expectedResult, result, @"Objects were not equal when equality was expected. expectedResult:%@ result:%@", expectedResult, result);
        
    }];
    
    NSArray * s = [NSArray arrayWithObjects:
                   @"[-f --file if]={1,1:false}",
                   @"[-f --file if]={1,1:}",
                   @"[-f --file if]={1,1}",
                   @"[-f --file if]={1,:false}",
                   @"[-f --file if]={1,:}",
                   @"[-f --file if]={:false}",
                   @"[-f --file if]={:}",
                   @"[-f --file if]={}",
                   @"[-f --file if]=",
                   @"[-f --file if]", nil];
    
    for (NSUInteger i = 0;
         i != [s count];
         ++i) {
        NSLog(@"s%lu:\"%@\" a%lu:%@", i, [s objectAtIndex:i], i, [FSArgumentSignature argumentSignatureWithFormat:[s objectAtIndex:i]]);
    }
}

@end
