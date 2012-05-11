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

/* This is a scary function which scans the argument array for items that can be extracted using the provided signatures. The overall process is:
 *
 * 1. Scan the signature array for purity. If there's an object which doesn't implement FSArgumentSignature, then an error is thrown.
 * 2. Scan the signature array for conflicting signatures. This means that if we have two different signature objects which want the same flag, we'll be able to throw an error.
 * 3. Sort the signatures into two groups: flags and named arguments. This makes lookup during scanning slightly easier.
 */
+ (FSArgumentPackage *)parseArguments:(NSArray *)_args withSignatures:(NSArray *)signatures error:(__autoreleasing NSError **)error
{
    NSMutableArray * args = [_args mutableCopy];
    
    /* check for purity in signature array */ // see step 1
    [signatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[FSArgumentSignature class]]) {
            *error = [NSError errorWithDomain:kFSAPErrorDomain code:ImpureSignatureArray userInfo:[NSDictionary dictionaryWithObjectsAndKeys:obj, FSAPErrorDictKeys.ImpureSignatureObject,
                                                                                                   [NSNumber numberWithUnsignedInteger:idx], FSAPErrorDictKeys.ImpureSignatureLocation, nil]];
            *stop = YES;
        }
    }]; if (*error) return nil;
    
    /* check for conflicting signatures */ // see step 2 
    [signatures enumerateObjectsUsingBlock:^(FSArgumentSignature * signature, NSUInteger signature_idx, BOOL *signature_stop) {
	
	/* scan the shortnames for conflicts */
	
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

	/* scan the long names for conflicts */

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
    
    // these little darlings get to be copied over into the final argument package
    NSMutableDictionary * flags = [[NSMutableDictionary alloc] init]; /* These are all flags that have been set. It's empty now, but gets populated with false values later. */
    NSMutableDictionary * namedArguments = [[NSMutableDictionary alloc] init]; /* These are all named arguments. It's supposed to be empty. */
    NSMutableArray * unnamedArguments = [[NSMutableArray alloc] init]; /* Unnamed arguments are essentially everything that is left over after the detected arguments are found.
                                                                        * They will be in the order of how they were originally found in the array. */
    /* the following are sorted bits from the signatures array */
    NSMutableSet * flagSignatures = [[NSMutableSet alloc] init]; // all the flag signatures
    NSMutableCharacterSet * flagCharacters = [[NSMutableCharacterSet alloc] init]; // all the flag characters. If the character is in this set, congrats! it's a flag
    NSMutableArray * flagNames = [[NSMutableArray alloc] init]; // All the flag names, eg. names that correspond to a flag signature. If the string is in this array, congrats! it's a flag
    NSMutableSet * notFlagSignatures = [[NSMutableSet alloc] init]; // if it ain't a flag, then it's in this signature array.
    // actually perform the sorting. see step 3
    [signatures enumerateObjectsUsingBlock:^(FSArgumentSignature * obj, NSUInteger idx, BOOL *stop) {
        if (obj.isFlag) {
            [flagSignatures addObject:obj];
            [flagCharacters formUnionWithCharacterSet:obj.shortNames];
            [flagNames addObjectsFromArray:obj.longNames];
            [flags setObject:[NSNumber numberWithUnsignedInteger:0] forKey:obj]; // initialize the value of the flag to false.
            /* a note on implementation decisions:
             * 
             * I have chosen it such that every single flag shall be false. If the flag does not appear at all, it's false. It used to be in a previous iteration that it would be nil, which is a very bad idea. it created obnoxious nil checks which had to be reinterpreted as false, etc. it was just bad.
             *
             * this is a lot better.
             */
        }
        else [notFlagSignatures addObject:obj]; // seems obvious, right?
    }];
    
    // these are some regexen that define whether or not a given string (from the arg array) is a flag, named argument, or isn't a value.

    // Matches -anything, but NOT --anything.
    NSRegularExpression * flagDetector = [NSRegularExpression regularExpressionWithPattern:@"^[\\-][^\\-]*$" options:0 error:error];
    if (*error) return nil; // asplode if my regexen fails
    // Match --anything, but NOT -anything. Ain't that spiffy?
    NSRegularExpression * namedArgumentDetector = [NSRegularExpression regularExpressionWithPattern:@"^[\\-]{2}.*$" options:0 error:error];
    if (*error) return nil;
    /* This is a general catch-all that signifies that something ISN'T a value and should be ignored by the value grabber.
     *
     * In explainum: consider the following invocation:
     *
     *   foo -cfg --no-bar file.txt
     *
     * Imagine for a moment that the -f is a named argument. The parser is going to want to pop forward and grab '--no-bar' as the value. HOWEVER, because --no-bar doesn't match the isntValueDetector, it's excluded. So the parser will move forward again to file.txt (which makes more sense, right?) Just nod your head, because it makes a lot more sense.
     *
     * In the event that a stupid invocation is given, like, say, this:
     *
     *   foo -cfg --no-bar
     *
     * The scanner will perform reliably and tell you that there is no value given to the -f argument. As a note, how would you pass in a file that begins with a dash?
     *
     *   foo -cfg ./--no-bar.txt
     *
     * I know, smart-ass answer, but hey... it's what you do.
     */
    NSRegularExpression * isntValueDetector = [NSRegularExpression regularExpressionWithPattern:@"^\\-" options:0 error:error];
    if (*error) return nil;
    
    /* this begins the biggest piece of evil ever. comments have been added for entertainment purposes */
    while (0<[args count]) { // we use a wonky iteration because we're tearing elements out of the array during iteration. Thus we can't use fast enumeration. Once an element is parsed (sorted into a bucket, either a flag increment, named argument value, or as an unnamed argument) it's removed from the source array which means that it's done. Gone. Boom. Parsed. When everything is gone (0==[args count]) then it's considered parsed. ¿Comprendé?

        NSString * arg = [args objectAtIndex:0]; // this is the root arg we'll be working with this iteration. We may pull other args later
        [args removeObjectAtIndex:0];

        if (0<[flagDetector numberOfMatchesInString:arg options:0 range:NSMakeRange(0, [arg length])]) { // if this is a flag, eg. a -f instead of a --file

            /* Because flags can have many bretheren and sisteren in their invocations (eg. -cfg is equivalent to -c -f -g) we need to treat each flag individually. */

            for (NSUInteger i = 1; // starting at 1 ignores the prefixed -
                    i < [arg length];
                    ++i) {
                unichar c = [arg characterAtIndex:i];

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
                else if (!as.isMultipleAllowed && [count unsignedIntegerValue]>0) {
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
    // check for an exclusive signature
    NSArray * allExclusiveArguments = [signatures filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FSArgumentSignature * signature, NSDictionary *bindings) {
        return [signature isExclusive]==YES;
    }]];
    BOOL hasExclusiveArgument = NO;
    for (FSArgumentSignature * signature in allExclusiveArguments)
        if ([pkg boolValueOfFlag:signature]) {
            hasExclusiveArgument = YES;
            break;
        }
    
    if (0<[allRequiredSignatures count]&&!hasExclusiveArgument) {
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
