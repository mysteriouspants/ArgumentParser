//
//  FSValuedArgument.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "FSValuedArgument.h"
#import "FSArgumentSignature_Private.h"
#import "FSArguments_Coalescer_Internal.h"
#import "NSString+Indenter.h"

// used in computing the hash value
#import <CommonCrypto/CommonDigest.h>

@implementation FSValuedArgument

@synthesize valuesPerInvocation = _valuesPerInvocation;

+ (id)valuedArgumentWithSwitches:(id)switches aliases:(id)aliases
{
    return [[self alloc] initWithSwitches:switches aliases:aliases];
}

- (id)initWithSwitches:(id)switches aliases:(id)aliases
{
    return [super initWithSwitches:switches aliases:aliases];
}

+ (id)valuedArgumentWithSwitches:(id)switches aliases:(id)aliases valuesPerInvocation:(NSRange)valuesPerInvocation
{
    return [[self alloc] initWithSwitches:switches aliases:aliases valuesPerInvocation:valuesPerInvocation];
}

- (id)initWithSwitches:(id)switches aliases:(id)aliases valuesPerInvocation:(NSRange)valuesPerInvocation
{
    self = [super initWithSwitches:switches aliases:aliases];
    
    if (self) {
        _valuesPerInvocation = valuesPerInvocation;
    }
    
    return self;
}


#pragma mark FSArgumentSignature

- (NSString *)descriptionForHelp:(NSUInteger)indent terminalWidth:(NSUInteger)width
{
    if (self.descriptionHelper)
        return self.descriptionHelper(self, indent, width);
    
    if (width < 20) width = 20; // just make sure
    
    NSMutableString * prefix = [NSMutableString stringWithCapacity:indent*2];
    for (NSUInteger i = 0;
         i < indent * 2;
         ++i) [prefix appendString:@" "];
    
    NSMutableArray * invocations = [NSMutableArray arrayWithCapacity:[_switches count] + [_aliases count]];
    [invocations addObjectsFromArray:__fsargs_expandAllSwitches(_switches)];
    [invocations addObjectsFromArray:[_aliases allObjects]];
    
    NSString * unmangled = [NSString stringWithFormat:@"[%@]={%lu,%lu}", [invocations componentsJoinedByString:@" "], _valuesPerInvocation.location, _valuesPerInvocation.length];
    
    NSMutableString * s = [unmangled fsargs_mutableStringByIndentingToWidth:indent*2 lineLength:width];
    
    for (FSArgumentSignature * signature in _injectedSignatures) {
        [s appendString:[signature descriptionForHelp:indent+1 terminalWidth:width]];
    }
    
    return [s copy];
}

#pragma mark NSCopying

- (id)copy
{
    FSValuedArgument * copy = [super copy];
    
    if (copy) {
        copy->_valuesPerInvocation = _valuesPerInvocation;
    }
    
    return copy;
}

#pragma mark NSObject

- (id)init
{
    self = [super init];
    
    if (self) {
        _valuesPerInvocation = NSMakeRange(1, 1);
    }
    
    return self;
}

- (NSUInteger)hash
{
    // use an MD5 hash to determine the uniqueness of the counted argument.
    // Injected sub-arguments are not considered.
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);

    [super updateHash:&md5];
    
    CC_MD5_Update(&md5, (const void *)&_valuesPerInvocation, sizeof(NSUInteger));
    
    unsigned char md5_final[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(md5_final, &md5);
    return *((NSUInteger *)md5_final);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p switches:[%@] aliases:[%@] valuesPerInvocation:%@>", NSStringFromClass([self class]), self, [__fsargs_expandAllSwitches(_switches) componentsJoinedByString:@" "], [[_aliases allObjects] componentsJoinedByString:@" "], NSStringFromRange(_valuesPerInvocation)];
}

@end
