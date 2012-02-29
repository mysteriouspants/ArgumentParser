//
//  FSArgumentPackage.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/23/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentPackage.h"

#import "FSArgumentSignature.h"

FSArgumentSignature * __argumentSignatureInArrayRespondingToString(NSArray *, NSString *);

BOOL FSAPNotFound = -1;

@implementation FSArgumentPackage

@synthesize flags = _flags;
@synthesize namedArguments = _namedArguments;
@synthesize unnamedArguments = _unnamedArguments;

- (BOOL)boolValueOfFlag:(id)name
{
    FSArgumentSignature * s;
    if ([name isKindOfClass:[FSArgumentSignature class]]) s = name;
    else s = __argumentSignatureInArrayRespondingToString([_flags allKeys], name);
    if (!s) return FSAPNotFound;
    else return [[_flags objectForKey:s] boolValue];
}

- (NSUInteger)unsignedIntegerValueOfFlag:(id)name
{
    FSArgumentSignature * s;
    if ([name isKindOfClass:[FSArgumentSignature class]]) s = name;
    else s = __argumentSignatureInArrayRespondingToString([_flags allKeys], name);
    if (!s) return NSNotFound;
    else return [[_flags objectForKey:s] unsignedIntegerValue];
}

- (id)objectForNamedArgument:(id)name
{
    FSArgumentSignature * s;
    if ([name isKindOfClass:[FSArgumentSignature class]]) s = name;
    else s = __argumentSignatureInArrayRespondingToString([_namedArguments allKeys], name);
    if (!s) return nil;
    else return [_namedArguments objectForKey:s];
}

@end

FSArgumentSignature * __argumentSignatureInArrayRespondingToString(NSArray * a, NSString * s) {
    __block FSArgumentSignature * sig;
    __block BOOL shouldTreatAsLongName = [s length]>1;
    __block unichar c = [s characterAtIndex:0];
    [a enumerateObjectsUsingBlock:^(FSArgumentSignature * obj, NSUInteger idx, BOOL *stop) {
        if (shouldTreatAsLongName) {
            if ([obj.longNames containsObject:s]) {
                sig = obj;
                *stop = YES;
            }
        } else {
            if ([obj.shortNames characterIsMember:c]) {
                sig = obj;
                *stop = YES;
            }
        }
    }];
    return sig;
}
