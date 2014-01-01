//
//  NSString+FilledString.h
//  ArgumentParser
//
//  Created by Chris Miller on 12/31/13.
//  Copyright (c) 2013 FSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

// Helper when working with indents. Stolen from NSContainers+PrettyPrint
// https://github.com/NSError/NSContainers-PrettyPrint I can do that because of reasons.
@interface NSString (FilledString)
+ (NSString *)fs_stringByFillingWithCharacter:(char)character repeated:(NSUInteger)times;
+ (NSString *)fs_stringByFillingWithString:(NSString *)string repeated:(NSUInteger)times;
@end
