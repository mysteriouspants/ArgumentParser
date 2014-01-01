//
//  desc.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/27/12.
//  Copyright (c) 2012, 2013 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSArguments.h"

#include <stdio.h>

int main (int argc, const char * argv[]) {
    @autoreleasepool {
        FSArgumentSignature
            * helpSig = [FSArgumentSignature argumentSignatureWithFormat:@"[-h --help]"],
            * outFileSig = [FSArgumentSignature argumentSignatureWithFormat:@"[-o --out-file]={1,}"];
        NSArray * signatures = @[helpSig, outFileSig];
    
        FSArgumentPackage * arguments = [[NSProcessInfo processInfo] fsargs_parseArgumentsWithSignatures:signatures];
        
        if (YES==[arguments booleanValueForSignature:helpSig]) {
            printf("Example program with help flag!\n\n");
            
            [signatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                printf("%s\n", [[obj descriptionWithLocale:nil indent:1] UTF8String]);
            }];
        } else {
            printf("%s\n", [[signatures description] UTF8String]);
        }
    
    }
    return 0;
}
