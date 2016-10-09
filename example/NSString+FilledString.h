//
//  NSString+FilledString.h
//  ArgumentParser
//
//  Created by Christopher R. Miller on 12/31/13.
//  Copyright (c) 2013, 2016 Christopher R. Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

// Helper when working with indents. Stolen from NSContainers+PrettyPrint
// https://github.com/NSError/NSContainers-PrettyPrint I can do that because of reasons.
@interface NSString (FilledString)

+ (NSString *)xpm_stringByFillingWithCharacter:(char)character repeated:(NSUInteger)times;
+ (NSString *)xpm_stringByFillingWithString:(NSString *)string repeated:(NSUInteger)times;

@end
