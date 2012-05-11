//
//  FSArgumentParser.h
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/23/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

/*@class FSArgumentPackage;

enum FSArgumentParserErrorCodes {
    ImpureSignatureArray=0, //! something in the signature array with isn't an FSArgumentSignature
    OverlappingArgument=1, //! some arguments in the signature array which share the same flag
    TooManySignatures=2, //! more than one signature that doesn't allow multiple signatures per invocation
    MissingSignatures=3, //! missing flag or argument which is marked as required
    ArgumentMissingValue=4, //! all arguments need a value, and this one is missing that value
    UnknownArgument=5, //! this argument doesn't have a matching signature
};

extern const NSString * kFSAPErrorDomain;

extern const struct FSAPErrorDictKeys {
    // ImpureSignatureArray
    __unsafe_unretained NSString * ImpureSignatureObject; //! the object in question
    __unsafe_unretained NSString * ImpureSignatureLocation; //! where in the array was it found
    // OverlappingArgument
    __unsafe_unretained NSString * OverlappingArgumentName; //! which name are they fighting over (either an NSString * or an NSCharacterSet *)
    __unsafe_unretained NSString * OverlappingArgumentSignature1; //! the first signature
    __unsafe_unretained NSString * OverlappingArgumentSignature2; //! the second signature
    // TooManySignatures
    __unsafe_unretained NSString * TooManyOfThisSignature; //! which kind of signature
    __unsafe_unretained NSString * CountOfTooManySignatures; //! how many of them are there
    // MissingSignatures
    __unsafe_unretained NSString * MissingTheseSignatures; //! which signature is 404'd?
    // ArgumentMissingValue
    __unsafe_unretained NSString * ArgumentOfTypeMissingValue; //! every argument needs a value, and this one is missing
    // UnknownArgument
    __unsafe_unretained NSString * UnknownSignature; //! Either the character (NSNumber *) or string (NSString *) that isn't matched by any known FSArgumentSignature *
} FSAPErrorDictKeys;*/

@interface FSArgumentParser : NSObject

//+ (FSArgumentPackage *)parseArguments:(NSArray *)args withSignatures:(NSArray *)signatures error:(__autoreleasing NSError **)error;

@end
