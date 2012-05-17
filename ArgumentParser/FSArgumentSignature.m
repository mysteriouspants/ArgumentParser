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

// more robust format ctors
#import "CoreParse.h"

#import "FSSwitchRecognizer.h"
#import "FSAliasRecognizer.h"

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
    
    switches = __fsargs_coalesceToSet(switches);
    aliases = __fsargs_coalesceToSet(aliases);
    
    if (self) {
        _switches = switches?:_switches; // keep empty set
        _aliases = aliases?:_aliases; // keep empty set
    }
    
    return self;
}

- (NSString *)descriptionForHelp:(NSUInteger)indent terminalWidth:(NSUInteger)width
{
    return @"";
}

#pragma mark Format String Constructors

+ (id)argumentSignatureWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    FSArgumentSignature * signature = [FSArgumentSignature argumentSignatureWithFormat:format arguments:args];
    
    va_end(args);
    
    return signature;
}

- (id)initWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    self = [self initWithFormat:format arguments:args];
    
    va_end(args);
    
    return self;
}

+ (id)argumentSignatureWithFormat:(NSString *)format arguments:(va_list)args
{
    return [[[self class] alloc] initWithFormat:format arguments:args];
}

- (id)initWithFormat:(NSString *)format arguments:(va_list)args
{
    NSString * input = [[NSString alloc] initWithFormat:format arguments:args];
    
    NSMutableSet * invocationAliases = [NSMutableSet set];
    NSMutableSet * invocationSwitches = [NSMutableSet set];
    bool isValued = false;
    NSRange valuesPerInvocation = NSMakeRange(NSNotFound, 0);
    
    NSError * error;
    NSRegularExpression * generalRegex = __fsargs_generalRegex(&error);
    if (error) {
        [NSException raise:@"net.fsdev.ArgumentParser.RegexConstructionError" format:@"there's been a problem constructing the general regex. error is %@", error];
        return nil;
    }
    
    NSArray * results =
    [generalRegex matchesInString:input options:0 range:NSMakeRange(0, [input length])];
    
    if ([results count]==0)
        return nil; // no match
    
    NSTextCheckingResult * generalResult = [results objectAtIndex:0];
    
    NSAssert([generalResult numberOfRanges]==5, @"expected 6 capture groups. has the regex changed?");
    
    NSRange rAliases = [generalResult rangeAtIndex:1]; NSString * sAliases = rAliases.location==NSNotFound?nil:[input substringWithRange:rAliases]; 
    NSRange rValued = [generalResult rangeAtIndex:2]; NSString * sValued = rValued.location==NSNotFound?nil:[input substringWithRange:rValued];
    NSRange rValuesPerInvocationMinimum = [generalResult rangeAtIndex:3]; NSString * sValuesPerInvocationMinimum = rValuesPerInvocationMinimum.location==NSNotFound?nil:[input substringWithRange:rValuesPerInvocationMinimum];
    NSRange rValuesPerInvocationMaximum = [generalResult rangeAtIndex:4]; NSString * sValuesPerInvocationMaximum = rValuesPerInvocationMaximum.location==NSNotFound?nil:[input substringWithRange:rValuesPerInvocationMaximum];
    
    if (!sAliases) return nil;
    
    // run some stuff on the aliases
    NSScanner * aliasScanner = [NSScanner scannerWithString:sAliases];
    NSCharacterSet * wspace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    while (![aliasScanner isAtEnd]) {
        NSString * s;
        if ([aliasScanner scanUpToCharactersFromSet:wspace intoString:&s]) {
            if ([s hasPrefix:@"--"])
                [invocationSwitches addObject:[s substringFromIndex:2]];
            else if ([s hasPrefix:@"-"])
                [invocationSwitches addObject:[s substringFromIndex:1]];
            else
                [invocationAliases addObject:s];
        }
    }
    
    if (sValued && [sValued isEqualToString:@"="]) isValued = true;
    
    if (isValued) {
        
        if (sValuesPerInvocationMinimum)
            valuesPerInvocation.location = [sValuesPerInvocationMinimum integerValue];
        else
            valuesPerInvocation.location = 1;
        
        if (sValuesPerInvocationMinimum)
            valuesPerInvocation.length = [sValuesPerInvocationMaximum integerValue];
        else
            valuesPerInvocation.length = 1;
        
    } else {
        // if any other bits are set, then it's a malformed format
        
        if (sValuesPerInvocationMaximum || sValuesPerInvocationMinimum)
            return nil;
    }
    
    FSArgumentSignature * retVal;
    
    if (isValued) {
        retVal = [FSValuedArgument valuedArgumentWithSwitches:invocationSwitches aliases:invocationAliases valuesPerInvocation:valuesPerInvocation];
    } else {
        retVal = [FSCountedArgument countedArgumentWithSwitches:invocationSwitches aliases:invocationAliases];
    }
    
    return retVal;
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

- (bool)respondsToSwitch:(NSString *)s
{
    if ([s hasPrefix:@"--"]) s = [s substringFromIndex:2];
    else if ([s hasPrefix:@"-"]) s = [s substringFromIndex:1];
    
    return (bool)[_switches containsObject:s];
}

- (bool)respondsToAlias:(NSString *)alias
{
    return (bool)[_aliases containsObject:alias];
}

+ (CPTokeniser *)formatTokens
{
    static CPTokeniser * expressionTokens;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        expressionTokens = [[CPTokeniser alloc] init];
        [expressionTokens addTokenRecogniser:[CPNumberRecogniser numberRecogniser]];
        [expressionTokens addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
        [expressionTokens addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"["]];
        [expressionTokens addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"]"]];
        [expressionTokens addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"{"]];
        [expressionTokens addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"}"]];
        [expressionTokens addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@","]];
        [expressionTokens addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"="]];
        [expressionTokens addTokenRecogniser:[FSSwitchRecognizer switchRecognizer]];
        [expressionTokens addTokenRecogniser:[FSAliasRecognizer aliasRecognizer]];
    });
    return expressionTokens;
}

+ (CPGrammar *)formatGrammar
{
    static CPGrammar * expressionGrammer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * bnfFormat =
        @"FormatSequence ::= (<FormatInvocation> \" \")+"
        @"";
    });
    return expressionGrammer;
}

+ (CPParser *)formatParser
{
    return nil;
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

NSRegularExpression * __fsargs_generalRegex(NSError ** error)
{
    static NSRegularExpression * r;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        r = [NSRegularExpression regularExpressionWithPattern:@"\\A\\[([^\\]]*)\\](=)?\\{?(\\d)?,?(\\d)?\\}?\\z" options:0 error:error];
        // \A\[([^\]]*)\](=)?\{?(\d)?,?(\d)?\}?\z
        // "[-f --file if]={1,1}"       => "-f --file if", "=", "1", "1", nil
        // "[-f --file if]={1,}"        => "-f --file if", "=", "1", nil, nil
        // "[-f --file if]="            => "-f --file if", "=", nil, nil, nil
    });
    return r;
}
