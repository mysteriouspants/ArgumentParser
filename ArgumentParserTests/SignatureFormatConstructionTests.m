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

#define FSTAssertKindOfClass(obj, cls) \
    do { \
        id _obj = obj; /* this escapes the potential multiple invocations of popToken */ \
        STAssertTrue([_obj isKindOfClass:[cls class]], @"Expecting a kind of class %@; got class %@ from object %@.", NSStringFromClass([_obj class]), NSStringFromClass([cls class]), _obj); \
    } while (0);
#define _FSTAssertKindOfClass_Unsafe(obj, cls) STAssertTrue([obj isKindOfClass:[cls class]], @"Expecting a kind of class %@; got class %@ from object %@.", NSStringFromClass([obj class]), NSStringFromClass([cls class]), obj);
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
    
    /* 2012-05-17 14:40:03.348 otest[5274:403] ts for "[-f --file if]={1,1}": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <Alias: if> <Keyword: ]> <Keyword: => <Keyword: {> <Number: 1> <Keyword: ,> <Number: 1> <Keyword: }> <EOF> */
    ts = [t tokenise:@"[-f --file if]={1,1}"];
    FSTAssertKeywordEquals([ts popToken], @"[");
    FSTAssertSwitchEquals([ts popToken], @"-f");
    FSTAssertKindOfClass([ts popToken], CPWhiteSpaceToken);
    FSTAssertSwitchEquals([ts popToken], @"--file");
    FSTAssertKindOfClass([ts popToken], CPWhiteSpaceToken);
    FSTAssertAliasEquals([ts popToken], @"if");
    FSTAssertKeywordEquals([ts popToken], @"]");
    FSTAssertKeywordEquals([ts popToken], @"=");
    FSTAssertKeywordEquals([ts popToken], @"{");
    FSTAssertIntegerNumberEquals([ts popToken], 1);
    FSTAssertKeywordEquals([ts popToken], @",");
    FSTAssertIntegerNumberEquals([ts popToken], 1);
    FSTAssertKeywordEquals([ts popToken], @"}");
    FSTAssertKindOfClass([ts popToken], CPEOFToken);
    
    /* 2012-05-17 14:40:03.349 otest[5274:403] ts for "[-f --file if]={1,}": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <Alias: if> <Keyword: ]> <Keyword: => <Keyword: {> <Number: 1> <Keyword: ,> <Keyword: }> <EOF> */
    ts = [t tokenise:@"[-f --file if]={1,}"];
    FSTAssertKeywordEquals([ts popToken], @"[");
    FSTAssertSwitchEquals([ts popToken], @"-f");
    FSTAssertKindOfClass([ts popToken], CPWhiteSpaceToken);
    FSTAssertSwitchEquals([ts popToken], @"--file");
    FSTAssertKindOfClass([ts popToken], CPWhiteSpaceToken);
    FSTAssertAliasEquals([ts popToken], @"if");
    FSTAssertKeywordEquals([ts popToken], @"]");
    FSTAssertKeywordEquals([ts popToken], @"=");
    FSTAssertKeywordEquals([ts popToken], @"{");
    FSTAssertIntegerNumberEquals([ts popToken], 1);
    FSTAssertKeywordEquals([ts popToken], @",");
    FSTAssertKeywordEquals([ts popToken], @"}");
    FSTAssertKindOfClass([ts popToken], CPEOFToken);
    
    /* 2012-05-17 14:40:03.349 otest[5274:403] ts for "[-f --file if]={}": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <Alias: if> <Keyword: ]> <Keyword: => <Keyword: {> <Keyword: }> <EOF> */
    ts = [t tokenise:@"[-f --file if]={}"];
    FSTAssertKeywordEquals([ts popToken], @"[");
    FSTAssertSwitchEquals([ts popToken], @"-f");
    FSTAssertKindOfClass([ts popToken], CPWhiteSpaceToken);
    FSTAssertSwitchEquals([ts popToken], @"--file");
    FSTAssertKindOfClass([ts popToken], CPWhiteSpaceToken);
    FSTAssertAliasEquals([ts popToken], @"if");
    FSTAssertKeywordEquals([ts popToken], @"]");
    FSTAssertKeywordEquals([ts popToken], @"=");
    FSTAssertKeywordEquals([ts popToken], @"{");
    FSTAssertKeywordEquals([ts popToken], @"}");
    FSTAssertKindOfClass([ts popToken], CPEOFToken);
    
    /* 2012-05-17 14:40:03.351 otest[5274:403] ts for "[-f --file if]=": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <Alias: if> <Keyword: ]> <Keyword: => <EOF> */
    ts = [t tokenise:@"[-f --file if]="];
    FSTAssertKeywordEquals([ts popToken], @"[");
    FSTAssertSwitchEquals([ts popToken], @"-f");
    FSTAssertKindOfClass([ts popToken], CPWhiteSpaceToken);
    FSTAssertSwitchEquals([ts popToken], @"--file");
    FSTAssertKindOfClass([ts popToken], CPWhiteSpaceToken);
    FSTAssertAliasEquals([ts popToken], @"if");
    FSTAssertKeywordEquals([ts popToken], @"]");
    FSTAssertKeywordEquals([ts popToken], @"=");
    FSTAssertKindOfClass([ts popToken], CPEOFToken);
    
    /* 2012-05-17 14:40:03.352 otest[5274:403] ts for "[-f --file if]": <Keyword: [> <Switch: -f> <Whitespace> <Switch: --file> <Whitespace> <Alias: if> <Keyword: ]> <EOF> */
    ts = [t tokenise:@"[-f --file if]"];
    FSTAssertKeywordEquals([ts popToken], @"[");
    FSTAssertSwitchEquals([ts popToken], @"-f");
    FSTAssertKindOfClass([ts popToken], CPWhiteSpaceToken);
    FSTAssertSwitchEquals([ts popToken], @"--file");
    FSTAssertKindOfClass([ts popToken], CPWhiteSpaceToken);
    FSTAssertAliasEquals([ts popToken], @"if");
    FSTAssertKeywordEquals([ts popToken], @"]");
    FSTAssertKindOfClass([ts popToken], CPEOFToken);
    
    // a very specific test case for improperly escaped characters in flag-style switches
    /* 2012-05-18 10:25:14.578 otest[2800:403] ts: <Keyword: [> <Error> */
    ts = [t tokenise:@"[-\\[]"];
    FSTAssertKeywordEquals([ts popToken], @"[");
    FSTAssertKindOfClass([ts popToken], CPErrorToken);
    
    /* 2012-05-17 14:40:03.353 otest[5274:403] ts for "[-[]": <Keyword: [> <Switch: -[> <Keyword: ]> <EOF> */
    ts = [t tokenise:@"[-[]"];
    FSTAssertKeywordEquals([ts popToken], @"[");
    FSTAssertSwitchEquals([ts popToken], @"-[");
    FSTAssertKeywordEquals([ts popToken], @"]");
    FSTAssertKindOfClass([ts popToken], CPEOFToken);
    
    /* 2012-05-18 10:30:45.854 otest[2925:403] ts: <Keyword: [> <Switch: -]> <Keyword: ]> <EOF> */
    ts = [t tokenise:@"[-\\]]"];
    FSTAssertKeywordEquals([ts popToken], @"[");
    FSTAssertSwitchEquals([ts popToken], @"-]");
    FSTAssertKeywordEquals([ts popToken], @"]");
    FSTAssertKindOfClass([ts popToken], CPEOFToken);
}

@end
