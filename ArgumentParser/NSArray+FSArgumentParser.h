//
//  NSArray+FSArgumentParser.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/15/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (FSArgumentParser)

- (id)fsargs_parseArgumentsWithSignatures:(id)signatures;

@end
