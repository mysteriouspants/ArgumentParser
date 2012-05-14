//
//  FSValuedArgument.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "FSArgumentSignature.h"

/** An argument which has one or more values attached to it. */
@interface FSValuedArgument : FSArgumentSignature

/**
 * The number of values per invocation, which should start at one and have a maximum of NSNotFound (infinity).
 *
 * Note that this is not used as NSRange is normally used! The `location` is the *minimum* number of values per invocation, and the `length` is the *maximum* number of values per invocation.
 */
@property (assign) NSRange valuesPerInvocation;

/**
 * If set, this argument will continue to try and grab values beyond barriers, which are defined as any other explicit argument invocation or a double dash.
 *
 * For example, if the signature signified by the short name c were to have valuesPerInvocation as 3, and shouldGrabBeyondBarrier were false, the following would error as having insufficient values to the argument:
 *
 *     foo -c 1 2 -f 3
 *
 * However, given the same signature with shouldGrabBeyondBarrier set to true, the same invocation would succeed and grab the 3 and add it to c.
 *
 * It is important to note that this only applies to disconnected value lists. So, if shouldGrabBeyondBarrier is false, this will still work:
 *
 *     foo --file -v 1
 *
 * But this won't:
 *
 *     foo --files 1 -v 2
 */
@property (assign) bool shouldGrabBeyondBarrier;

+ (id)valuedArgumentWithSwitches:(id)switches aliases:(id)aliases;
- (id)initWithSwitches:(id)switches aliases:(id)aliases;

+ (id)valuedArgumentWithSwitches:(id)switches aliases:(id)aliases valuesPerInvocation:(NSRange)valuesPerInvocation shouldGrabBeyondBarrier:(bool)shouldGrabBeyondBarrier;
- (id)initWithSwitches:(id)switches aliases:(id)aliases valuesPerInvocation:(NSRange)valuesPerInvocation shouldGrabBeyondBarrier:(bool)shouldGrabBeyondBarrier;


@end
