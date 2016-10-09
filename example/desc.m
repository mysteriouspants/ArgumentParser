//
//  desc.m
//  ArgumentParser
//
//  Created by Christopher R. Miller on 2/27/12.
//  Copyright (c) 2012, 2013, 2016 Christopher R. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XPMArguments.h"

#include <stdio.h>
#include <sys/ioctl.h>

int main (int argc, const char *argv[]) {
    @autoreleasepool {
			XPMArgumentSignature
				*helpSig = [XPMArgumentSignature argumentSignatureWithFormat:@"[-h --help]"],
				*outFileSig = [XPMArgumentSignature argumentSignatureWithFormat:@"[-o --out-file]={1,}"];
			NSArray *signatures = @[helpSig, outFileSig];
	
			XPMArgumentPackage *arguments = [[NSProcessInfo processInfo] xpmargs_parseArgumentsWithSignatures:signatures];
			
			if ([arguments booleanValueForSignature:helpSig]) {
				printf("Example program with help flag!\n\n");
				
				[signatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
						struct winsize ws;
						ioctl(0, TIOCGWINSZ, &ws);
						
						printf("%s\n", [[obj descriptionForHelpWithIndent:1 terminalWidth:(NSUInteger)ws.ws_col] UTF8String]);
					}];
			} else {
				printf("%s\n", [[signatures description] UTF8String]);
			}
	
    }
    return 0;
}
