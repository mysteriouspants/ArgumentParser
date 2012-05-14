//
//  FSArgumentSignature.h
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/22/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSArgumentSignature : NSObject < NSCopying >

/**
 * A switch is defined as a dash-prefixed invocation, which come in two flavors:
 *
 * 1. Flags, which are composed of a single dash, then a single non-whitespace, non-dash character. Flags may be grouped, and will grab values (for valued signatures) in the order in which they appear in the grouping.
 * 2. Banners, which are composed of two dashes, then a string. This string may not start with a dash, but may contain any non-whitespace character within it. You may not group banner arguments.
 */
@property (strong) NSSet * switches;

/**
 * An alias is defined as a string which is not preceded by any dashes, which triggers behavior in the argument parser. For example, you might assign the alias `of` as the output file argument. Thus, you could invoke that argument using the terse syntax `of=file.txt` (but not `of file.txt`), omitting any dashes.
 *
 * You should be very careful with aliases, since the definition of an alias will disqualify any input string from behaving as an argument value (assuming you want values including an equals sign).
 */
@property (strong) NSSet * aliases;

/**
 * If this argument is invoked, inject this set of argument signatures into the current parser.
 */
@property (strong) NSSet * injectedSignatures;

/**
 * If this is not nil, then this block will be called to retrieve special text given for the description of the signature. The arguments are the current signature, the indent level, and the current terminal width (if available).
 */
@property (copy) NSString * (^descriptionHelper) (FSArgumentSignature * currentSignature, NSUInteger indentLevel, NSUInteger terminalWidth);

- (NSString *)descriptionForHelp:(NSUInteger)indent terminalWidth:(NSUInteger)width;

@end
