//
//  XPMAttributedArrayTests.m
//  ArgumentParser
//
//  Created by Christopher R. Miller on 2/5/15.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "XPMMutableAttributedArray.h"

@interface XPMAttributedArrayTests : XCTestCase

@end

@implementation XPMAttributedArrayTests

- (void)setUp {
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

- (void)testAddition
{
  XPMMutableAttributedArray * a = [XPMMutableAttributedArray attributedArrayWithCapacity:2];
  
  [a addObject:@"one" withAttributes:nil];
  [a addObject:@"two" withAttributes:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
  
  XCTAssertEqualObjects(@"one", [a objectAtIndex:0], @"Goof.");
  XCTAssertNotNil([a attributesOfObjectAtIndex:0], @"This really shouldn't be nil.");
  XCTAssertTrue([[a attributesOfObjectAtIndex:0] count] == 0, @"Why is this not zero?");
  
  XCTAssertEqualObjects(@"two", [a objectAtIndex:1], @"Goof.");
  XCTAssertNotNil([a attributesOfObjectAtIndex:1], @"This really shouldn't be nil.");
  XCTAssertTrue([[a attributesOfObjectAtIndex:1] count] == 1, @"Why is this not one?");
}


@end
