//
//  FSArgumentSignature.m
//  fs-dataman
//
//  Created by Christopher Miller on 2/22/12.
//  Copyright (c) 2012 Christopher Miller. All rights reserved.
//

#import "FSArgumentSignature.h"

@implementation FSArgumentSignature
@synthesize names=_names;
@synthesize flag=_flag;
@synthesize required=_required;
@synthesize multipleAllowed=_multipleAllowed;
+ (id)argumentSignatureWithNames:(NSArray *)names flag:(BOOL)flag required:(BOOL)required multipleAllowed:(BOOL)multipleAllowed
{
    FSArgumentSignature * siggy = [[[self class] alloc] init];
    siggy.names = names;
    siggy.flag = flag;
    siggy.required = required;
    siggy.multipleAllowed = multipleAllowed;
    return siggy;
}
@end
