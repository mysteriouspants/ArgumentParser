//
//  FSArgumentPackage.h
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/23/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

extern BOOL FSAPNotFound;

//! dumb return structure which bundles up all the relevant information
@interface FSArgumentPackage : NSObject

//! All flags. This is a dict of NSNumbers (containing NSUIntegers) keyed to their constituent FSArgumentSignature.
//@property (readwrite, strong) NSDictionary * flags;
//! All named arguments. This is a dict of NSString or NSArray (of NSStrings) keyed to their constituent FSArgumentSignature.
//@property (readwrite, strong) NSDictionary * namedArguments;
//! The residue of what wasn't parsed to a flag or named argument.
//@property (readwrite, strong) NSArray * unnamedArguments;

/**
 * Find the boolean value of a flag.
 * 
 * @param name This can be a string (either a single-character for the flag or a whole string for the long name), or the FSArgumentSignature.
 * @return YES or NO, or FSAPNotFound if no such signature exists.
 */
//- (BOOL)boolValueOfFlag:(id)name;

/**
 * Find the integer value of a flag.
 *
 * @param name This can be a string (either a single character for the flag or a whole string for the long name), or the FSArgumentSignature.
 * @return NSNotFound if no such signature exists.
 */
//- (NSUInteger)unsignedIntegerValueOfFlag:(id)name;

/**
 * Find the object corresponding to a named argument.
 * 
 * @param name This can be a string (either a single character for the flag or a whole string for the long name), or the FSArgumentSignature.
 * @return Either an NSString if isMultipleAllowed is NO, or an NSArray if isMultipleAllowed is YES, or nil if no such signature exists.
 */
//- (id)objectForNamedArgument:(id)name;

@end
