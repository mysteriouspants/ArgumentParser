//
//  FSArgumentParser.h
//  FSArgumentParser
//
//  Created by Christopher Miller on 2/23/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSArgumentParser : NSObject

- (id)initWithArguments:(NSArray *)arguments signatures:(id)signatures;
- (id)parse;

@end
