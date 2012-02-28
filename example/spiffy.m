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

/*
> rake spiffy
... build stuffs you don't care about
> ./bin/spiffy
2012-02-28 09:35:38.211 spiffy[2785:707] Error Domain=net.fsdev.argument_parser Code=3 "The operation couldn’t be completed. (net.fsdev.argument_parser error 3.)" UserInfo=0x10bb1cf60 {missingTheseSignatures=<CFBasicHash 0x10bb1ce50 [0x7fff776f5fc0]>{type = mutable set, count = 2,
entries =>
    1 : Argument responding to -i and --if; required:YES multipleAllowed:NO
    2 : Argument responding to -o and --of; required:YES multipleAllowed:NO
}
}
> ./bin/spiffy --if file0 --of file1
 */

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
        if (err) { NSLog(@"%@", err); return -1; }

        if ([[arguments.flags objectForKey:[signatures objectAtIndex:help]] boolValue]==YES) {
            printf("Example program with help flag!\n\n");

            [signatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                printf("%s\n", [[obj descriptionWithLocale:nil indent:1] UTF8String]);
            }];
        } else {
            printf("Example program:\n");
            
            printf("  Input File: %s\n", [[arguments.namedArguments objectForKey:[signatures objectAtIndex:infile]] UTF8String]);
            printf("  OutputFile: %s\n", [[arguments.namedArguments objectForKey:[signatures objectAtIndex:outfile]] UTF8String]);
        }

    }
    return 0;
}
