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
 * All of the names that this argument can be referenced by, with their leading dashes.
 */
@property (readwrite, strong) NSArray *             names;

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
 * Convenience constructor.
 */
+ (id)argumentSignatureWithNames:(NSArray *)names flag:(BOOL)flag required:(BOOL)required multipleAllowed:(BOOL)multipleAllowed;

@end
