//
//  XPMPackageTests.m
//  ArgumentParser
//
//  Created by Chris Miller on 2/5/15.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "FSArgumentSignature.h"
#import "FSCountedArgument.h"
#import "FSValuedArgument.h"

#import "FSArgumentPackage.h"
#import "FSArgumentPackage_Private.h"

@interface XPMPackageTests : XCTestCase

@end

@implementation XPMPackageTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCountedArguments
{
  FSArgumentSignature * verbose = [FSArgumentSignature argumentSignatureWithFormat:@"[-v --verbose]"];
  FSArgumentPackage * package = [[FSArgumentPackage alloc] init];
  
  XCTAssertEqual([package booleanValueForSignature:verbose], (bool)false, @"Verbosity hasn't been enabled yet!");
  XCTAssertEqual([package countOfSignature:verbose], 0UL, @"Verbosity should be zero.");
  
  [package incrementCountOfSignature:verbose];
  
  XCTAssertEqual([package booleanValueForSignature:verbose], (bool)true, @"Verbosity has been set!");
  XCTAssertEqual([package countOfSignature:verbose], 1UL, @"Verbosity should be one");
  
  [package incrementCountOfSignature:verbose];
  
  XCTAssertEqual([package booleanValueForSignature:verbose], (bool)true, @"Verbosity has been set twice.");
  XCTAssertEqual([package countOfSignature:verbose], 2UL, @"Verbosity has been set twice.");
}

- (void)testValuedArguments
{
  FSArgumentSignature * file = [FSArgumentSignature argumentSignatureWithFormat:@"[-f --file]="];
  FSArgumentPackage * package = [[FSArgumentPackage alloc] init];
  
  XCTAssertEqual([package countOfSignature:file], 0UL, @"No files.");
  XCTAssertNil([package firstObjectForSignature:file], @"No files.");
  XCTAssertNil([package lastObjectForSignature:file], @"No files.");
  
  NSUInteger expectedCount = 0;
  for (NSString * value in [NSSet setWithObjects:@"file0.txt", @"file1.txt", @"file2.txt", nil]) {
    [package addObject:value toSignature:file]; ++expectedCount;
    
    XCTAssertEqual([package countOfSignature:file], expectedCount, @"Count mismatch.");
    if (expectedCount == 1) XCTAssertEqualObjects([package firstObjectForSignature:file], value, @"File mismatch.");
    XCTAssertEqualObjects([package objectAtIndex:expectedCount-1 forSignature:file], value, @"File mismatch.");
    XCTAssertEqualObjects([package lastObjectForSignature:file], value, @"File mismatch.");
  }
}

@end
