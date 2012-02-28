//
//  FSArgumentSignature.m
//  fs-dataman
//
//  Created by Christopher Miller on 2/22/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentSignature.h"

#import <CommonCrypto/CommonDigest.h>

#include <stdio.h>
#include <sys/ioctl.h>

NSCharacterSet * __fsargs_coalesceToCharacterSet(id);
NSArray * __fsargs_coalesceToArray(id);

@implementation FSArgumentSignature

@synthesize shortNames=_shortNames;
@synthesize longNames=_longNames;
@synthesize flag=_flag;
@synthesize required=_required;
@synthesize multipleAllowed=_multipleAllowed;
@synthesize signatureDescription=_signatureDescription;
@synthesize signatureDescriptionDelegate=_signatureDescriptionDelegate;
@synthesize signatureDescriptionDelegateMethod=_signatureDescriptionDelegateMethod;
@synthesize signatureDescriptionBlock=_signatureDescriptionBlock;

#pragma mark Flag Signature Constructors

+ (id)argumentSignatureAsFlag:(id)shortName longNames:(id)longNames multipleAllowed:(BOOL)multipleAllowed description:(NSString *)description delegate:(id)delegate selector:(SEL)selector block:(NSString *(^)())block
{
    FSArgumentSignature * siggy = [[[self class] alloc] init];
    if (!siggy) return siggy;
    siggy->_flag = YES;
    siggy->_multipleAllowed = multipleAllowed;
    siggy->_required = NO;
    siggy->_shortNames = __fsargs_coalesceToCharacterSet(shortName);
    siggy->_longNames = __fsargs_coalesceToArray(longNames);
    siggy->_signatureDescription = description;
    siggy->_signatureDescriptionDelegate = delegate;
    siggy->_signatureDescriptionDelegateMethod = selector;
    siggy->_signatureDescriptionBlock = block;
    return siggy;
}
+ (id)argumentSignatureAsFlag:(id)shortName longNames:(id)longNames multipleAllowed:(BOOL)multipleAllowed {
    return [[self class] argumentSignatureAsFlag:shortName longNames:longNames multipleAllowed:multipleAllowed description:nil delegate:nil selector:nil block:nil];
}
+ (id)argumentSignatureAsFlag:(id)shortName longNames:(id)longNames multipleAllowed:(BOOL)multipleAllowed description:(NSString *)description {
    return [[self class] argumentSignatureAsFlag:shortName longNames:longNames multipleAllowed:multipleAllowed description:description delegate:nil selector:nil block:nil];
}
+ (id)argumentSignatureAsFlag:(id)shortName longNames:(id)longNames multipleAllowed:(BOOL)multipleAllowed delegate:(id)delegate selector:(SEL)selector {
    return [[self class] argumentSignatureAsFlag:shortName longNames:longNames multipleAllowed:multipleAllowed description:nil delegate:delegate selector:selector block:nil];
}
+ (id)argumentSignatureAsFlag:(id)shortName longNames:(id)longNames multipleAllowed:(BOOL)multipleAllowed block:(NSString *(^)())block {
    return [[self class] argumentSignatureAsFlag:shortName longNames:longNames multipleAllowed:multipleAllowed description:nil delegate:nil selector:nil block:block];
}

#pragma mark Named Argument Signature Constructors

+ (id)argumentSignatureAsNamedArgument:(id)shortName longNames:(id)longNames required:(BOOL)required multipleAllowed:(BOOL)multipleAllowed description:(NSString *)description delegate:(id)delegate selector:(SEL)selector block:(NSString *(^)())block 
{
    FSArgumentSignature * siggy = [[[self class] alloc] init];
    if (!siggy) return siggy;
    siggy->_flag = NO;
    siggy->_multipleAllowed = multipleAllowed;
    siggy->_required = required;
    siggy->_shortNames = __fsargs_coalesceToCharacterSet(shortName);
    siggy->_longNames = __fsargs_coalesceToArray(longNames);
    siggy->_signatureDescription = description;
    siggy->_signatureDescriptionDelegate = delegate;
    siggy->_signatureDescriptionDelegateMethod = selector;
    siggy->_signatureDescriptionBlock = block;
    return siggy;
}
+ (id)argumentSignatureAsNamedArgument:(id)shortName longNames:(id)longNames required:(BOOL)required multipleAllowed:(BOOL)multipleAllowed {
    return [[self class] argumentSignatureAsNamedArgument:shortName longNames:longNames required:required multipleAllowed:multipleAllowed description:nil delegate:nil selector:nil block:nil];
}
+ (id)argumentSignatureAsNamedArgument:(id)shortName longNames:(id)longNames required:(BOOL)required multipleAllowed:(BOOL)multipleAllowed description:(NSString *)description {
    return [[self class] argumentSignatureAsNamedArgument:shortName longNames:longNames required:required multipleAllowed:multipleAllowed description:description delegate:nil selector:nil block:nil];
}
+ (id)argumentSignatureAsNamedArgument:(id)shortName longNames:(id)longNames required:(BOOL)required multipleAllowed:(BOOL)multipleAllowed delegate:(id)delegate selector:(SEL)selector {
    return [[self class] argumentSignatureAsNamedArgument:shortName longNames:longNames required:required multipleAllowed:multipleAllowed description:nil delegate:delegate selector:selector block:nil];
}
+ (id)argumentSignatureAsNamedArgument:(id)shortName longNames:(id)longNames required:(BOOL)required multipleAllowed:(BOOL)multipleAllowed block:(NSString *(^)())block {
    return [[self class] argumentSignatureAsNamedArgument:shortName longNames:longNames required:required multipleAllowed:multipleAllowed description:nil delegate:nil selector:nil block:block];
}

#pragma mark Help Output

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    struct ttysize ts;
    ioctl(0, TIOCGWINSZ, &ts);
    // figure out how much to indent, or just 4 spaces if it's not valid
    ushort indent = level*4;
    if (ts.ts_cols<40) ts.ts_cols = 80; // lldb in xcode sez nonsensical things
    if (indent >= ts.ts_cols) indent = 4;
    // lovingly pilfered from NSContainers+PrettyPrint; not linked because I don't want to add too many weird dependencies
    char* f = malloc(sizeof(char)*indent);
    f = memset(f, ' ', indent);
    NSString * indent_string = [[NSString alloc] initWithBytesNoCopy:f length:indent encoding:NSASCIIStringEncoding freeWhenDone:YES];
    NSMutableString * s = [[NSMutableString alloc] init];
    ushort chunk_size = ts.ts_cols - indent;
    NSString * original = nil;
    if (self.signatureDescription) original = self.signatureDescription;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    else if (self.signatureDescriptionDelegate && self.signatureDescriptionDelegateMethod) original = [self.signatureDescriptionDelegate performSelector:self.signatureDescriptionDelegateMethod];
#pragma clang diagnostic pop
    else if (self.signatureDescriptionBlock) original = self.signatureDescriptionBlock();
    else {
        NSMutableArray * characterSetDesc = [[NSMutableArray alloc] init];
        for (unichar c = 0;
             c < 256;
             ++c)
            if ([self.shortNames characterIsMember:c]) [characterSetDesc addObject:[NSString stringWithFormat:@"-%c", c]];
        original = [NSMutableString stringWithFormat:@"%@ responding to %@ and --%@; required:%@ multipleAllowed:%@",
                    (self.isFlag)?@"Flag":@"Argument",
                    [characterSetDesc componentsJoinedByString:@", "],
                    [self.longNames componentsJoinedByString:@", --"],
                    (self.isRequired)?@"YES":@"NO",
                    (self.isMultipleAllowed)?@"YES":@"NO"];
    }
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    [original enumerateSubstringsInRange:NSMakeRange(0, [original length]) options:NSStringEnumerationByParagraphs usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        NSMutableString * s2 = [[NSMutableString alloc] init];
        
        for (NSUInteger i = 0;
             i < [substring length];
             i+=chunk_size) {
            [s2 appendString:indent_string];
            NSRange r = NSMakeRange(i, (i+chunk_size<[substring length])?chunk_size:[substring length]-i);
            [s2 appendString:[substring substringWithRange:r]];
            [s2 appendString:@"\n"];
        }
        if ([s2 hasSuffix:@"\n"])
            [s2 deleteCharactersInRange:NSMakeRange([s2 length]-1, 1)];
        
        [arr addObject:s2];
    }];
    
    [s appendString:[arr componentsJoinedByString:@"\n"]];
    
    return s;
}

- (NSString *)descriptionWithLocale:(id)locale {
    return [self descriptionWithLocale:nil indent:0];
}

- (NSString *)description {
    return [self descriptionWithLocale:nil indent:0];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [self copy];
}

- (id)copy
{
    FSArgumentSignature * copy = [[FSArgumentSignature alloc] init];
    copy->_flag = _flag;
    copy->_shortNames = _shortNames;
    copy->_longNames = _longNames;
    copy->_required = _required;
    copy->_multipleAllowed = _multipleAllowed;
    copy->_signatureDescription = _signatureDescription;
    copy->_signatureDescriptionDelegate = _signatureDescriptionDelegate;
    copy->_signatureDescriptionDelegateMethod = _signatureDescriptionDelegateMethod;
    copy->_signatureDescriptionBlock = _signatureDescriptionBlock;
    return copy;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    FSArgumentSignature * _object = (FSArgumentSignature *)object;
    if (_object.flag != _flag) return NO;
    if (_object.required != _required) return NO;
    if (_object.multipleAllowed != _required) return NO;
    if (_object.longNames != _longNames) return NO;
    if (_object.shortNames != _shortNames) return NO;
    return YES;
}

- (BOOL)isEqualTo:(id)object
{
    return [self isEqual:object];
}

- (NSUInteger)hash
{
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    NSUInteger flags=0;
    flags=_flag;flags=flags<<1;flags|=_required;flags=flags<<1;flags|=_multipleAllowed;
    CC_MD5_Update(&md5, (const void*)&flags, sizeof(NSUInteger));
    NSUInteger shortnameshash = [_shortNames hash];
    CC_MD5_Update(&md5, (const void*)&shortnameshash, sizeof(NSUInteger));
    for (NSString * s in _longNames) {
        NSUInteger longnamehash = [s hash];
        CC_MD5_Update(&md5, (const void*)&longnamehash, sizeof(NSUInteger));
    }
    unsigned char* md5_final = (unsigned char*)malloc(sizeof(unsigned char)*CC_MD5_DIGEST_LENGTH);
    CC_MD5_Final(md5_final, &md5);
    return *((NSUInteger *)md5_final);
}

@end

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsstring(NSString *);
NSCharacterSet * __fsargs_coalesceToCharacterSet_nsarray(NSArray *);
NSCharacterSet * __fsargs_coalesceToCharacterSet_nsset(NSSet *);
NSCharacterSet * __fsargs_coalesceToCharacterSet_nsorderedset(NSOrderedSet *);
NSCharacterSet * __fsargs_coalesceToCharacterSet_nsobject(NSObject *);

NSCharacterSet * __fsargs_coalesceToCharacterSet(id o) {
    if (o==nil) return nil;
    else if ([o isKindOfClass:[NSString class]]) return __fsargs_coalesceToCharacterSet_nsstring(o);
    else if ([o isKindOfClass:[NSArray class]]) return __fsargs_coalesceToCharacterSet_nsarray(o);
    else if ([o isKindOfClass:[NSSet class]]) return __fsargs_coalesceToCharacterSet_nsset(o);
    else if ([o isKindOfClass:[NSOrderedSet class]]) return __fsargs_coalesceToCharacterSet_nsorderedset(o);
    else return __fsargs_coalesceToCharacterSet_nsobject(o);
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsstring(NSString * s) {
    return [NSCharacterSet characterSetWithCharactersInString:s];
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsarray(NSArray * a) {
    NSMutableCharacterSet * s = [[NSMutableCharacterSet alloc] init];
    [a enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [s formUnionWithCharacterSet:__fsargs_coalesceToCharacterSet(obj)];
    }];
    return s;
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsset(NSSet * s) {
    NSMutableCharacterSet * cs = [[NSMutableCharacterSet alloc] init];
    [s enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [cs formUnionWithCharacterSet:__fsargs_coalesceToCharacterSet(obj)];
    }];
    return cs;
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsorderedset(NSOrderedSet * s) {
    NSMutableCharacterSet * cs = [[NSMutableCharacterSet alloc] init];
    [s enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [cs formUnionWithCharacterSet:__fsargs_coalesceToCharacterSet(obj)];
    }];
    return cs;
}

NSCharacterSet * __fsargs_coalesceToCharacterSet_nsobject(NSObject * o) {
    return __fsargs_coalesceToCharacterSet_nsstring([o description]);
}

NSArray * __fsargs_coalesceToArray(id o) {
    if (!o) return nil;
    else if ([o isKindOfClass:[NSArray class]]) return o;
    else if ([o isKindOfClass:[NSString class]]) return [NSArray arrayWithObject:o];
    else if ([o isKindOfClass:[NSSet class]]||[o isKindOfClass:[NSOrderedSet class]]) return [o allObjects];
    else return [NSArray arrayWithObject:[o description]];
}
