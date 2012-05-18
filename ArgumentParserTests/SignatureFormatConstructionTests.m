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

#import "FSSwitchToken.h"
#import "FSAliasToken.h"

#define FSTAssertKindOfClass(obj, ct) STAssertTrue([obj isKindOfClass:[ct class]], @"Expecting a kind of class %@; got class %@ from object %@.", NSStringFromClass([obj class]), NSStringFromClass([ct class]), obj);
#define _FSTAssertKindOfClass_Unsafe(obj, cls) \
    do { \
        id _obj = obj; /* this escapes the potential multiple invocations of popToken */ \
        STAssertTrue([_obj isKindOfClass:[cls class]], @"Expecting a kind of class %@; got class %@ from object %@.", NSStringFromClass([_obj class]), NSStringFromClass([cls class]), _obj); \
    } while (0);
#define FSTAssertKeywordEquals(token, expectation) \
    do { \
        CPKeywordToken * t = (CPKeywordToken *)token; /* this escapes the potential multiple invocations of popToken */ \
        _FSTAssertKindOfClass_Unsafe(t, CPKeywordToken); \
        STAssertEqualObjects([t keyword], expectation, @"Keyword doesn't match expectation."); \
    } while (0);
#define FSTAssertIntegerNumberEquals(token, expectation) \
    do { \
        CPNumberToken * t = (CPNumberToken *)token; /* this escapes the potential multiple invocations of popToken */ \
        _FSTAssertKindOfClass_Unsafe(t, CPNumberToken); \
        NSNumber * n = [t number]; \
        STAssertTrue(0==strcmp([n objCType], @encode(NSInteger)), @"Type expectation failure. Wanted %s, got %s.", @encode(NSInteger), [n objCType]); \
        STAssertEquals([n integerValue], ((NSInteger)expectation), @"Number fails expectation."); \
    } while (0);
#define FSTAssertSwitchEquals(token, expectation) \
    do { \
        FSSwitchToken * t = (FSSwitchToken *)token; /* this escapes the potential multiple invocations of popToken */ \
        _FSTAssertKindOfClass_Unsafe(t, FSSwitchToken); \
        STAssertEqualObjects([t identifier], expectation, @"Switch identifier doesn't match expectation."); \
    } while (0);
#define FSTAssertAliasEquals(token, expectation) \
    do { \
        FSAliasToken * t = (FSAliasToken *)token; /* this escapes the potential multiple invocations of popToken */ \
        _FSTAssertKindOfClass_Unsafe(t, FSAliasToken); \
        STAssertEqualObjects([t identifier], expectation, @"Alias identifier doesn't match expectation."); \
    } while (0);

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

- (void)testTokenizer
{
    CPTokeniser * t = [FSArgumentSignature formatTokens];
    
    STAssertNotNil(t, @"Cannot create a tokenizer.");
    
    CPTokenStream * ts;
    
    /* 
     2012-05-17 14:40:03.349 otest[5274:403] ts for "[-f --file if]={1,}": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <AliasToken: if> <Keyword: ]> <Keyword: => <Keyword: {> <Number: 1> <Keyword: ,> <Keyword: }> <EOF> 
     2012-05-17 14:40:03.349 otest[5274:403] ts for "[-f --file if]={}": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <AliasToken: if> <Keyword: ]> <Keyword: => <Keyword: {> <Keyword: }> <EOF> 
     2012-05-17 14:40:03.351 otest[5274:403] ts for "[-f --file if]=": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <AliasToken: if> <Keyword: ]> <Keyword: => <EOF> 
     2012-05-17 14:40:03.352 otest[5274:403] ts for "[-f --file if]": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <AliasToken: if> <Keyword: ]> <EOF> 
     2012-05-17 14:40:03.352 otest[5274:403] ts for "[-f -\[]": <Keyword: [> <Switch: -f> <Whitespace> <Switch: -\[> <Keyword: ]> <EOF> 
     2012-05-17 14:40:03.353 otest[5274:403] ts for "[-f -[]": <Keyword: [> <Switch: -f> <Whitespace> <Switch: -[> <Keyword: ]> <EOF> 
     2012-05-17 14:40:03.353 otest[5274:403] ts for "[-f -\]]": <Keyword: [> <Switch: -f> <Whitespace> <Switch: -\> <Keyword: ]> <Keyword: ]> <EOF> */
    
    /* 2012-05-17 14:40:03.348 otest[5274:403] ts for "[-f --file if]={1,1}": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <AliasToken: if> <Keyword: ]> <Keyword: => <Keyword: {> <Number: 1> <Keyword: ,> <Number: 1> <Keyword: }> <EOF> */
    ts = [t tokenise:@"[-f --file if]={1,1}"];
    FSTAssertKeywordEquals([ts popToken], @"["); // <Keyword: [>
    FSTAssertSwitchEquals([ts popToken], @"-f"); // <Switch: -f>
    FSTAssertKindOfClass([ts popToken], CPWhiteSpaceToken); // <Whitespace>
    FSTAssertSwitchEquals([ts popToken], @"--file"); // <Switch: --file>
    FSTAssertKindOfClass([ts popToken], CPWhiteSpaceToken); // <Whitespace>
    FSTAssertAliasEquals([ts popToken], @"if"); // <AliasToken: if>
    FSTAssertKeywordEquals([ts popToken], @"]"); // <Keyword: ]>
    FSTAssertKeywordEquals([ts popToken], @"="); // <Keyword: =>
    FSTAssertKeywordEquals([ts popToken], @"{"); // <Keyword: {>
    FSTAssertIntegerNumberEquals([ts popToken], 1); // <Number: 1>
    FSTAssertKeywordEquals([ts popToken], @","); // <Keyword: ,>
    FSTAssertIntegerNumberEquals([ts popToken], 1); // <Number: 1>
    FSTAssertKeywordEquals([ts popToken], @"}"); // <Keyword: }>
    FSTAssertKindOfClass([ts popToken], CPEOFToken); // <EOF>
    
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
