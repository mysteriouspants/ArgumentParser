//
//  SignatureFormatConstructionTests.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/14/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "SignatureFormatConstructionTests.h"

#import "CoreParse.h"

#import "FSArgumentSignature.h"
#import "FSArgumentSignature_Private.h"
#import "FSCountedArgument.h"
#import "FSValuedArgument.h"

@implementation SignatureFormatConstructionTests

- (void)testArgumentConstruction
{
    NSDictionary * d =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNull null], @"",
     [FSValuedArgument valuedArgumentWithSwitches:[NSSet setWithObjects:@"f", @"file", nil] aliases:@"if" valuesPerInvocation:NSMakeRange(1, 1)], @"[-f --file if]={1,1}",
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
                   @"[-f --file if]={1,1}",
                   @"[-f --file if]={}",
                   @"[-f --file if]=",
                   @"[-f --file if]", nil];
    
    for (NSUInteger i = 0;
         i != [s count];
         ++i) {
        NSLog(@"s%lu:\"%@\" a%lu:%@", i, [s objectAtIndex:i], i, [FSArgumentSignature argumentSignatureWithFormat:[s objectAtIndex:i]]);
    }
}

#define FSTAssertKindOfClass(obj, ct) STAssertTrue([obj isKindOfClass:[ct class]], @"Expecting class %@, got %@ (%@).", NSStringFromClass([obj class]), NSStringFromClass([ct class]), obj);

- (void)testTokenizer
{
    CPTokeniser * t = [FSArgumentSignature formatTokens];
    
    STAssertNotNil(t, @"Cannot create a tokenizer.");
    
    CPTokenStream * ts = [t tokenise:@"[-f --file if]={1,1}"];
    CPToken * tk = [ts popToken];
    
    /*2012-05-17 14:40:03.348 otest[5274:403] ts for "[-f --file if]={1,1}": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <AliasToken: if> <Keyword: ]> <Keyword: => <Keyword: {> <Number: 1> <Keyword: ,> <Number: 1> <Keyword: }> <EOF> 
     2012-05-17 14:40:03.349 otest[5274:403] ts for "[-f --file if]={1,}": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <AliasToken: if> <Keyword: ]> <Keyword: => <Keyword: {> <Number: 1> <Keyword: ,> <Keyword: }> <EOF> 
     2012-05-17 14:40:03.349 otest[5274:403] ts for "[-f --file if]={}": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <AliasToken: if> <Keyword: ]> <Keyword: => <Keyword: {> <Keyword: }> <EOF> 
     2012-05-17 14:40:03.351 otest[5274:403] ts for "[-f --file if]=": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <AliasToken: if> <Keyword: ]> <Keyword: => <EOF> 
     2012-05-17 14:40:03.352 otest[5274:403] ts for "[-f --file if]": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <AliasToken: if> <Keyword: ]> <EOF> 
     2012-05-17 14:40:03.352 otest[5274:403] ts for "[-f -\[]": <Keyword: [> <Switch: -f> <Whitespace> <Switch: -\[> <Keyword: ]> <EOF> 
     2012-05-17 14:40:03.353 otest[5274:403] ts for "[-f -[]": <Keyword: [> <Switch: -f> <Whitespace> <Switch: -[> <Keyword: ]> <EOF> 
     2012-05-17 14:40:03.353 otest[5274:403] ts for "[-f -\]]": <Keyword: [> <Switch: -f> <Whitespace> <Switch: -\> <Keyword: ]> <Keyword: ]> <EOF> */
    if ([tk isKindOfClass:[CPKeywordToken class]])
        STAssertTrue(YES==NO,@"Penis.");
    FSTAssertKindOfClass(tk, CPKeywordToken);
    
    
    
    NSArray * s = [NSArray arrayWithObjects:
                   @"[-f --file if]={1,1}",
                   @"[-f --file if]={1,}",
                   @"[-f --file if]={}",
                   @"[-f --file if]=",
                   @"[-f --file if]",
                   @"[-f -\\[]", // some weird ones
                   @"[-f -[]",
                   @"[-f -\\]]", nil];
    
    for (NSString * si in s) {
        CPTokenStream * ts = [t tokenise:si];
        NSLog(@"ts for \"%@\": %@", si, ts);
    }
}

@end
