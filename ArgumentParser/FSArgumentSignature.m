//
//  FSArgumentSignature.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/22/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentSignature.h"

// used in computing the hash value
#import <CommonCrypto/CommonDigest.h>

@implementation FSArgumentSignature

@synthesize positiveInjectors = _positiveInjectors;
@synthesize negativeInjectors = _negativeInjectors;

@synthesize nullifyRequired = _nullifyRequired;
@synthesize nullifyRequiredAncestorPropagation = _nullifyRequiredAncestorPropagation;
@synthesize nullifyRequiredDescendentPropagation = _nullifyRequiredDescendentPropagation;

#pragma mark Internal

- (void)internal_updateMD5:(CC_MD5_CTX *)md5
{
    CC_MD5_Update(md5, (const void *)&_nullifyRequired, sizeof(bool));
    CC_MD5_Update(md5, (const void *)&_nullifyRequiredAncestorPropagation, sizeof(NSUInteger));
    CC_MD5_Update(md5, (const void *)&_nullifyRequiredDescendentPropagation, sizeof(NSUInteger));
}

#pragma mark NSCopying

- (id)copy
{
    FSArgumentSignature * copy = [[[self class] alloc] init];
    
    copy->_positiveInjectors = _positiveInjectors;
    copy->_negativeInjectors = _negativeInjectors;
    copy->_nullifyRequired = _nullifyRequired;
    copy->_nullifyRequiredAncestorPropagation = _nullifyRequiredAncestorPropagation;
    copy->_nullifyRequiredDescendentPropagation = _nullifyRequiredDescendentPropagation;
    
    return copy;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self copy];
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object
{
    if ([object class] == [self class])
        return [object hash] == [self hash];
    else
        return NO;
}

@end
