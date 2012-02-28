//
//  chocolat-app.m
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/28/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSArgumentSignature.h"
#import "FSArgumentParser.h"
#import "FSArgumentPackage.h"

#include <stdio.h>

void Print  (NSString* format, ...)        NS_FORMAT_FUNCTION(1,2);
void PrintLn(NSString* format, ...)        NS_FORMAT_FUNCTION(1,2);
void PrintLnThenDie(NSString* format, ...) NS_FORMAT_FUNCTION(1,2);

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        enum signatureIndexes {
            async,
            wait,
            no_reativation,
            help,
            version
        };
        NSArray * signatures = [NSArray arrayWithObjects:
                                [FSArgumentSignature argumentSignatureAsFlag:@"a" longNames:@"async"
                                                             multipleAllowed:NO description:@"-a --async           Do not wait for the user to close the file in Chocolat. [default if output is ignored]"],
                                [FSArgumentSignature argumentSignatureAsFlag:@"w" longNames:@"wait"
                                                             multipleAllowed:NO description:@"-w --wait            Wait for file to be closed by Chocolat. [default if output is piped]"],
                                [FSArgumentSignature argumentSignatureAsFlag:@"n" longNames:@"no-reactivation"
                                                             multipleAllowed:NO description:@"-n --no-reactivation After editing with -w, do not reactivate the calling app."],
                                [FSArgumentSignature argumentSignatureAsFlag:@"h" longNames:@"help"
                                                             multipleAllowed:NO description:@"-h --help            Show this information."],
                                [FSArgumentSignature argumentSignatureAsFlag:@"v" longNames:@"version"
                                                             multipleAllowed:NO description:@"-v --version         Print version information."],
                                nil];
        NSError * err;
        FSArgumentPackage * arguments = [FSArgumentParser parseArguments:[[NSProcessInfo processInfo] arguments] withSignatures:signatures error:&err];
        if (arguments && [[arguments.flags objectForKey:
                           [signatures objectAtIndex:help]] boolValue]) {
            PrintLn(@"Usage: choc [-awdnhv] [file ...]");
            PrintLn(@"Options:");
            [signatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PrintLn(@"%@", [obj descriptionWithLocale:nil indent:1]);
            }];
            PrintLn(@"\nIf multiple files are given, -w will be ignored.\n");
            PrintLn(@"By default choc will not wait for the file to be closed except when the output is not to the console:");
            PrintLn(@"ls *.tex|choc|sh	-w implied");
            PrintLn(@"choc foo.h > bar.h	-w implied\n");
        } else if (arguments && [[arguments.flags objectForKey:[signatures objectAtIndex:version]] boolValue]) {
            PrintLn(@"Example app version nil");
        } else if (err) {
            // handle the error
            switch (err.code) {
                case TooManySignatures:
                    PrintLn(@"Too many signatures for argument: %@", [[err.userInfo objectForKey:FSAPErrorDictKeys.TooManyOfThisSignature] longNames]);
                    break;
                    
                default:
                    PrintLn(@"%@", err);
                    break;
            }
            exit(-1);
        } else {
            // handle the other args
            NSArray * filesToOpen = arguments.unnamedArguments;
            BOOL doAsync = [[arguments.flags objectForKey:[signatures objectAtIndex:async]] boolValue];
            BOOL doWait = [[arguments.flags objectForKey:[signatures objectAtIndex:wait]] boolValue];
            BOOL doNotReactivate = [[arguments.flags objectForKey:[signatures objectAtIndex:no_reativation]] boolValue];
            
            // do other things related to the app
        }
    }
    return 0;
}

void Print  (NSString* format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    NSString* s0 = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    printf("%s", [s0 UTF8String]);
}
                       
void PrintLn(NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    NSString* s0 = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    printf("%s\n", [s0 UTF8String]);
}
                       
void PrintLnThenDie(NSString* format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    NSString* s0 = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    printf("%s\n", [s0 UTF8String]);
    exit(-1);
}
