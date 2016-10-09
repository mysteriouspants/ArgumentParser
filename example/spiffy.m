//
//  spiffy.m
//  ArgumentParser
//
//  Created by Christopher R. Miller on 2/28/12.
//  Copyright (c) 2012, 2013, 2016 Christopher R. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XPMArguments.h"

#include <stdio.h>
#include <sys/ioctl.h>

int main (int argc, const char * argv[]) {
	@autoreleasepool {
		XPMArgumentSignature
			* helpSig = [XPMArgumentSignature argumentSignatureWithFormat:@"[-h --help]"],
			* ifSig = [XPMArgumentSignature argumentSignatureWithFormat:@"[-i --if]="],
			* ofSig = [XPMArgumentSignature argumentSignatureWithFormat:@"[-o --of]="];
		NSArray * signatures = @[helpSig, ifSig, ofSig];

		XPMArgumentPackage * arguments = [[NSProcessInfo processInfo] xpmargs_parseArgumentsWithSignatures:signatures];

		bool print_help = false;
		
		if ([arguments booleanValueForSignature:helpSig]) {
			print_help = true;
		} else {
			printf("  Input File: %s\n", [[[arguments firstObjectForSignature:ifSig] description] UTF8String]);
			printf("  OutputFile: %s\n", [[[arguments firstObjectForSignature:ofSig] description] UTF8String]);
		}
		
		if (print_help) {
			struct winsize ws;
			ioctl(0, TIOCGWINSZ, &ws);
			
			printf("Example program:\n");
			printf("  %s Input file\n", [[ifSig descriptionForHelpWithIndent:2 terminalWidth:(NSUInteger)ws.ws_col] UTF8String]);
			printf("  %s Output file\n", [[ofSig descriptionForHelpWithIndent:2 terminalWidth:(NSUInteger)ws.ws_col] UTF8String]);
		}

	}
	return 0;
}
