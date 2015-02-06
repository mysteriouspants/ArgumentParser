//
//  XPMParserTests.m
//  ArgumentParser
//
//  Created by Chris Miller on 2/5/15.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "FSArgumentSignature.h"
#import "FSArgumentParser.h"
#import "FSArgumentPackage.h"
#import "FSArgumentPackage_Private.h"

// Utilize http://www.ruby-doc.org/stdlib-2.0.0/libdoc/shellwords/rdoc/Shellwords.html#method-c-shellsplit
// to perform full tests?

@interface XPMParserTests : XCTestCase

@end

@implementation XPMParserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCommonCases
{
  NSArray * t0 = @[@"-cfg=file.txt", @"--verbose", @"refridgerator"];
  
  FSArgumentSignature * conflate = [FSArgumentSignature argumentSignatureWithFormat:@"[-c --conflate]"];
  FSArgumentSignature * file = [FSArgumentSignature argumentSignatureWithFormat:@"[-f --file]="];
  FSArgumentSignature * goober = [FSArgumentSignature argumentSignatureWithFormat:@"[-g --goober]"];
  FSArgumentSignature * verbose = [FSArgumentSignature argumentSignatureWithFormat:@"[-v --verbose]"];
  
  NSSet * s0 =
  [NSSet setWithObjects:conflate, file, goober, verbose, nil];
  
  FSArgumentParser * parser = [[FSArgumentParser alloc] initWithArguments:t0 signatures:s0];
  FSArgumentPackage * retVal = [parser parse];
  
  XCTAssertEqual([retVal countOfSignature:conflate], 1UL, @"Conflation was set only once.");
  XCTAssertTrue([retVal booleanValueForSignature:conflate], @"Conflation is on, dude.");
  XCTAssertEqual([retVal countOfSignature:file], 1UL, @"File was set only once.");
  XCTAssertEqualObjects([retVal firstObjectForSignature:file], @"file.txt", @"The files don't match.");
  XCTAssertEqual([retVal countOfSignature:goober], 1UL, @"Goober was set only once.");
  XCTAssertTrue([retVal booleanValueForSignature:goober], @"Goobering all over the place.");
  XCTAssertEqual([retVal countOfSignature:verbose], 1UL, @"Verbosity is on.");
  XCTAssertTrue([retVal booleanValueForSignature:verbose], @"Verbosity is on.");
  XCTAssertEqual([[retVal uncapturedValues] count], 1UL, @"There is an uncaptured refridgerator.");
  XCTAssertEqualObjects([[retVal uncapturedValues] lastObject], @"refridgerator", @"There is an uncaptured refridgerator.");
  XCTAssertEqual([[retVal unknownSwitches] count], 0UL, @"There were no unknown switches.");
}

- (void)testWeirdCases
{
  NSArray * t0 =
  [NSArray arrayWithObjects:@"-[", @"foo", @"bar", @"-]", nil];
  
  FSArgumentSignature * lbracket = [FSArgumentSignature argumentSignatureWithFormat:@"[-[]={1,}"];
  FSArgumentSignature * rbracket = [FSArgumentSignature argumentSignatureWithFormat:@"[-\\]]"];
  
  NSLog(@"%@", lbracket);
  
  NSSet * s0 =
  [NSSet setWithObjects:lbracket, rbracket, nil];
  
  FSArgumentParser * parser = [[FSArgumentParser alloc] initWithArguments:t0 signatures:s0];
  FSArgumentPackage * retVal = [parser parse];
  
  XCTAssertEqual([retVal countOfSignature:lbracket], 2UL, @"Only foo and bar were given.");
  XCTAssertEqualObjects([retVal firstObjectForSignature:lbracket], @"foo", @"Should be foo.");
  XCTAssertEqualObjects([retVal lastObjectForSignature:lbracket], @"bar", @"Should be bar.");
  XCTAssertEqual([retVal countOfSignature:rbracket], 1UL, @"Only one rbracket was set.");
  XCTAssertEqual([[retVal uncapturedValues] count], 0UL, @"There are no values that shouldn't have been captured.");
  XCTAssertEqual([[retVal unknownSwitches] count], 0UL, @"There were no unknown switches.");
}

@end
