//
//  FSArgumentParser.m
//  fs-dataman
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
    
    .MissingSignatureOfType = @"missingSignatureOfType",
    
    .ArgumentOfTypeMissingValue = @"argumentOfTypeMissingValue"
};

@interface FSArgumentPackage (__nice_constructor__)
+ (id)argumentPackageWithFlags:(NSDictionary *)flags namedArguments:(NSDictionary *)namedArguments unnamedArguments:(NSArray *)unnamedArguments;
@end

@implementation FSArgumentParser

+ (FSArgumentPackage *)parseArguments:(NSArray *)_args withSignatures:(NSArray *)signatures error:(NSError **)error
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
        [signature.names enumerateObjectsUsingBlock:^(NSString * name, NSUInteger name_idx, BOOL *name_stop) {
            [signatures enumerateObjectsUsingBlock:^(FSArgumentSignature * compared_signature, NSUInteger compared_signature_idx, BOOL *compared_signature_stop) {
                if (compared_signature == signature) return; // duh they're going to match!
                if ([compared_signature.names containsObject:name]) {
                    // stop
                    *signature_stop = YES;
                    *name_stop = YES;
                    *compared_signature_stop = YES;
                    
                    *error = [NSError errorWithDomain:kFSAPErrorDomain code:OverlappingArgument userInfo:[NSDictionary dictionaryWithObjectsAndKeys:name, FSAPErrorDictKeys.OverlappingArgumentName,
                                                                                                          signature, FSAPErrorDictKeys.OverlappingArgumentSignature1,
                                                                                                          compared_signature, FSAPErrorDictKeys.OverlappingArgumentSignature2, nil]];
                }
            }];
        }];
    }]; if (*error) return nil;
    
    NSMutableDictionary * flags = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * namedArguments = [[NSMutableDictionary alloc] init];
    
    // arguments first
    [[signatures filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSArgumentSignature * evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isFlag]) return NO;
        return YES;
    }]] enumerateObjectsUsingBlock:^(FSArgumentSignature * signature, NSUInteger idx, BOOL *stop) {
        NSIndexSet * matchingFlags = [args indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [signature.names containsObject:obj];
        }];
        if (![signature isMultipleAllowed]&&[matchingFlags count]>1) {
            *stop = YES;
            *error = [NSError errorWithDomain:kFSAPErrorDomain code:TooManySignatures userInfo:[NSDictionary dictionaryWithObjectsAndKeys:signature, FSAPErrorDictKeys.TooManyOfThisSignature,
                                                                                                [NSNumber numberWithUnsignedInteger:[matchingFlags count]], FSAPErrorDictKeys.CountOfTooManySignatures, nil]];
        } else if ([signature isRequired]&&[matchingFlags count]==0) {
            *stop = YES;
            *error = [NSError errorWithDomain:kFSAPErrorDomain code:MissingSignature userInfo:[NSDictionary dictionaryWithObject:signature forKey:FSAPErrorDictKeys.MissingSignatureOfType]];
        }
        NSMutableIndexSet * toKill = [[NSMutableIndexSet alloc] init];
        [matchingFlags enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *index_stop) {
            if (idx+1 == [args count]) { // array index out of bounds
                *index_stop = YES;
                *stop = YES;
                *error = [NSError errorWithDomain:kFSAPErrorDomain code:ArgumentMissingValue userInfo:[NSDictionary dictionaryWithObject:signature forKey:FSAPErrorDictKeys.ArgumentOfTypeMissingValue]];
            }
            NSString * arg = [args objectAtIndex:idx+1];
            if ([namedArguments objectForKey:signature]==nil && [signature isMultipleAllowed])
                [namedArguments setObject:[NSMutableArray array] forKey:signature];
            if ([signature isMultipleAllowed]) [[namedArguments objectForKey:signature] addObject:arg];
            else [namedArguments setObject:arg forKey:signature];
            [toKill addIndexesInRange:NSMakeRange(idx, 1)];
        }];
        [args removeObjectsAtIndexes:toKill];
    }]; if (*error) return nil;
    
    // flags next
    [[signatures filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSArgumentSignature * evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isFlag];
    }]] enumerateObjectsUsingBlock:^(FSArgumentSignature * signature, NSUInteger idx, BOOL *stop) {
        NSIndexSet * matchingFlags = [args indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [signature.names containsObject:obj];
        }];
        if (![signature isMultipleAllowed]&&[matchingFlags count]>1) {
            *stop = YES;
            *error = [NSError errorWithDomain:kFSAPErrorDomain code:TooManySignatures userInfo:[NSDictionary dictionaryWithObjectsAndKeys:signature, FSAPErrorDictKeys.TooManyOfThisSignature,
                                                                                                [NSNumber numberWithUnsignedInteger:[matchingFlags count]], FSAPErrorDictKeys.CountOfTooManySignatures, nil]];
        } else if ([signature isRequired]&&[matchingFlags count]==0) {
            *stop = YES;
            *error = [NSError errorWithDomain:kFSAPErrorDomain code:MissingSignature userInfo:[NSDictionary dictionaryWithObject:signature forKey:FSAPErrorDictKeys.MissingSignatureOfType]];
        }
        [flags setObject:[NSNumber numberWithUnsignedInteger:[matchingFlags count]] forKey:signature];
        [args removeObjectsAtIndexes:matchingFlags];
     }];
    
    return [FSArgumentPackage argumentPackageWithFlags:[flags copy] namedArguments:[namedArguments copy] unnamedArguments:[args copy]];
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
