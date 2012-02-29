//
//  spiffy.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/28/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSArgumentSignature.h"
#import "FSArgumentParser.h"
#import "FSArgumentPackage.h"

#include <stdio.h>

int main (int argc, const char * argv[]) {
    @autoreleasepool {
        FSArgumentSignature
            * helpSig = [FSArgumentSignature argumentSignatureAsFlag:@"h" longNames:@"help" multipleAllowed:NO],
            * ifSig = [FSArgumentSignature argumentSignatureAsNamedArgument:@"i" longNames:@"if" required:YES multipleAllowed:NO],
            * ofSig = [FSArgumentSignature argumentSignatureAsNamedArgument:@"o" longNames:@"of" required:YES multipleAllowed:NO];
        NSArray * signatures = [[NSArray alloc] initWithObjects:helpSig, ifSig, ofSig, nil];

        NSError * err;
        FSArgumentPackage * arguments = [FSArgumentParser parseArguments:[[NSProcessInfo processInfo] arguments]
                                                          withSignatures:signatures
                                                                   error:&err];

        if (!err) {
            printf("Example program:\n");
            printf("  Input File: %s\n", [[arguments objectForNamedArgument:ifSig] UTF8String]);
            printf("  OutputFile: %s\n", [[arguments objectForNamedArgument:ofSig] UTF8String]);
        } else {
            printf("Example program with help flag!\n\n");

            [signatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                printf("%s\n", [[obj descriptionWithLocale:nil indent:1] UTF8String]);
            }];
            
            if (err&&[arguments boolValueOfFlag:helpSig]==NO) printf("\nOh, PS, there was an error: %s\n", [[[err userInfo] description] UTF8String]);
        }

    }
    return 0;
}
