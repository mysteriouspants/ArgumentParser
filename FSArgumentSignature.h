//
//  FSArgumentSignature.h
//  fs-dataman
//
//  Created by Christopher Miller on 2/22/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * An argument signature defines either a named argument or flag in a command-line invocation.
 */
@interface FSArgumentSignature : NSObject

/**
 * All the characters this signature will respond to as short flags. Eg: -v or something.
 */
@property (readwrite, strong) NSCharacterSet * shortNames;

/**
 * All the names this signature will responds to as long names. Eg: --verbose or something.
 */
@property (readwrite, strong) NSArray * longNames;

/**
 * Sets whether the argument is treated as a flag; if it is, then its presence indicates yes. If the flag isn't found, then it means no. There is no trailing data after a flag.
 */
@property (readwrite, assign, getter = isFlag) BOOL flag;

/**
 * Sets whether this argument is required or not. If it is, then the parser will scream and complain if it is not found.
 */
@property (readwrite, assign, getter = isRequired) BOOL required;

/**
 * Set whether more than one of this argument is allowed. If multiple arguments are not allowed, then the parser fails. In the case of multiple flags, the parser increments the flag count.
 */
@property (readwrite, assign, getter = isMultipleAllowed) BOOL multipleAllowed;

/**
 * Create a new argument signature that behaves as a boolean flag.
 *
 * @param shortName A string, array, set, or character set describing all the characters that this signature responds to.
 * @param longNames A string, array, or set describing all the long names this signature responds to.
 * @param multipleAllowed Tells the parser to explode if more than one of this flag is found.
 */
+ (id)argumentSignatureAsFlag:(id)shortName longNames:(id)longNames multipleAllowed:(BOOL)multipleAllowed;

/**
 * Create a new argument signature that behaves as a named argument.
 *
 * @param shortName A string, array, set, or character set describing all the characters that this signature responds to.
 * @param longNames A string, array, or set describing all the long names this signature responds to.
 * @param required Scream bloody murder if this argument isn't found.
 * @param multipleAllowed Tells the parser to explode if more than one of this argument is found.
 */
+ (id)argumentSignatureAsNamedArgument:(id)shortName longNames:(id)longNames required:(BOOL)required multipleAllowed:(BOOL)multipleAllowed;

@end
