//
//  XPMArgumentNormalizerTests.m
//  ArgumentParser
//
//  Created by Christopher R. Miller on 2/5/15.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "XPMMutableAttributedArray.h"
#import "NSArray+XPMArgumentsNormalizer.h"
#import "XPMArgsKonstants.h"

#define FSTExpectValueAt(array, location, expectedValue) XCTAssertEqualObjects([array objectAtIndex:location], expectedValue, @"Mismatched argument.");
#define FSTExpectTypeAt(array, location, expectedType) XCTAssertEqualObjects([array valueOfAttribute:xpmargs_typeKey forObjectAtIndex:location], expectedType, @"Mismatched type.");

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
  XPMMutableAttributedArray * array = [[NSArray arrayWithObjects:@"-cfg", @"--file", @"foo", @"--", @"--asplode", nil] xpmargs_normalize];
  XCTAssertEqual([array count], 7UL, @"Expecting seven elements!");
  FSTExpectValueAt(array, 0, @"-c");
  FSTExpectTypeAt(array, 0, xpmargs_switch);
  FSTExpectValueAt(array, 1, @"-f");
  FSTExpectTypeAt(array, 1, xpmargs_switch);
  FSTExpectValueAt(array, 2, @"-g");
  FSTExpectTypeAt(array, 2, xpmargs_switch);
  FSTExpectValueAt(array, 3, @"--file");
  FSTExpectTypeAt(array, 3, xpmargs_switch);
  FSTExpectValueAt(array, 4, @"foo");
  FSTExpectTypeAt(array, 4, xpmargs_unknown);
  FSTExpectValueAt(array, 5, [NSNull null]);
  FSTExpectTypeAt(array, 5, xpmargs_barrier);
  FSTExpectValueAt(array, 6, @"--asplode");
  FSTExpectTypeAt(array, 6, xpmargs_switch);
  
  array = [[NSArray arrayWithObjects:@"-cfg", @"--file=foo", @"--", @"--asplode", nil] xpmargs_normalize];
  XCTAssertEqual([array count], 7UL, @"Expecting seven elements!");
  FSTExpectValueAt(array, 0, @"-c");
  FSTExpectTypeAt(array, 0, xpmargs_switch);
  FSTExpectValueAt(array, 1, @"-f");
  FSTExpectTypeAt(array, 1, xpmargs_switch);
  FSTExpectValueAt(array, 2, @"-g");
  FSTExpectTypeAt(array, 2, xpmargs_switch);
  FSTExpectValueAt(array, 3, @"--file");
  FSTExpectTypeAt(array, 3, xpmargs_switch);
  FSTExpectValueAt(array, 4, @"foo");
  FSTExpectTypeAt(array, 4, xpmargs_value);
  FSTExpectValueAt(array, 5, [NSNull null]);
  FSTExpectTypeAt(array, 5, xpmargs_barrier);
  FSTExpectValueAt(array, 6, @"--asplode");
  FSTExpectTypeAt(array, 6, xpmargs_switch);
  
}

@end
