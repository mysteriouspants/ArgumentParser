//
//  FSArgumentParser.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/23/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentParser.h"
#import "FSMutableAttributedArray.h"
#import "NSArray+FSArgumentsNormalizer.h"
#import "FSArguments_Coalescer_Internal.h"
#import "FSArgsKonstants.h"

#import "FSArgumentSignature.h"
#import "FSCountedArgument.h"
#import "FSValuedArgument.h"

@interface FSArgumentParser () {
    FSMutableAttributedArray * _arguments;
    NSMutableSet * _signatures;
    NSMutableDictionary * _switches;
    NSMutableDictionary * _aliases;
}
- (void)injectSignatures:(NSSet *)signatures;
@end

@implementation FSArgumentParser

- (id)initWithArguments:(NSArray *)arguments signatures:(id)signatures
{
    self = [super init];
    
    if (self) {
        _arguments = [arguments fsargs_normalize];
        _signatures = [__fsargs_coalesceToSet(signatures) mutableCopy];
        _switches = [[NSMutableDictionary alloc] init];
        _aliases = [[NSMutableDictionary alloc] init];
        [self injectSignatures:_signatures];
    }
    
    return self;
}

- (id)parse
{
    for (NSUInteger i = 0;
         i < [_arguments count];
         ++i) {
        NSString * v = [_arguments objectAtIndex:i];
        FSArgumentSignature * signature;
        NSString * type = [_arguments valueOfAttribute:__fsargs_typeKey forObjectAtIndex:i];
        if ([type isEqual:__fsargs_switch]) {
            // switch
            if ((signature = [_switches objectForKey:v]) != nil) {
                // perform the argument
                NSLog(@"Found the %@ signature", signature);
            } else {
                // it's an unknown switch
                
            }
        } else if ([type isEqual:__fsargs_value]) {
            // uncaptured valued
            if ([_arguments booleanValueOfAttribute:__fsargs_isValueCaptured forObjectAtIndex:i]) {
                continue; // just skip this one
            } else {
                // it's an uncaptured value, which is really quite rare. The only way to pre-mark a value to with an equals-sign, which means that an equals sign assignment was used on a signature which doesn't capture values.
                // find a way to associate this with what it wanted to be associated with in a weak way.
                NSLog(@"Unknown value %@ detected", v);
            }
        } else if ([type isEqual:__fsargs_unknown]) {
            // potentially uncaptured value, or else it could be an alias
            if ((signature = [_aliases objectForKey:v]) != nil) {
                // perform the argument
                NSLog(@"Found the signature %@ (alias)", signature);
                
            } else {
                // it's an uncaptured value, not strongly associated with anything else
                // it could be weakly associated with something, however
                NSLog(@"Uncaptured value %@", v);
                
            }
        } else {
            // unknown type
            NSLog(@"Unknown type: %@", type);
        }
    }
    return nil;
}

- (void)injectSignatures:(NSSet *)signatures
{
    [signatures enumerateObjectsUsingBlock:^(FSArgumentSignature * signature, BOOL *stop) {
        [signature.switches enumerateObjectsUsingBlock:^(id _switch, BOOL *stop) {
            [_switches setObject:signature forKey:_switch];
        }];
        [signature.aliases enumerateObjectsUsingBlock:^(id alias, BOOL *stop) {
            [_aliases setObject:signature forKey:alias];
        }];
    }];
}

@end
