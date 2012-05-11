//
//  FSCountedArgument.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "FSCountedArgument.h"
#import "FSArgumentSignature_Internal.h"

// used in computing the hash value
#import <CommonCrypto/CommonDigest.h>

@implementation FSCountedArgument

@synthesize switchAliases = _switchAliases;
@synthesize longAliases = _longAliases;

@synthesize shouldAllowMultipleInvocations = _shouldAllowMultipleInvocations;

#pragma mark NSCopying

- (id)copy
{
    FSCountedArgument * copy = [super copy];
    
    if (copy) {
        copy->_switchAliases = _switchAliases;
        copy->_longAliases = _longAliases;
        copy->_shouldAllowMultipleInvocations = _shouldAllowMultipleInvocations;
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
