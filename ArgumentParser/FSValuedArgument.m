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
#import "NSString+Indenter.h"

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

#pragma mark FSExplicitArgument

- (NSArray *)switchAliasesAsArray
{
    return __fsargs_charactersFromCharacterSetAsArray(_switchAliases);
}

- (NSString *)switchAliasesAsString
{
    return __fsargs_charactersFromCharacterSetAsString(_switchAliases);
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
    
    NSMutableArray * switches = [[self switchAliasesAsArray] mutableCopy];
    for (NSUInteger i = 0;
         i < [switches count];
         ++i) {
        NSString * character = [switches objectAtIndex:i];
        [switches replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"-%@", character]];
    }
    
    NSString * unmangled = [NSString stringWithFormat:@"%@ %@\nallowsMultipleInvocations: %@\nrequired: %@\nvaluesPerInvocation: %lu\nshouldGrabBeyondBarrier: %@\nnullifiesRequired: %@\nnullifiesRequiredAncestorPropagation: %lu\nnullifiesRequiredDescendentPropagation: %lu", [switches componentsJoinedByString:@" "], [[_longAliases allObjects] componentsJoinedByString:@" "], _shouldAllowMultipleInvocations?@"true":@"false", _required?@"true":@"false", _valuesPerInvocation, _shouldGrabBeyondBarrier?@"true":@"false", [self nullifyRequired]?@"true":@"false", [self nullifyRequiredAncestorPropagation], [self nullifyRequiredDescendentPropagation]];
    
    NSMutableString * s = [unmangled fsargs_mutableStringByIndentingToWidth:indent*2 lineLength:width];
    
    for (FSArgumentSignature * signature in [self injectedArguments]) {
        [s appendString:[signature descriptionForHelp:indent+1 terminalWidth:width]];
    }
    
    return [s copy];
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p switches:%@ longAliases:%@ shouldAllowMultipleInvocations:%@ required:%@ valuesPerInvocation:%lu shouldGrabBeyondBarrier:%@>", NSStringFromClass([self class]), self, __fsargs_charactersFromCharacterSetAsString(_switchAliases), [[_longAliases allObjects] componentsJoinedByString:@","], _shouldAllowMultipleInvocations?@"true":@"false", _required?@"true":@"false", _valuesPerInvocation, _shouldGrabBeyondBarrier?@"true":@"false"];
}

@end
