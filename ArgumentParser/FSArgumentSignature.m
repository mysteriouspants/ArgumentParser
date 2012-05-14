//
//  FSArgumentSignature.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/22/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentSignature.h"
#import "FSArgumentSignature_Private.h"
#import "FSArguments_Coalescer_Internal.h"

#import "FSCountedArgument.h"
#import "FSValuedArgument.h"

// used in computing the hash value
#import <CommonCrypto/CommonDigest.h>

@implementation FSArgumentSignature

@synthesize switches = _switches;
@synthesize aliases = _aliases;

@synthesize injectedSignatures = _injectedSignatures;
@synthesize descriptionHelper = _descriptionHelper;

- (id)initWithSwitches:(id)switches aliases:(id)aliases
{
    self = [self init];
    
    if (self) {
        _switches = switches?:_switches; // keep empty set
        _aliases = aliases?:_aliases; // keep empty set
    }
    
    return self;
}

- (NSString *)descriptionForHelp:(NSUInteger)indent terminalWidth:(NSUInteger)width
{
    return [NSString stringWithFormat:@"Hey, you found the root object. This isn't actually supposed to be an argument though, just a kind of pure virtual class. It isn't really, so you haven't done anything wrong though."];
}

#pragma mark Private Implementation

- (void)updateHash:(CC_MD5_CTX *)md5
{
    // note that _injectedSignatures and _descriptionHelper is ignored in the uniqueness evaluation
    
    // add the class name too, just to make it more unique
    NSUInteger classHash = [NSStringFromClass([self class]) hash];
    CC_MD5_Update(md5, (const void *)&classHash, sizeof(NSUInteger));
    
    for (NSString * s in _switches) {
        NSUInteger hash = [__fsargs_expandSwitch(s) hash];
        CC_MD5_Update(md5, (const void *)&hash, sizeof(NSUInteger));
    }
    
    for (NSString * s in _aliases) {
        NSUInteger hash = [s hash];
        CC_MD5_Update(md5, (const void *)&hash, sizeof(NSUInteger));
    }
}

#pragma mark NSCopying

- (id)copy
{
    FSArgumentSignature * copy = [[[self class] alloc] initWithSwitches:_switches aliases:_aliases];
    
    if (copy) {
        copy->_injectedSignatures = _injectedSignatures;
    }
    
    return copy;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self copy];
}

#pragma mark NSObject

- (id)init
{
    if ([self class] == [FSArgumentSignature class]) {
        [NSException raise:@"net.fsdev.ArgumentParser.VirtualClassInitializedException" format:@"This is supposed to be a pure-virtual class. Please use either %@ or %@ instead of directly using this class.", NSStringFromClass([FSCountedArgument class]), NSStringFromClass([FSValuedArgument class])];
    }
    
    self = [super init];
    
    if (self) {
        _injectedSignatures = [NSSet set];
        _switches = [NSSet set];
        _aliases = [NSSet set];
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
