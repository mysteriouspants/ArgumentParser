//
//  FSCountedArgument.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "FSCountedArgument.h"
#import "FSArgumentSignature_Internal.h"
#import "FSArguments_Coalescer_Internal.h"
#import "NSString+Indenter.h"

// used in computing the hash value
#import <CommonCrypto/CommonDigest.h>

@implementation FSCountedArgument

@synthesize switchAliases = _switchAliases;
@synthesize longAliases = _longAliases;

@synthesize shouldAllowMultipleInvocations = _shouldAllowMultipleInvocations;

+ (id)countedArgumentWithSwitches:(id)switchAliases longAliases:(id)longAliases allowMultipleInvocations:(bool)shouldAllowMultipleInvocations
{
    return [[self alloc] initWithSwitches:switchAliases longAliases:longAliases allowMultipleInvocations:shouldAllowMultipleInvocations];
}

- (id)initWithSwitches:(id)switchAliases longAliases:(id)longAliases allowMultipleInvocations:(bool)shouldAllowMultipleInvocations
{
    self = [super init];
    
    if (self) {
        _switchAliases = __fsargs_coalesceToCharacterSet(switchAliases);
        _longAliases = __fsargs_coalesceToSet(longAliases);
        _shouldAllowMultipleInvocations = shouldAllowMultipleInvocations;
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
    
    NSString * unmangled = [NSString stringWithFormat:@"%@ %@\nallowsMultipleInvocations: %@\nnullifiesRequired: %@\nnullifiesRequiredAncestorPropagation: %lu\nnullifiesRequiredDescendentPropagation: %lu", [switches componentsJoinedByString:@" "], [[_longAliases allObjects] componentsJoinedByString:@" "], _shouldAllowMultipleInvocations?@"true":@"false", [self nullifyRequired]?@"true":@"false", [self nullifyRequiredAncestorPropagation], [self nullifyRequiredDescendentPropagation]];
    
    NSMutableString * s = [unmangled fsargs_mutableStringByIndentingToWidth:indent*2 lineLength:width];
    
    for (FSArgumentSignature * signature in [self injectedArguments]) {
        [s appendString:[signature descriptionForHelp:indent+1 terminalWidth:width]];
    }
    
    return [s copy];
}

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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p switches:%@ longAliases:%@ shouldAllowMultipleInvocations:%@>", NSStringFromClass([self class]), self, __fsargs_charactersFromCharacterSetAsString(_switchAliases), [[_longAliases allObjects] componentsJoinedByString:@","], _shouldAllowMultipleInvocations?@"true":@"false"];
}

@end
