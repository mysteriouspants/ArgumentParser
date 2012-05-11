//
//  FSArgumentSignature.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/22/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentSignature.h"
#import "FSArgumentSignature_Internal.h"
#import "FSExplicitArgument.h"
#import "FSCountedArgument.h"
#import "FSValuedArgument.h"
#import "FSCommandArgument.h"

// used in computing the hash value
#import <CommonCrypto/CommonDigest.h>

@implementation FSArgumentSignature

@synthesize injectedArguments = _injectedArguments;

@synthesize nullifyRequired = _nullifyRequired;
@synthesize nullifyRequiredAncestorPropagation = _nullifyRequiredAncestorPropagation;
@synthesize nullifyRequiredDescendentPropagation = _nullifyRequiredDescendentPropagation;

@synthesize descriptionHelper = _descriptionHelper;

- (NSString *)descriptionForHelp:(NSUInteger)indent terminalWidth:(NSUInteger)width
{
    return [NSString stringWithFormat:@"Hey, you found the root object. This isn't actually supposed to be an argument though, just a kind of pure virtual class. It isn't really, so you haven't done anything wrong though."];
}

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
    
    copy->_injectedArguments = _injectedArguments;
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

- (id)init
{
    self = [super init];
    
    if (self) {
        _nullifyRequired = false;
        _nullifyRequiredAncestorPropagation = 0;
        _nullifyRequiredDescendentPropagation = 0;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object class] == [self class])
        return [object hash] == [self hash];
    else
        return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass([self class]), self];
}

@end
