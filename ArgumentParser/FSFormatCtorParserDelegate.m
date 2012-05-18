//
//  FSFormatCtorParserDelegate.m
//  ArgumentParser
//
//  Created by Christopher Miller on 5/18/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "FSFormatCtorParserDelegate.h"

#import "FSSwitchToken.h"
#import "FSAliasToken.h"

@implementation FSFormatCtorParserDelegate

- (id)parser:(CPParser *)parser didProduceSyntaxTree:(CPSyntaxTree *)syntaxTree
{
    NSLog(@"syntaxTree: %@", syntaxTree);
    
    if ([[syntaxTree children] count] == 1) {
        if ([[[syntaxTree children] objectAtIndex:0] isKindOfClass:[FSSwitchToken class]]
            || [[[syntaxTree children] objectAtIndex:0] isKindOfClass:[FSAliasToken class]]) {
            return [[syntaxTree children] objectAtIndex:0];
        }
    }
    
    return syntaxTree;
}

@end
