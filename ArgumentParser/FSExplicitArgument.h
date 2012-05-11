//
//  FSExplicitArgument.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSExplicitArgument <NSObject>

@property (strong) NSCharacterSet * switchAliases;
@property (strong) NSSet * longAliases;

@property (assign) bool shouldAllowMultipleInvocations;

/** Helper for generating documentation. */
- (NSArray *)switchAliasesAsArray;
/** Helper for generating documentation. */
- (NSString *)switchAliasesAsString;

@end
