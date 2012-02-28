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
        NSUInteger help=0,infile=1,outfile=2;
        NSArray * signatures = [[NSArray alloc] initWithObjects:
                                [FSArgumentSignature argumentSignatureAsFlag:@"h" longNames:@"help" multipleAllowed:NO],
                                [FSArgumentSignature argumentSignatureAsNamedArgument:@"i" longNames:@"if" required:YES multipleAllowed:NO],
                                [FSArgumentSignature argumentSignatureAsNamedArgument:@"o" longNames:@"of" required:YES multipleAllowed:NO],
                                nil];

        NSError * err;
        FSArgumentPackage * arguments = [FSArgumentParser parseArguments:[[NSProcessInfo processInfo] arguments]
                                                          withSignatures:signatures
                                                                   error:&err];

        if ([[arguments.flags objectForKey:[signatures objectAtIndex:help]] boolValue]==YES) {
            printf("Example program with help flag!\n\n");

            [signatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                printf("%s\n", [[obj descriptionWithLocale:nil indent:1] UTF8String]);
            }];
            
            if (err) printf("\nOh, PS, there was an error: %s\n", [[[err userInfo] description] UTF8String]);
        } else {
            printf("Example program:\n");
            printf("  Input File: %s\n", [[arguments.namedArguments objectForKey:[signatures objectAtIndex:infile]] UTF8String]);
            printf("  OutputFile: %s\n", [[arguments.namedArguments objectForKey:[signatures objectAtIndex:outfile]] UTF8String]);
        }

    }
    return 0;
}
