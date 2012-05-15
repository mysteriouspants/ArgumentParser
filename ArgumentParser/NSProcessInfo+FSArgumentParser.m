//
//  NSProcessInfo+FSArgumentParser.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/15/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "NSProcessInfo+FSArgumentParser.h"
#import "NSArray+FSArgumentParser.h"

@implementation NSProcessInfo (FSArgumentParser)

- (id)fsargs_parseArgumentsWithSignatures:(id)signatures
{
    return [[self arguments] fsargs_parseArgumentsWithSignatures:signatures];
}

@end
