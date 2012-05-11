//
//  FSArgumentSignature_Internal.h
//  ArgumentParser
//
//  Created by Christopher Miller on 5/11/12.
//  Copyright (c) 2012 FSDEV. All rights reserved.
//

#import "FSArgumentSignature.h"

#import <CommonCrypto/CommonDigest.h>

@interface FSArgumentSignature ()



- (void)internal_updateMD5:(CC_MD5_CTX *)md5;

@end
