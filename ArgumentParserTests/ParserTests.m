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

@implementation ParserTests

- (void)testCommonCases
{
    NSArray * t0 =
    [NSArray arrayWithObjects:@"-cfg=file.txt", @"--verbose", @"refridgerator", nil];
    
    NSSet * s0 =
    [NSSet setWithObjects:[FSArgumentSignature argumentSignatureWithFormat:@"[-c --conflate]"], [FSArgumentSignature argumentSignatureWithFormat:@"[-f --file]="], [FSArgumentSignature argumentSignatureWithFormat:@"[-g --goober]"], [FSArgumentSignature argumentSignatureWithFormat:@"[-v --verbose]"], nil];
    
    FSArgumentParser * parser = [[FSArgumentParser alloc] initWithArguments:t0 signatures:s0];
    id retVal = [parser parse];
    
    NSLog(@"retVal = %@", retVal);
}

@end
