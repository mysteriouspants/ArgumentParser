//
//  FSArgumentParser.h
//  fs-dataman
//
//  Created by Christopher Miller on 2/23/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSArgumentPackage;

enum FSArgumentParserErrorCodes {
    ImpureSignatureArray, //! something in the signature array with isn't an FSArgumentSignature
    OverlappingArgument, //! some arguments in the signature array which share the same flag
    TooManySignatures, //! more than one signature that doesn't allow multiple signatures per invocation
    MissingSignature, //! missing flag or argument which is marked as required
    ArgumentMissingValue, //! all arguments need a value, and this one is missing that value
};

extern const NSString * kFSAPErrorDomain;

extern const struct FSAPErrorDictKeys {
    // ImpureSignatureArray
    __unsafe_unretained NSString * ImpureSignatureObject; //! the object in question
    __unsafe_unretained NSString * ImpureSignatureLocation; //! where in the array was it found
    // OverlappingArgument
    __unsafe_unretained NSString * OverlappingArgumentName; //! which name are they fighting over
    __unsafe_unretained NSString * OverlappingArgumentSignature1; //! the first signature
    __unsafe_unretained NSString * OverlappingArgumentSignature2; //! the second signature
    // TooManySignatures
    __unsafe_unretained NSString * TooManyOfThisSignature; //! which kind of signature
    __unsafe_unretained NSString * CountOfTooManySignatures; //! how many of them are there
    // MissingSignature
    __unsafe_unretained NSString * MissingSignatureOfType; //! which signature is 404'd?
    // ArgumentMissingValue
    __unsafe_unretained NSString * ArgumentOfTypeMissingValue; //! every argument needs a value, and this one is missing
} FSAPErrorDictKeys;

@interface FSArgumentParser : NSObject

+ (FSArgumentPackage *)parseArguments:(NSArray *)args withSignatures:(NSArray *)signatures error:(NSError **)error;

@end
