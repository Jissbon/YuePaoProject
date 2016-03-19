//
//  KRUserInfo.m
//  酷跑
//
//  Created by tarena on 15/12/31.
//  Copyright © 2015年 tarena. All rights reserved.
//

#import "KRUserInfo.h"

@implementation KRUserInfo
singleton_implementation(KRUserInfo)
-(NSString *)jidStr
{
     return [NSString stringWithFormat:@"%@@%@",self.userName,KRXMPPDOMAIN];
}
@end








