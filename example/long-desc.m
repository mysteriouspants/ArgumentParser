//
//  long-desc.m
//  ArgumentParser
//
//  Created by Christopher R. Miller on 2/28/12.
//  Copyright (c) 2012, 2013, 2016 Christopher R. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XPMArguments.h"
#import "XPMArguments_Coalescer_Internal.h" // for __xpmargs_expandAllSwitches
#import "NSString+FilledString.h"

#include <stdio.h>
#include <sys/ioctl.h>

int main (int argc, const char * argv[]) {
	@autoreleasepool {
		XPMArgumentSignature
			* helpSig = [XPMArgumentSignature argumentSignatureWithFormat:@"[-h --help]"],
			* outFileSig = [XPMArgumentSignature argumentSignatureWithFormat:@"[-o --out-file]="];
		
		[outFileSig setDescriptionHelper:^NSString *(XPMArgumentSignature * signature, NSUInteger indent, NSUInteger width) {
			NSMutableArray * invocations = [NSMutableArray arrayWithCapacity:[signature.switches count] + [signature.aliases count]];
			[invocations addObjectsFromArray:xpmargs_expandAllSwitches(signature.switches)];
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
			
			explodingGarbageCans[0] = [NSString stringWithFormat:@"%@%@ %@", [NSString xpm_stringByFillingWithCharacter:' ' repeated:indent*4], unmangled, explodingGarbageCans[0]];
			
			for (NSUInteger i = 1; i < [explodingGarbageCans count]; ++i) {
				explodingGarbageCans[i] = [NSString stringWithFormat:@"%@%@", [NSString xpm_stringByFillingWithCharacter:' ' repeated:indent*4+[unmangled length]+1], explodingGarbageCans[i]];
			}
			
			return [explodingGarbageCans componentsJoinedByString:@"\n"];
		}];

		NSArray * signatures = @[helpSig, outFileSig];
		
		XPMArgumentPackage * arguments = [[NSProcessInfo processInfo] xpmargs_parseArgumentsWithSignatures:signatures];

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
