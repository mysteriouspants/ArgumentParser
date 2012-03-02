//
//  FSArgumentParser.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/23/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentParser.h"
#import "FSArgumentPackage.h"
#import "FSArgumentSignature.h"

NSString * kFSAPErrorDomain = @"net.fsdev.argument_parser";

const struct FSAPErrorDictKeys FSAPErrorDictKeys = {
    .ImpureSignatureObject = @"impureSignatureObject",
    .ImpureSignatureLocation = @"impureSignatureLocation",
    
    .OverlappingArgumentName = @"overlappingArgumentName",
    .OverlappingArgumentSignature1 = @"overlappingArgumentSignature1",
    .OverlappingArgumentSignature2 = @"overlappingArgumentSignature2",
    
    .TooManyOfThisSignature = @"tooManyOfThisSignature",
    .CountOfTooManySignatures = @"countOfTooManySignatures",
    
    .MissingTheseSignatures = @"missingTheseSignatures",
    
    .ArgumentOfTypeMissingValue = @"argumentOfTypeMissingValue",
    
    .UnknownSignature = @"unknownSignature"
};

@interface FSArgumentPackage (__nice_constructor__)
+ (id)argumentPackageWithFlags:(NSDictionary *)flags namedArguments:(NSDictionary *)namedArguments unnamedArguments:(NSArray *)unnamedArguments;
@end

@implementation FSArgumentParser

+ (FSArgumentPackage *)parseArguments:(NSArray *)_args withSignatures:(NSArray *)signatures error:(__autoreleasing NSError **)error
{
    NSMutableArray * args = [_args mutableCopy];
    
    // check for purity in signature array
    [signatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[FSArgumentSignature class]]) {
            *error = [NSError errorWithDomain:kFSAPErrorDomain code:ImpureSignatureArray userInfo:[NSDictionary dictionaryWithObjectsAndKeys:obj, FSAPErrorDictKeys.ImpureSignatureObject,
                                                                                                   [NSNumber numberWithUnsignedInteger:idx], FSAPErrorDictKeys.ImpureSignatureLocation, nil]];
            *stop = YES;
        }
    }]; if (*error) return nil;
    
    // check for conflicting signatures
    [signatures enumerateObjectsUsingBlock:^(FSArgumentSignature * signature, NSUInteger signature_idx, BOOL *signature_stop) {
        [signatures enumerateObjectsUsingBlock:^(FSArgumentSignature * signature2, NSUInteger signature2_idx, BOOL *signature2_stop) {
            if (signature2==signature) return; // duh they're going to match!
            NSMutableCharacterSet * signature_shortnames = [signature.shortNames mutableCopy];
            [signature_shortnames formIntersectionWithCharacterSet:signature2.shortNames];
            BOOL shortname_conflict=NO;
            for (unichar t = 0;
                 t < 256;
                 ++t) {
                if ([signature_shortnames characterIsMember:t]) {
                    shortname_conflict = YES;
                    break;
                }
            }
            if (shortname_conflict) {
                *signature2_stop = YES;
                *signature_stop = YES;
                *error = [NSError errorWithDomain:kFSAPErrorDomain code:OverlappingArgument userInfo:[NSDictionary dictionaryWithObjectsAndKeys:signature_shortnames, FSAPErrorDictKeys.OverlappingArgumentName,
                                                                                                      signature, FSAPErrorDictKeys.OverlappingArgumentSignature1,
                                                                                                      signature2, FSAPErrorDictKeys.OverlappingArgumentSignature2, nil]];
            }
        }];
        if (*signature_stop==YES) return; // just die now
        [signature.longNames enumerateObjectsUsingBlock:^(NSString * longName, NSUInteger longName_idx, BOOL *longName_stop) {
            [signatures enumerateObjectsUsingBlock:^(FSArgumentSignature * signature2, NSUInteger signature2_idx, BOOL *signature2_stop) {
                if (signature==signature2) return; // duh they're going to match!
                if ([signature2.longNames containsObject:longName]) {
                    // stop
                    *signature_stop = YES;
                    *longName_stop = YES;
                    *signature2_stop = YES;
                    *error = [NSError errorWithDomain:kFSAPErrorDomain code:OverlappingArgument userInfo:[NSDictionary dictionaryWithObjectsAndKeys:longName, FSAPErrorDictKeys.OverlappingArgumentName,
                                                                                                          signature, FSAPErrorDictKeys.OverlappingArgumentSignature1,
                                                                                                          signature2, FSAPErrorDictKeys.OverlappingArgumentSignature2, nil]];
                }
            }];
        }];
    }]; if (*error) return nil;
    
    NSMutableDictionary * flags = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * namedArguments = [[NSMutableDictionary alloc] init];
    NSMutableArray * unnamedArguments = [[NSMutableArray alloc] init];
    
    NSMutableSet * flagSignatures = [[NSMutableSet alloc] init];
    NSMutableCharacterSet * flagCharacters = [[NSMutableCharacterSet alloc] init];
    NSMutableArray * flagNames = [[NSMutableArray alloc] init];
    NSMutableSet * notFlagSignatures = [[NSMutableSet alloc] init];
    [signatures enumerateObjectsUsingBlock:^(FSArgumentSignature * obj, NSUInteger idx, BOOL *stop) {
        if (obj.isFlag) {
            [flagSignatures addObject:obj];
            [flagCharacters formUnionWithCharacterSet:obj.shortNames];
            [flagNames addObjectsFromArray:obj.longNames];
            [flags setObject:[NSNumber numberWithUnsignedInteger:0] forKey:obj];
        }
        else [notFlagSignatures addObject:obj];
    }];
    
    NSRegularExpression * flagDetector = [NSRegularExpression regularExpressionWithPattern:@"^[\\-][^\\-]*$" options:0 error:error];
    if (*error) return nil;
    NSRegularExpression * namedArgumentDetector = [NSRegularExpression regularExpressionWithPattern:@"^[\\-]{2}.*$" options:0 error:error];
    if (*error) return nil;
    NSRegularExpression * isntValueDetector = [NSRegularExpression regularExpressionWithPattern:@"^\\-" options:0 error:error];
    if (*error) return nil;
    
    while (0<[args count]) {
        NSString * arg = [args objectAtIndex:0];
        [args removeObjectAtIndex:0];
        if (0<[flagDetector numberOfMatchesInString:arg options:0 range:NSMakeRange(0, [arg length])]) {
            NSMutableString * mutable_arg = [arg mutableCopy];
            // chop off the first dash
            [mutable_arg deleteCharactersInRange:NSMakeRange(0, 1)];
            while (0<[mutable_arg length]) {
                unichar c = [mutable_arg characterAtIndex:0];
                if ([flagCharacters characterIsMember:c]) {
                    FSArgumentSignature * as = [[flagSignatures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSArgumentSignature * evaluatedObject, NSDictionary *bindings) {
                        if ([evaluatedObject.shortNames characterIsMember:c]) return YES;
                        else return NO;
                    }]] anyObject];
                    if (!as) {
                        *error = [NSError errorWithDomain:kFSAPErrorDomain code:UnknownArgument userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithChar:c] forKey:FSAPErrorDictKeys.UnknownSignature]];
                        return nil;
                    }
                    NSNumber * count = [flags objectForKey:as];
                    if (count==nil) count = [NSNumber numberWithUnsignedInteger:0];
                    else if (!as.isMultipleAllowed&&[count unsignedIntegerValue]>1) {
                        *error = [NSError errorWithDomain:kFSAPErrorDomain code:TooManySignatures userInfo:[NSDictionary dictionaryWithObject:as forKey:FSAPErrorDictKeys.TooManyOfThisSignature]];
                        return nil;
                    }
                    count = [NSNumber numberWithUnsignedInteger:[count unsignedIntegerValue]+1];
                    [flags setObject:count forKey:as];
                } else { // it's a named argument
                    FSArgumentSignature * as = [[notFlagSignatures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSArgumentSignature * evaluatedObject, NSDictionary *bindings) {
                        if ([evaluatedObject.shortNames characterIsMember:c]) return YES;
                        else return NO;
                    }]] anyObject];
                    if (!as) {
                        *error = [NSError errorWithDomain:kFSAPErrorDomain code:UnknownArgument userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithChar:c] forKey:FSAPErrorDictKeys.UnknownSignature]];
                        return nil;
                    }
                    __block NSUInteger valueLocation=NSNotFound;
                    [args enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
                        if ([isntValueDetector numberOfMatchesInString:obj options:0 range:NSMakeRange(0, [obj length])]==0) {
                            valueLocation = idx;
                            *stop = YES;
                        }
                    }];
                    if (0==[args count]||valueLocation==NSNotFound) {
                        *error = [NSError errorWithDomain:kFSAPErrorDomain code:ArgumentMissingValue userInfo:[NSDictionary dictionaryWithObject:as forKey:FSAPErrorDictKeys.ArgumentOfTypeMissingValue]];
                        return nil;
                    }
                    id value = [namedArguments objectForKey:as];
                    if (value&&!as.isMultipleAllowed) {
                        *error = [NSError errorWithDomain:kFSAPErrorDomain code:TooManySignatures userInfo:[NSDictionary dictionaryWithObject:as forKey:FSAPErrorDictKeys.TooManyOfThisSignature]];
                        return nil;
                    }
                    if (!value&&as.isMultipleAllowed) value = [NSMutableArray array];
                    if (as.isMultipleAllowed) [value addObject:[args objectAtIndex:valueLocation]];
                    else value = [args objectAtIndex:valueLocation];
                    [namedArguments setObject:value forKey:as];
                    [args removeObjectAtIndex:valueLocation];
                }
                [mutable_arg deleteCharactersInRange:NSMakeRange(0, 1)];
            }
        } else if (0<[namedArgumentDetector numberOfMatchesInString:arg options:0 range:NSMakeRange(0, [arg length])]) {
            NSMutableString * mutable_arg = [arg mutableCopy];
            // chop off the first two dashes
            [mutable_arg deleteCharactersInRange:NSMakeRange(0, 2)];
            if ([flagNames containsObject:mutable_arg]) {
                // just a flag
                FSArgumentSignature * as = [[flagSignatures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSArgumentSignature * evaluatedObject, NSDictionary *bindings) {
                    if ([evaluatedObject.longNames containsObject:mutable_arg]) return YES;
                    else return NO;
                }]] anyObject];
                if (!as) {
                    *error = [NSError errorWithDomain:kFSAPErrorDomain code:UnknownArgument userInfo:[NSDictionary dictionaryWithObject:mutable_arg forKey:FSAPErrorDictKeys.UnknownSignature]];
                    return nil;
                }
                NSNumber * count = [flags objectForKey:as];
                if (count==nil) count = [NSNumber numberWithUnsignedInteger:0];
                else if (!as.isMultipleAllowed) {
                    *error = [NSError errorWithDomain:kFSAPErrorDomain code:TooManySignatures userInfo:[NSDictionary dictionaryWithObject:as forKey:FSAPErrorDictKeys.TooManyOfThisSignature]];
                    return nil;
                }
                count = [NSNumber numberWithUnsignedInteger:[count unsignedIntegerValue]+1];
                [flags setObject:count forKey:as];
            } else { // it's a named argument
                FSArgumentSignature * as = [[notFlagSignatures filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSArgumentSignature * evaluatedObject, NSDictionary *bindings) {
                    if ([evaluatedObject.longNames containsObject:mutable_arg]) return YES;
                    else return NO;
                }]] anyObject];
                if (!as) {
                    *error = [NSError errorWithDomain:kFSAPErrorDomain code:UnknownArgument userInfo:[NSDictionary dictionaryWithObject:mutable_arg forKey:FSAPErrorDictKeys.UnknownSignature]];
                    return nil;
                }
                __block NSUInteger valueLocation = NSNotFound;
                [args enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
                    if ([isntValueDetector numberOfMatchesInString:obj options:0 range:NSMakeRange(0, [obj length])]==0) {
                        valueLocation = idx;
                        *stop = YES;
                    }
                }];
                if (0==[args count]||valueLocation==NSNotFound) {
                    *error = [NSError errorWithDomain:kFSAPErrorDomain code:ArgumentMissingValue userInfo:[NSDictionary dictionaryWithObject:as forKey:FSAPErrorDictKeys.ArgumentOfTypeMissingValue]];
                    return nil;
                }
                id value = [namedArguments objectForKey:as];
                if (value&&!as.isMultipleAllowed) {
                    *error = [NSError errorWithDomain:kFSAPErrorDomain code:TooManySignatures userInfo:[NSDictionary dictionaryWithObject:as forKey:FSAPErrorDictKeys.TooManyOfThisSignature]];
                    return nil;
                }
                if (!value&&as.isMultipleAllowed) value = [NSMutableArray array];
                if (as.isMultipleAllowed) [value addObject:[args objectAtIndex:valueLocation]];
                else value = [args objectAtIndex:valueLocation];
                [namedArguments setObject:value forKey:as];
                [args removeObjectAtIndex:valueLocation];
            }
        } else {
            // unnamed arg
            [unnamedArguments addObject:arg];
        }
    }
    
    NSMutableArray * allFoundArguments = [[NSMutableArray alloc] initWithArray:[flags allKeys]];
    [allFoundArguments addObjectsFromArray:[namedArguments allKeys]];
    NSMutableArray * allRequiredSignatures = [NSMutableArray arrayWithArray:[signatures filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSArgumentSignature * evaluatedObject, NSDictionary *bindings) {        
        return evaluatedObject.isRequired && ![allFoundArguments containsObject:evaluatedObject];
    }]]];
    
    FSArgumentPackage * pkg = [FSArgumentPackage argumentPackageWithFlags:[flags copy] namedArguments:[namedArguments copy] unnamedArguments:[unnamedArguments copy]];
    if (0<[allRequiredSignatures count]) {
        *error = [NSError errorWithDomain:kFSAPErrorDomain code:MissingSignatures userInfo:[NSDictionary dictionaryWithObject:allRequiredSignatures forKey:FSAPErrorDictKeys.MissingTheseSignatures]];
        return pkg;
    }
    
    return pkg;
}

@end

@implementation FSArgumentPackage (__nice_constructor__)
+ (id)argumentPackageWithFlags:(NSDictionary *)flags namedArguments:(NSDictionary *)namedArguments unnamedArguments:(NSArray *)unnamedArguments
{
    FSArgumentPackage * toReturn = [[FSArgumentPackage alloc] init];
    if (!toReturn) return nil;
    toReturn.flags = flags;
    toReturn.namedArguments = namedArguments;
    toReturn.unnamedArguments = unnamedArguments;
    return toReturn;
}
@end
