//
//  FSArgumentSignature.m
//  fs-dataman
//
//  Created by Christopher Miller on 2/22/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentSignature.h"

NSCharacterSet * __fsargs_coalesceToCharacterSet(id);
NSArray * __fsargs_coalesceToArray(id);

@implementation FSArgumentSignature
@synthesize shortNames=_shortNames;
@synthesize longNames=_longNames;
@synthesize flag=_flag;
@synthesize required=_required;
@synthesize multipleAllowed=_multipleAllowed;
+ (id)argumentSignatureAsFlag:(id)shortName longNames:(id)longNames multipleAllowed:(BOOL)multipleAllowed
{
    FSArgumentSignature * siggy = [[[self class] alloc] init];
    if (!siggy) return siggy;
    siggy.flag = YES;
    siggy.multipleAllowed = multipleAllowed;
    siggy.required = NO;
    siggy.shortNames = __fsargs_coalesceToCharacterSet(shortName);
    siggy.longNames = __fsargs_coalesceToArray(longNames);
    return siggy;
}
+ (id)argumentSignatureAsNamedArgument:(id)shortName longNames:(id)longNames required:(BOOL)required multipleAllowed:(BOOL)multipleAllowed
{
    FSArgumentSignature * siggy = [[[self class] alloc] init];
    if (!siggy) return siggy;
    siggy.flag = NO;
    siggy.multipleAllowed = multipleAllowed;
    siggy.required = required;
    siggy.shortNames = __fsargs_coalesceToCharacterSet(shortName);
    siggy.longNames = __fsargs_coalesceToArray(longNames);
    return siggy;
}
@end

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsstring(NSString *);
NSCharacterSet * __fsargs_coalesceToCharacterSet_nsarray(NSArray *);
NSCharacterSet * __fsargs_coalesceToCharacterSet_nsset(NSSet *);
NSCharacterSet * __fsargs_coalesceToCharacterSet_nsorderedset(NSOrderedSet *);
NSCharacterSet * __fsargs_coalesceToCharacterSet_nsobject(NSObject *);

NSCharacterSet * __fsargs_coalesceToCharacterSet(id o) {
    if ([o isKindOfClass:[NSString class]]) return __fsargs_coalesceToCharacterSet_nsstring(o);
    else if ([o isKindOfClass:[NSArray class]]) return __fsargs_coalesceToCharacterSet_nsarray(o);
    else if ([o isKindOfClass:[NSSet class]]) return __fsargs_coalesceToCharacterSet_nsset(o);
    else if ([o isKindOfClass:[NSOrderedSet class]]) return __fsargs_coalesceToCharacterSet_nsorderedset(o);
    else return __fsargs_coalesceToCharacterSet_nsobject(o);
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsstring(NSString * s) {
    return [NSCharacterSet characterSetWithCharactersInString:s];
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsarray(NSArray * a) {
    NSMutableCharacterSet * s = [[NSMutableCharacterSet alloc] init];
    [a enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [s formUnionWithCharacterSet:__fsargs_coalesceToCharacterSet(obj)];
    }];
    return s;
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsset(NSSet * s) {
    NSMutableCharacterSet * cs = [[NSMutableCharacterSet alloc] init];
    [s enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [cs formUnionWithCharacterSet:__fsargs_coalesceToCharacterSet(obj)];
    }];
    return cs;
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsorderedset(NSOrderedSet * s) {
    NSMutableCharacterSet * cs = [[NSMutableCharacterSet alloc] init];
    [s enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [cs formUnionWithCharacterSet:__fsargs_coalesceToCharacterSet(obj)];
    }];
    return cs;
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsobject(NSObject * o) {
    return __fsargs_coalesceToCharacterSet_nsstring([o description]);
}

NSArray * __fsargs_coalesceToArray(id o) {
    if (!o) return nil;
    else if ([o isKindOfClass:[NSArray class]]) return o;
    else if ([o isKindOfClass:[NSString class]]) return [NSArray arrayWithObject:o];
    else if ([o isKindOfClass:[NSSet class]]||[o isKindOfClass:[NSOrderedSet class]]) return [o allObjects];
    else return [NSArray arrayWithObject:[o description]];
}
