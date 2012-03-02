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
        FSArgumentSignature
        * asyncSig = [FSArgumentSignature argumentSignatureAsFlag:@"a" longNames:@"async"
                                                  multipleAllowed:NO description:@"-a --async           Do not wait for the user to close the file in Chocolat. [default if output is ignored]"],
        * waitSig = [FSArgumentSignature argumentSignatureAsFlag:@"w" longNames:@"wait"
                                                 multipleAllowed:NO description:@"-w --wait            Wait for file to be closed by Chocolat. [default if output is piped]"],
        * noReactivationSig = [FSArgumentSignature argumentSignatureAsFlag:@"n" longNames:@"no-reactivation"
                                                           multipleAllowed:NO description:@"-n --no-reactivation After editing with -w, do not reactivate the calling app."],
        * helpSig = [FSArgumentSignature argumentSignatureAsFlag:@"h" longNames:@"help"
                                                 multipleAllowed:NO description:@"-h --help            Show this information."],
        * versionSig = [FSArgumentSignature argumentSignatureAsFlag:@"v" longNames:@"version"
                                                    multipleAllowed:NO description:@"-v --version         Print version information."];
        NSArray * signatures = [NSArray arrayWithObjects:asyncSig, waitSig, noReactivationSig, helpSig, versionSig, nil];
        NSError * err;
        FSArgumentPackage * arguments = [FSArgumentParser parseArguments:[[NSProcessInfo processInfo] arguments] withSignatures:signatures error:&err];
        if (arguments && [arguments boolValueOfFlag:helpSig]) {
            PrintLn(@"Usage: choc [-awdnhv] [file ...]");
            PrintLn(@"Options:");
            [signatures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PrintLn(@"%@", [obj descriptionWithLocale:nil indent:1]);
            }];
            PrintLn(@"\nIf multiple files are given, -w will be ignored.\n");
            PrintLn(@"By default choc will not wait for the file to be closed except when the output is not to the console:");
            PrintLn(@"ls *.tex|choc|sh	-w implied");
            PrintLn(@"choc foo.h > bar.h	-w implied\n");
        } else if (arguments && [arguments boolValueOfFlag:versionSig]) {
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
            __unused NSArray * filesToOpen = arguments.unnamedArguments;
            __unused BOOL doAsync = [arguments boolValueOfFlag:asyncSig];
            __unused BOOL doWait = [arguments boolValueOfFlag:waitSig];
            __unused BOOL doNotReactivate = [arguments boolValueOfFlag:noReactivationSig];
            
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
