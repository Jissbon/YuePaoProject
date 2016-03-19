//
//  NSString+md5.m
//  酷跑
//
//  Created by tarena on 16/1/4.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "NSString+md5.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (md5)
- (NSString*) md5Str
{
    const char *myPasswd = [self UTF8String];
    // 1Byte = 8bit  4bit可以表示
    //   一个16进制数
    unsigned char mdc[16];
    CC_MD5(myPasswd, (CC_LONG)strlen(myPasswd), mdc);
    NSMutableString *md5String =
        [NSMutableString string];
    for (int i = 0; i < 16; i++) {
        [md5String appendFormat:@"%02x",mdc[i]];
    }
    return  md5String;
}

- (NSString*) md5StrXor
{
    const char *myPasswd = [self UTF8String];
    // 1Byte = 8bit  4bit可以表示
    //   一个16进制数
    unsigned char mdc[16];
    CC_MD5(myPasswd, (CC_LONG)strlen(myPasswd), mdc);
    NSMutableString *md5String =
    [NSMutableString string];
    [md5String appendFormat:@"%02x",mdc[0]];
    for (int i = 1; i < 16; i++) {
        [md5String appendFormat:@"%02x",mdc[i]^mdc[0]];
    }
    return  md5String;
}
@end






