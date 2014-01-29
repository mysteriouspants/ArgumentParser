//
//  long-desc.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/28/12.
//  Copyright (c) 2012, 2013 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSArguments.h"
#import "FSArguments_Coalescer_Internal.h" // for __fsargs_expandAllSwitches
#import "NSString+FilledString.h"

#include <stdio.h>
#include <sys/ioctl.h>

int main (int argc, const char * argv[]) {
    @autoreleasepool {
        FSArgumentSignature
            * helpSig = [FSArgumentSignature argumentSignatureWithFormat:@"[-h --help]"],
            * outFileSig = [FSArgumentSignature argumentSignatureWithFormat:@"[-o --out-file]="];
        [outFileSig setDescriptionHelper:^NSString *(FSArgumentSignature * signature, NSUInteger indent, NSUInteger width) {
            NSMutableArray * invocations = [NSMutableArray arrayWithCapacity:[signature.switches count] + [signature.aliases count]];
            [invocations addObjectsFromArray:__fsargs_expandAllSwitches(signature.switches)];
            [invocations addObjectsFromArray:[signature.aliases allObjects]];
            
            NSString * unmangled = [NSString stringWithFormat:@"[%@]", [invocations componentsJoinedByString:@" "]];
            
            NSString * block_text = @"specify zero or more output files. I'm not really sure why you'd want to pipe the output to more than one file, but the main point of this is to show how the program can wrap really long lines without screwing up the indentation.";
            
            NSUInteger block_indent = indent * 4 + [unmangled length];
            
            assert(block_indent + 10 <= width); // ensure that there's some room to print our stuff
            
            NSMutableArray * explodingGarbageCans = [[NSMutableArray alloc] init];
            
            for (NSRange bin_range={0,width-block_indent}; bin_range.location<[block_text length]; bin_range.location += bin_range.length) {
                if (bin_range.length + bin_range.location > [block_text length]) {
                    bin_range.length = [block_text length] - bin_range.location;
                }
                [explodingGarbageCans addObject:[block_text substringWithRange:bin_range]];
            }
            
            explodingGarbageCans[0] = [NSString stringWithFormat:@"%@%@ %@", [NSString fs_stringByFillingWithCharacter:' ' repeated:indent*4], unmangled, explodingGarbageCans[0]];
            for (NSUInteger i = 1; i < [explodingGarbageCans count]; ++i) {
                explodingGarbageCans[i] = [NSString stringWithFormat:@"%@%@", [NSString fs_stringByFillingWithCharacter:' ' repeated:indent*4+[unmangled length]+1], explodingGarbageCans[i]];
            }
            
            return [explodingGarbageCans componentsJoinedByString:@"\n"];
        }];
    
        NSArray * signatures = @[helpSig, outFileSig];
        
        FSArgumentPackage * arguments = [[NSProcessInfo processInfo] fsargs_parseArgumentsWithSignatures:signatures];

        if (YES==[arguments booleanValueForSignature:helpSig]) {
            struct winsize ws;
            ioctl(0, TIOCGWINSZ, &ws);
            
            printf("Example program with help flag!\n\n");

            [signatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                printf("%s\n", [[obj descriptionForHelpWithIndent:1 terminalWidth:(NSUInteger)ws.ws_col] UTF8String]);
            }];
        }

    }
    return 0;
}
