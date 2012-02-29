//
//  desc.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/27/12.
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
            * outFileSig = [FSArgumentSignature argumentSignatureAsNamedArgument:@"o" longNames:@"out-file" required:NO multipleAllowed:YES];
        NSArray * signatures = [[NSArray alloc] initWithObjects:helpSig, outFileSig, nil];
    
        NSError * err;
        FSArgumentPackage * arguments = [FSArgumentParser parseArguments:[[NSProcessInfo processInfo] arguments]
                                                          withSignatures:signatures
                                                                   error:&err];
        if (err) { NSLog(@"%@", err); return -1; }
        
        if ([arguments boolValueOfFlag:helpSig]==YES) {
            printf("Example program with help flag!\n\n");
            
            [signatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                printf("%s\n", [[obj descriptionWithLocale:nil indent:1] UTF8String]);
            }];
        } else {
            printf("%s\n", [[arguments.flags description] UTF8String]);
        }
    
    }
    return 0;
}
