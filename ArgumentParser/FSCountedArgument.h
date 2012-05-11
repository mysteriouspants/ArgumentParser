//
//  FSCountedArgument.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "FSArgumentSignature.h"
#import "FSExplicitArgument.h"

/** Counted or boolean argument signature. */
@interface FSCountedArgument : FSArgumentSignature < FSExplicitArgument >

@property (strong) NSCharacterSet * switchAliases;
@property (strong) NSSet * longAliases;

@property (assign) bool shouldAllowMultipleInvocations;

+ (id)countedArgumentWithSwitches:(id)switchAliases longAliases:(id)longAliases allowMultipleInvocations:(bool)shouldAllowMultipleInvocations;
- (id)initWithSwitches:(id)switchAliases longAliases:(id)longAliases allowMultipleInvocations:(bool)shouldAllowMultipleInvocations;

@end
