//
//  XPMArgumentNormalizerTests.m
//  ArgumentParser
//
//  Created by Chris Miller on 2/5/15.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "FSMutableAttributedArray.h"
#import "NSArray+FSArgumentsNormalizer.h"
#import "FSArgsKonstants.h"

#define FSTExpectValueAt(array, location, expectedValue) XCTAssertEqualObjects([array objectAtIndex:location], expectedValue, @"Mismatched argument.");
#define FSTExpectTypeAt(array, location, expectedType) XCTAssertEqualObjects([array valueOfAttribute:__fsargs_typeKey forObjectAtIndex:location], expectedType, @"Mismatched type.");

@interface XPMArgumentNormalizerTests : XCTestCase

@end

@implementation XPMArgumentNormalizerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNormalizerCommonCases
{
  FSMutableAttributedArray * array = [[NSArray arrayWithObjects:@"-cfg", @"--file", @"foo", @"--", @"--asplode", nil] fsargs_normalize];
  XCTAssertEqual([array count], 7UL, @"Expecting seven elements!");
  FSTExpectValueAt(array, 0, @"-c");
  FSTExpectTypeAt(array, 0, __fsargs_switch);
  FSTExpectValueAt(array, 1, @"-f");
  FSTExpectTypeAt(array, 1, __fsargs_switch);
  FSTExpectValueAt(array, 2, @"-g");
  FSTExpectTypeAt(array, 2, __fsargs_switch);
  FSTExpectValueAt(array, 3, @"--file");
  FSTExpectTypeAt(array, 3, __fsargs_switch);
  FSTExpectValueAt(array, 4, @"foo");
  FSTExpectTypeAt(array, 4, __fsargs_unknown);
  FSTExpectValueAt(array, 5, [NSNull null]);
  FSTExpectTypeAt(array, 5, __fsargs_barrier);
  FSTExpectValueAt(array, 6, @"--asplode");
  FSTExpectTypeAt(array, 6, __fsargs_switch);
  
  array = [[NSArray arrayWithObjects:@"-cfg", @"--file=foo", @"--", @"--asplode", nil] fsargs_normalize];
  XCTAssertEqual([array count], 7UL, @"Expecting seven elements!");
  FSTExpectValueAt(array, 0, @"-c");
  FSTExpectTypeAt(array, 0, __fsargs_switch);
  FSTExpectValueAt(array, 1, @"-f");
  FSTExpectTypeAt(array, 1, __fsargs_switch);
  FSTExpectValueAt(array, 2, @"-g");
  FSTExpectTypeAt(array, 2, __fsargs_switch);
  FSTExpectValueAt(array, 3, @"--file");
  FSTExpectTypeAt(array, 3, __fsargs_switch);
  FSTExpectValueAt(array, 4, @"foo");
  FSTExpectTypeAt(array, 4, __fsargs_value);
  FSTExpectValueAt(array, 5, [NSNull null]);
  FSTExpectTypeAt(array, 5, __fsargs_barrier);
  FSTExpectValueAt(array, 6, @"--asplode");
  FSTExpectTypeAt(array, 6, __fsargs_switch);
  
}

@end
