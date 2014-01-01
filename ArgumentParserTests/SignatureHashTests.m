//
//  SignatureHashTests.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "SignatureHashTests.h"
#import "FSArgumentSignature.h"
#import "FSCountedArgument.h"
#import "FSValuedArgument.h"

// coz these things are so darned hard to get right. a botched hash will screw up dictionary indexing, too, so ensuring this is right will be a super-big help
@implementation SignatureHashTests

- (void)testCountedArgument
{
    FSCountedArgument * c0 = [FSCountedArgument countedArgumentWithSwitches:[NSSet setWithObjects:@"v", @"verbose", nil] aliases:nil];
    FSCountedArgument * c0_copy = [c0 copy];
    FSCountedArgument * c1 = [FSCountedArgument countedArgumentWithSwitches:[NSSet setWithObjects:@"v", @"verbose", nil] aliases:nil];
    FSCountedArgument * c2 = [FSCountedArgument countedArgumentWithSwitches:[NSSet setWithObjects:@"f", @"file", nil] aliases:nil];
    FSCountedArgument * c3 = [FSCountedArgument countedArgumentWithSwitches:[NSSet setWithObjects:@"v", [NSString stringWithFormat:@"%@%@", @"ver", @"bose"], nil] aliases:nil]; // should make it a different string in memory, too. I just want to check this to be sure. If it's right here, then it'll be correct in the other three tests, too.
    
    STAssertEquals([c0 hash], [c0_copy hash], @"For some reason c0 has a different hash from c0_copy.");
    STAssertTrue([c0 isEqual:c0_copy], @"c0 isn't equal to its copy.");
    
    STAssertEquals([c0 hash], [c1 hash], @"For some reason c0 has a different hash from its twin, c1.");
    STAssertTrue([c0 isEqual:c1], @"c0 isn't equal to its twin, c1.");
    
    STAssertFalse([c0 hash] == [c2 hash], @"c0 has the same hash has c2, which it shouldn't.");
    STAssertFalse([c0 isEqual:c2], @"c0 is somehow equal to c2; it shouldn't be.");
    
    STAssertEquals([c0 hash], [c3 hash], @"For some reason c0 has a different hash from c3.");
    STAssertTrue([c0 isEqual:c3], @"c0 isn't equal to its twin, c3.");
}

- (void)testValuedArgument
{
    FSValuedArgument * v0 = [FSValuedArgument valuedArgumentWithSwitches:[NSSet setWithObjects:@"f", @"file", nil] aliases:nil];
    FSValuedArgument * v0_copy = [v0 copy];
    FSValuedArgument * v1 = [FSValuedArgument valuedArgumentWithSwitches:[NSSet setWithObjects:@"f", @"file", nil] aliases:nil];
    FSValuedArgument * v2 = [FSValuedArgument valuedArgumentWithSwitches:[NSSet setWithObjects:@"p", @"phallus", nil] aliases:nil];;
    
    STAssertEquals([v0 hash], [v0_copy hash], @"For some reason v0 has a different hash from v0_copy.");
    STAssertTrue([v0 isEqual:v0_copy], @"v0 isn't equal to its copy.");
    
    STAssertEquals([v0 hash], [v1 hash], @"For some reason v0 has a different hash from its twin, v1.");
    STAssertTrue([v0 isEqual:v1], @"v0 isn't equal to its twin, v1.");
    
    STAssertFalse([v0 hash] == [v2 hash], @"v0 has the same hash as v2, which it shouldn't.");
    STAssertFalse([v0 isEqual:v2], @"v0 is somehow equal to v2; it shouldn't be.");
}

@end
