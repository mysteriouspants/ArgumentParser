//
//  NSString+FilledString.m
//  ArgumentParser
//
//  Created by Chris Miller on 12/31/13.
//  Copyright (c) 2013 Christopher Miller. All rights reserved.
//

#import "NSString+FilledString.h"

@implementation NSString (FilledString)
+ (NSString *)fs_stringByFillingWithCharacter:(char)character repeated:(NSUInteger)times
{
    char* f = malloc(sizeof(char)*times);
    
    f = memset(f, character, times); // memset may be implemented in assembler, which has some really spiffy bits to make filling memory blocks super-fast.
    // It's fair to expect OS X to have an optimized memset; ObjC zero-fills new objects, so using memset for that AND having that super-optimized makes sense.
    // So, by using memset we get to piggy-back on their work, for free.
    return [[NSString alloc] initWithBytesNoCopy:f length:times encoding:NSASCIIStringEncoding freeWhenDone:YES];
}
+ (NSString *)fs_stringByFillingWithString:(NSString *)string repeated:(NSUInteger)times
{
    NSMutableString * s = [NSMutableString stringWithCapacity:[string length]*times];
    for (NSUInteger i=0;
         i<times;
         ++i) [s appendString:string];
    return s;
}
@end
