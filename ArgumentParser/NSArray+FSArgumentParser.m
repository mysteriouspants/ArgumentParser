//
//  NSArray+FSArgumentParser.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/15/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "NSArray+FSArgumentParser.h"
#import "NSArray+FSArgumentsNormalizer.h"
#import "FSMutableAttributedArray.h"

@implementation NSArray (FSArgumentParser)

- (id)fsargs_parseArgumentsWithSignatures:(id)signatures
{
    FSMutableAttributedArray * arguments = [self fsargs_normalize];
    
    NSLog(@"%@", arguments);
    
    return nil;
}

@end
