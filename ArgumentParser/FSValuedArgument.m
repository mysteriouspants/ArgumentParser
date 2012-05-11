//
//  FSValuedArgument.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "FSValuedArgument.h"
#import "FSArgumentSignature_Internal.h"
#import "FSArguments_Coalescer_Internal.h"

// used in computing the hash value
#import <CommonCrypto/CommonDigest.h>

@implementation FSValuedArgument

@synthesize switchAliases = _switchAliases;
@synthesize longAliases = _longAliases;

@synthesize shouldAllowMultipleInvocations = _shouldAllowMultipleInvocations;

@synthesize required = _required;

@synthesize valuesPerInvocation = _valuesPerInvocation;

@synthesize shouldGrabBeyondBarrier = _shouldGrabBeyondBarrier;

+ (id)valuedArgumentWithSwitches:(id)switchAliases longAliases:(id)longAliases allowsMultipleInvocations:(bool)shouldAllowMultipleInvocations required:(bool)required
{
    return [[self alloc] initWithSwitches:switchAliases longAliases:longAliases allowMultipleInvocations:shouldAllowMultipleInvocations required:required];
}

+ (id)valuedArgumentWithSwitches:(id)switchAliases longAliases:(id)longAliases allowsMultipleInvocations:(bool)shouldAllowMultipleInvocations required:(bool)required valuesPerInvocation:(NSUInteger)valuesPerInvocation grabBeyondBarrier:(bool)shouldGrabBeyondBarrier
{
    return [[self alloc] initWithSwitches:switchAliases longAliases:longAliases allowMultipleInvocations:shouldAllowMultipleInvocations required:required valuesPerInvocation:valuesPerInvocation grabBeyondBarrier:shouldGrabBeyondBarrier];
}

- (id)initWithSwitches:(id)switchAliases longAliases:(id)longAliases allowMultipleInvocations:(bool)shouldAllowMultipleInvocations required:(bool)required
{
    self = [super init];
    
    if (self) {
        _switchAliases = __fsargs_coalesceToCharacterSet(switchAliases);
        _longAliases = __fsargs_coalesceToSet(longAliases);
        _shouldAllowMultipleInvocations = shouldAllowMultipleInvocations;
        _required = required;
        _valuesPerInvocation = 1;
        _shouldGrabBeyondBarrier = false;
    }
    
    return self;
}

- (id)initWithSwitches:(id)switchAliases longAliases:(id)longAliases allowMultipleInvocations:(bool)shouldAllowMultipleInvocations required:(bool)required valuesPerInvocation:(NSUInteger)valuesPerInvocation grabBeyondBarrier:(bool)shouldGrabBeyondBarrier
{
    self = [super init];
    
    if (self) {
        _switchAliases = __fsargs_coalesceToCharacterSet(switchAliases);
        _longAliases = __fsargs_coalesceToSet(longAliases);
        _shouldAllowMultipleInvocations = shouldAllowMultipleInvocations;
        _required = required;
        _valuesPerInvocation = valuesPerInvocation;
        _shouldGrabBeyondBarrier = shouldAllowMultipleInvocations;
    }
    
    return self;
}

#pragma mark NSCopying

- (id)copy
{
    FSValuedArgument * copy = [super copy];
    
    if (copy) {
        copy->_switchAliases = _switchAliases;
        copy->_longAliases = _longAliases;
        copy->_shouldAllowMultipleInvocations = _shouldAllowMultipleInvocations;
        copy->_required = _required;
        copy->_valuesPerInvocation = _valuesPerInvocation;
        copy->_shouldGrabBeyondBarrier = _shouldGrabBeyondBarrier;
    }
    
    return copy;
}

#pragma mark NSObject

- (NSUInteger)hash
{
    // use an MD5 hash to determine the uniqueness of the counted argument.
    // Injected sub-arguments are not considered.
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    
    [super internal_updateMD5:&md5]; // add shared stuff to the hash
    
    CC_MD5_Update(&md5, (const void *)&_shouldAllowMultipleInvocations, sizeof(bool));
    CC_MD5_Update(&md5, (const void *)&_required, sizeof(bool));
    CC_MD5_Update(&md5, (const void *)&_valuesPerInvocation, sizeof(NSUInteger));
    CC_MD5_Update(&md5, (const void *)&_shouldGrabBeyondBarrier, sizeof(bool));
    
    NSUInteger shortnameshash = [_switchAliases hash];
    CC_MD5_Update(&md5, (const void*)&shortnameshash, sizeof(NSUInteger));
    for (id o in _longAliases) {
        NSUInteger longnamehash = [[o description] hash];
        CC_MD5_Update(&md5, (const void*)&longnamehash, sizeof(NSUInteger));
    }
    unsigned char* md5_final = (unsigned char*)malloc(sizeof(unsigned char)*CC_MD5_DIGEST_LENGTH);
    CC_MD5_Final(md5_final, &md5);
    return *((NSUInteger *)md5_final);
}

@end
