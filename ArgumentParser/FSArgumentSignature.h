//
//  FSArgumentSignature.h
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/22/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * An argument signature defines a named argument, command, or flag in a command-line invocation.
 *
 * The precise taxonomy is thus:
 *
 * 1. Counted argument. These are usually interpreted as booleans. Things such as the "verbose" or "help" flag are implemented as these.
 * 2. Valued argument. These are best described as arguments that can be interpreted as dictionary values, such as "--file text.txt".
 * 3. Command arguments. These are special strings which trigger something like a boolean switch, but don't need to be preceded by dashes.
 * 
 * Everything that remains is left as a simple array of strings.
 *
 * You are free to modify these objects as much as you want, but they must not be modified during parsing or undefined behavior will ensue.
 */
@interface FSArgumentSignature : NSObject < NSCopying >

/** If this argument is invoked, inject this set of argument signatures into the parser. */
@property (strong) NSSet * positiveInjectors;
/** If this argument is NOT invoked, inject this set of argument signatures into the parser. */
@property (strong) NSSet * negativeInjectors;

/** If this argument is found, ignore the "required" attributes of all named arguments. */
@property (assign) bool nullifyRequired;
/** If this argument is found and nullifies required arguments, extend this nullification upward by this many levels. */
@property (assign) NSUInteger nullifyRequiredAncestorPropagation;
/** If this argument is found and nullifies required arguments, extend this nullification downward (through positiveInjectors) by this many levels, or NSNotFound for inifinite. */
@property (assign) NSUInteger nullifyRequiredDescendentPropagation;

@end
