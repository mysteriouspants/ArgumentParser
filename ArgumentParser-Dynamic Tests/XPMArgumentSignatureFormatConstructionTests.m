//
//  XPMArgumentSignatureFormatConstructionTests.m
//  ArgumentParser
//
//  Created by Chris Miller on 2/5/15.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

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
XCTAssertTrue([_obj isKindOfClass:[cls class]], @"Expecting a kind of class %@; got class %@ from object %@.", NSStringFromClass([_obj class]), NSStringFromClass([cls class]), _obj); \
} while (0)
#define _FSTAssertKindOfClass_Unsafe(obj, cls) XCTAssertTrue([obj isKindOfClass:[cls class]], @"Expecting a kind of class %@; got class %@ from object %@.", NSStringFromClass([obj class]), NSStringFromClass([cls class]), obj);
#define FSTAssertKeywordEquals(token, expectation) \
do { \
CPKeywordToken * t = (CPKeywordToken *)token; /* this escapes the potential multiple invocations of popToken */ \
_FSTAssertKindOfClass_Unsafe(t, CPKeywordToken); \
XCTAssertEqualObjects([t keyword], expectation, @"Keyword doesn't match expectation."); \
} while (0)
#define FSTAssertIntegerNumberEquals(token, expectation) \
do { \
CPNumberToken * t = (CPNumberToken *)token; /* this escapes the potential multiple invocations of popToken */ \
_FSTAssertKindOfClass_Unsafe(t, CPNumberToken); \
NSNumber * n = [t number]; \
XCTAssertTrue(0==strcmp([n objCType], @encode(NSInteger)), @"Type expectation failure. Wanted %s, got %s.", @encode(NSInteger), [n objCType]); \
XCTAssertEqual([n integerValue], ((NSInteger)expectation), @"Number fails expectation."); \
} while (0)
#define FSTAssertSwitchEquals(token, expectation) \
do { \
FSSwitchToken * t = (FSSwitchToken *)token; /* this escapes the potential multiple invocations of popToken */ \
_FSTAssertKindOfClass_Unsafe(t, FSSwitchToken); \
XCTAssertEqualObjects([t identifier], expectation, @"Switch identifier doesn't match expectation."); \
} while (0)
#define FSTAssertAliasEquals(token, expectation) \
do { \
FSAliasToken * t = (FSAliasToken *)token; /* this escapes the potential multiple invocations of popToken */ \
_FSTAssertKindOfClass_Unsafe(t, FSAliasToken); \
XCTAssertEqualObjects([t identifier], expectation, @"Alias identifier doesn't match expectation."); \
} while (0)

@interface XPMArgumentSignatureFormatConstructionTests : XCTestCase

@end

@implementation XPMArgumentSignatureFormatConstructionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTokenizerAndDelegate
{
  CPTokeniser * t = [FSArgumentSignature formatTokens];
  
  XCTAssertNotNil(t, @"Cannot create a tokenizer.");
  XCTAssertNotNil([t delegate], @"Cannot create a tokenizer delegate.");
  
  CPTokenStream * ts;
  
  /* 2012-05-17 14:40:03.348 otest[5274:403] ts for "[-f --file if]={1,1}": <Keyword: [> <Switch: -f> <Switch: --file> <Alias: if> <Keyword: ]> <Keyword: => <Keyword: {> <Number: 1> <Keyword: ,> <Number: 1> <Keyword: }> <EOF> */
  ts = [t tokenise:@"[-f --file if]={1,1}"];
  FSTAssertKeywordEquals([ts popToken], @"[");
  FSTAssertSwitchEquals([ts popToken], @"-f");
  FSTAssertSwitchEquals([ts popToken], @"--file");
  FSTAssertAliasEquals([ts popToken], @"if");
  FSTAssertKeywordEquals([ts popToken], @"]");
  FSTAssertKeywordEquals([ts popToken], @"=");
  FSTAssertKeywordEquals([ts popToken], @"{");
  FSTAssertIntegerNumberEquals([ts popToken], 1);
  FSTAssertKeywordEquals([ts popToken], @",");
  FSTAssertIntegerNumberEquals([ts popToken], 1);
  FSTAssertKeywordEquals([ts popToken], @"}");
  FSTAssertKindOfClass([ts popToken], CPEOFToken);
  
  /* 2012-05-17 14:40:03.349 otest[5274:403] ts for "[-f --file if]={1,}": <Keyword: [> <Switch: -f> <Switch: --file> <Alias: if> <Keyword: ]> <Keyword: => <Keyword: {> <Number: 1> <Keyword: ,> <Keyword: }> <EOF> */
  ts = [t tokenise:@"[-f --file if]={1,}"];
  FSTAssertKeywordEquals([ts popToken], @"[");
  FSTAssertSwitchEquals([ts popToken], @"-f");
  FSTAssertSwitchEquals([ts popToken], @"--file");
  FSTAssertAliasEquals([ts popToken], @"if");
  FSTAssertKeywordEquals([ts popToken], @"]");
  FSTAssertKeywordEquals([ts popToken], @"=");
  FSTAssertKeywordEquals([ts popToken], @"{");
  FSTAssertIntegerNumberEquals([ts popToken], 1);
  FSTAssertKeywordEquals([ts popToken], @",");
  FSTAssertKeywordEquals([ts popToken], @"}");
  FSTAssertKindOfClass([ts popToken], CPEOFToken);
  
  /* 2012-05-17 14:40:03.349 otest[5274:403] ts for "[-f --file if]={}": <Keyword: [> <Switch: -f> <Switch: --file> <Alias: if> <Keyword: ]> <Keyword: => <Keyword: {> <Keyword: }> <EOF> */
  ts = [t tokenise:@"[-f --file if]={}"];
  FSTAssertKeywordEquals([ts popToken], @"[");
  FSTAssertSwitchEquals([ts popToken], @"-f");
  FSTAssertSwitchEquals([ts popToken], @"--file");
  FSTAssertAliasEquals([ts popToken], @"if");
  FSTAssertKeywordEquals([ts popToken], @"]");
  FSTAssertKeywordEquals([ts popToken], @"=");
  FSTAssertKeywordEquals([ts popToken], @"{");
  FSTAssertKeywordEquals([ts popToken], @"}");
  FSTAssertKindOfClass([ts popToken], CPEOFToken);
  
  /* 2012-05-17 14:40:03.351 otest[5274:403] ts for "[-f --file if]=": <Keyword: [> <Switch: -f> <Switch: --file> <Alias: if> <Keyword: ]> <Keyword: => <EOF> */
  ts = [t tokenise:@"[-f --file if]="];
  FSTAssertKeywordEquals([ts popToken], @"[");
  FSTAssertSwitchEquals([ts popToken], @"-f");
  FSTAssertSwitchEquals([ts popToken], @"--file");
  FSTAssertAliasEquals([ts popToken], @"if");
  FSTAssertKeywordEquals([ts popToken], @"]");
  FSTAssertKeywordEquals([ts popToken], @"=");
  FSTAssertKindOfClass([ts popToken], CPEOFToken);
  
  /* 2012-05-17 14:40:03.352 otest[5274:403] ts for "[-f --file if]": <Keyword: [> <Switch: -f> <Switch: --file> <Alias: if> <Keyword: ]> <EOF> */
  ts = [t tokenise:@"[-f --file if]"];
  FSTAssertKeywordEquals([ts popToken], @"[");
  FSTAssertSwitchEquals([ts popToken], @"-f");
  FSTAssertSwitchEquals([ts popToken], @"--file");
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

- (void)testGrammar
{
  XCTAssertNotNil([FSArgumentSignature formatGrammar], @"Format grammar was nil. That can't be good.");
}

- (void)testParser
{
  FSArgumentSignature * format;
  FSArgumentSignature * expected;
  
  format = [FSArgumentSignature argumentSignatureWithFormat:@"[-f --file if]={1,5}"];
  expected = [FSValuedArgument valuedArgumentWithSwitches:[NSSet setWithObjects:@"f", @"file", nil] aliases:[NSSet setWithObject:@"if"] valuesPerInvocation:NSMakeRange(1, 5)];
  XCTAssertEqualObjects(format, expected, @"Format constructor failure.");
  
  format = [FSArgumentSignature argumentSignatureWithFormat:@"[-f --file if]={1,}"];
  expected = [FSValuedArgument valuedArgumentWithSwitches:[NSSet setWithObjects:@"f", @"file", nil] aliases:[NSSet setWithObject:@"if"] valuesPerInvocation:NSMakeRange(1, NSNotFound)];
  XCTAssertEqualObjects(format, expected, @"Format constructor failure.");
  
  format = [FSArgumentSignature argumentSignatureWithFormat:@"[-f --file if]="];
  expected = [FSValuedArgument valuedArgumentWithSwitches:[NSSet setWithObjects:@"f", @"file", nil] aliases:[NSSet setWithObject:@"if"] valuesPerInvocation:NSMakeRange(1, 1)];
  XCTAssertEqualObjects(format, expected, @"Format constructor failure.");
  
  format = [FSArgumentSignature argumentSignatureWithFormat:@"[-f --file if]"];
  expected = [FSCountedArgument countedArgumentWithSwitches:[NSSet setWithObjects:@"f", @"file", nil] aliases:[NSSet setWithObject:@"if"]];
  
  XCTAssertEqualObjects(format, expected, @"Format constructor failure.");
}


@end
