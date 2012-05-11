//
//  FSArguments_Coalescer_Internal.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

NSCharacterSet * __fsargs_coalesceToCharacterSet(id);
NSArray * __fsargs_coalesceToArray(id);
NSSet * __fsargs_coalesceToSet(id);
NSArray * __charactersFromCharacterSet(NSCharacterSet *);
