//
//  KRXMPPTool.h
//  酷跑
//
//  Created by tarena on 15/12/31.
//  Copyright © 2015年 tarena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"
#import "XMPPMessageArchiving.h"
#import "XMPPMessageArchivingCoreDataStorage.h"

/** 定义枚举 代表登录的状态 和 注册的状态 */
typedef enum
{
   KRXMPPResultTypeLoginSuccess,
   KRXMPPResultTypeLoginFaild,
   KRXMPPResultTypeNetError,
   KRXMPPResultTypeRegisterSuccess,
   KRXMPPResultTypeRegisterFaild
}KRXMPPResultType;
/** 定义BLOCK */
typedef void(^KRResultBlock)(KRXMPPResultType type);
/** 定义一个实现登录的协议
@protocol KRLoginProtocol <NSObject>
- (void) krLoginSuccess;
- (void) krLoginFailed;
- (void) krNetError;
@end
 */
@interface KRXMPPTool : NSObject

//@property(nonatomic,weak) id<KRLoginProtocol> delegate;

singleton_interface(KRXMPPTool)//单例的宏

/** 负责和服务器进行交互的主要对象 */
@property(nonatomic,strong) XMPPStream
    *xmppStream;

/**增加电子名片模块 和 头像模块*/
@property (nonatomic,strong) XMPPvCardTempModule *xmppvCard;
@property (nonatomic,strong) XMPPvCardAvatarModule *xmppvCardAvar;

/**管理电子名片数据的对象*/
@property (nonatomic,strong) XMPPvCardCoreDataStorage *xmppvCordStore;


/**增加好友列表模块 和 对应的存储模块*/
@property (nonatomic,strong) XMPPRoster *xmppRoster;
@property (nonatomic,strong) XMPPRosterCoreDataStorage *xmppRosterStorage;


/**增加消息模块和对应的存储*/
@property (nonatomic,strong) XMPPMessageArchiving *xmppMsagArch;
@property (nonatomic,strong) XMPPMessageArchivingCoreDataStorage *xmppMsagArchStore;



/** 设置XMPP流 */
- (void) setXmpp;
/** 连接到服务器 */
- (void) connectHost;
/** 连接成功 发送密码 */
- (void) sendPasswdToHost;
/** 授权成功之后 发送在线消息 */
- (void) sendOnLine;
/** 用户登录调用这个方法即可 */
- (void) userLogin:(KRResultBlock) block;
/** 用户注册调用的方法 要得到注册的状态
    传入一个block 即可 */
- (void) userRegister:(KRResultBlock) block;

/**增加好友方法*/
-(void) rosterAddfrendWithName:(NSString *)name;

@end






