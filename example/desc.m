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
        NSArray * signatures = [[NSArray alloc] initWithObjects:
                                [FSArgumentSignature argumentSignatureAsFlag:@"h" longNames:@"help" multipleAllowed:NO],
                                [FSArgumentSignature argumentSignatureAsNamedArgument:@"o" longNames:@"out-file" required:NO multipleAllowed:YES],
                                nil];
    
        NSError * err;
        FSArgumentPackage * arguments = [FSArgumentParser parseArguments:[[NSProcessInfo processInfo] arguments]
                                                          withSignatures:signatures
                                                                   error:&err];
        if (err) { NSLog(@"%@", err); return -1; }
        
        if ([[arguments.flags objectForKey:[signatures objectAtIndex:0]] boolValue]==YES) {
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
