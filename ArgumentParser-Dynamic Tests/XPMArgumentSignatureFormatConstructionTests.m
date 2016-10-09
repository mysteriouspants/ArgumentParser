//
//  XPMArgumentSignatureFormatConstructionTests.m
//  ArgumentParser
//
//  Created by Christopher R. Miller on 2/5/15.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "XPMArgumentSignature.h"
#import "XPMArgumentSignature_Private.h"
#import "XPMCountedArgument.h"
#import "XPMValuedArgument.h"

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

- (void)testParser
{
  XPMArgumentSignature * format;
  XPMArgumentSignature * expected;
  
  format = [XPMArgumentSignature argumentSignatureWithFormat:@"[-f --file if]={1,5}"];
  expected = [XPMValuedArgument valuedArgumentWithSwitches:[NSSet setWithObjects:@"f", @"file", nil] aliases:[NSSet setWithObject:@"if"] valuesPerInvocation:NSMakeRange(1, 5)];
  XCTAssertEqualObjects(format, expected, @"Format constructor failure.");
  
  format = [XPMArgumentSignature argumentSignatureWithFormat:@"[-f --file if]={1,}"];
  expected = [XPMValuedArgument valuedArgumentWithSwitches:[NSSet setWithObjects:@"f", @"file", nil] aliases:[NSSet setWithObject:@"if"] valuesPerInvocation:NSMakeRange(1, NSNotFound)];
  XCTAssertEqualObjects(format, expected, @"Format constructor failure.");
  
  format = [XPMArgumentSignature argumentSignatureWithFormat:@"[-f --file if]="];
  expected = [XPMValuedArgument valuedArgumentWithSwitches:[NSSet setWithObjects:@"f", @"file", nil] aliases:[NSSet setWithObject:@"if"] valuesPerInvocation:NSMakeRange(1, 1)];
  XCTAssertEqualObjects(format, expected, @"Format constructor failure.");
  
  format = [XPMArgumentSignature argumentSignatureWithFormat:@"[-f --file if]"];
  expected = [XPMCountedArgument countedArgumentWithSwitches:[NSSet setWithObjects:@"f", @"file", nil] aliases:[NSSet setWithObject:@"if"]];
  
  XCTAssertEqualObjects(format, expected, @"Format constructor failure.");
}


@end
