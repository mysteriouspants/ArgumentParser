//
//  FSCommandArgument.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "FSArgumentSignature.h"

/** A command is a good way of elegantly delineating between program behaviors, such as foo command1 args. */
@interface FSCommandArgument : FSArgumentSignature

/** Any of these will trigger this command argument. This is found in the original arguments as a normal string with no leading dashes. */
@property (strong) NSSet * aliases;

+ (id)commandArgumentWithAliases:(id)aliases;
- (id)initWithAliases:(id)aliases;

@end
