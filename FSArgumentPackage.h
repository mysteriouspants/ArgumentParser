//
//  FSArgumentPackage.h
//  fs-dataman
//
//  Created by Christopher Miller on 2/23/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

//! dumb return structure which bundles up all the relevant information
@interface FSArgumentPackage : NSObject
@property (readwrite, strong) NSDictionary * flags;
@property (readwrite, strong) NSDictionary * namedArguments;
@property (readwrite, strong) NSArray * unnamedArguments;
@end
