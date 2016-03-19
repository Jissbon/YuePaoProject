//
//  KRUserInfo.h
//  酷跑
//
//  Created by tarena on 15/12/31.
//  Copyright © 2015年 tarena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
@interface KRUserInfo : NSObject
singleton_interface(KRUserInfo)
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *userPasswd;
/** 注册的用户名和密码 */
@property (nonatomic,copy) NSString *userRegisterName;
@property (nonatomic,copy) NSString *userRegisterPasswd;
/** 为了区分 登录还是注册 */
@property (nonatomic,assign,getter=isRegisterType) BOOL registerType;

/**获取当前登陆对象对应的jidStr*/
@property (nonatomic,copy) NSString *jidStr;

/**区分是不是新浪登陆*/
@property (nonatomic,assign,getter=isSinaLogin) BOOL sinaLogion;



@end






