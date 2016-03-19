//
//  KRXMPPTool.m
//  酷跑
//
//  Created by tarena on 15/12/31.
//  Copyright © 2015年 tarena. All rights reserved.
//

#import "KRXMPPTool.h"
#import "KRUserInfo.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

@interface   KRXMPPTool()<XMPPStreamDelegate,XMPPRosterDelegate>
{
    KRResultBlock _resultBlock;
}
@property (nonatomic,strong) XMPPJID *friendJID;

@end

@implementation KRXMPPTool
singleton_implementation(KRXMPPTool)
/** 设置XMPP流 */
- (void) setXmpp
{
    self.xmppStream = [[XMPPStream alloc]init];
    /** 设置代理 */
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
     //开启底层发送数据的日志
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    /**给头像电子名片模块和头像模块和对应的存储模块赋值*/
    self.xmppvCordStore = [XMPPvCardCoreDataStorage sharedInstance];
    
    self.xmppvCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.xmppvCordStore];
    
    self.xmppvCardAvar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCard];
    
    /**给好友列表 和 对应的存储对象赋值*/
    self.xmppRosterStorage = [XMPPRosterCoreDataStorage sharedInstance];
    self.xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:self.xmppRosterStorage];
    
    /**给消息模块和对应的存储模块赋值*/
    self.xmppMsagArchStore = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    self.xmppMsagArch = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:self.xmppMsagArchStore];
    
    /**激活电子名片模块和头像模块*/
    [self.xmppvCard activate:self.xmppStream];
    [self.xmppvCardAvar activate:self.xmppStream];
    
    /**激活好友列表模块*/
    [self.xmppRoster activate:self.xmppStream];
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
     /**激活消息模块*/
    [self.xmppMsagArch activate:self.xmppStream];
    
}
/** 连接到服务器 */
- (void) connectHost
{
    if (!self.xmppStream) {
        [self setXmpp];
    }
    /** 给xmppStream 做一些属性的赋值 */
    self.xmppStream.hostName = KRXMPPHOSTNAME;
    self.xmppStream.hostPort = KRXMPPPORT;
    /** 构建一个jid 根据登录名还是注册名 */
    NSString *uname = nil;
    if ([KRUserInfo sharedKRUserInfo].isRegisterType) {
        uname = [KRUserInfo sharedKRUserInfo].userRegisterName;
    }else{
        uname = [KRUserInfo sharedKRUserInfo].userName;
    }
    XMPPJID  *myJid = [XMPPJID jidWithUser:uname domain:KRXMPPDOMAIN resource:@"iphone"];
    self.xmppStream.myJID = myJid;
    /** 连接服务器 */
    NSError  *error = nil;
    [self.xmppStream  connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        MYLog(@"%@",error);
    }
}

#pragma mark - 连接服务器成功还是失败?
/** 连接服务器成功 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    /** 发送密码 */
    [self sendPasswdToHost];
}

/** 连接服务器失败 */
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    if (error && _resultBlock) {
        _resultBlock(KRXMPPResultTypeNetError);
        MYLog(@"%@",error);
        /** 授权成功就调用代理的成功方法
         if([self.delegate respondsToSelector:@selector(krNetError)]){
         [self.delegate krNetError];
         }*/
    }
}
/** 连接成功 发送密码 */
- (void) sendPasswdToHost
{
    NSString *pwd = nil;
    NSError  *error = nil;
    if ([KRUserInfo sharedKRUserInfo].isRegisterType) {
        pwd = [KRUserInfo sharedKRUserInfo].userRegisterPasswd;
        /** 用密码进行注册 */
        [self.xmppStream registerWithPassword:pwd error:&error];
    }else{
        pwd = [KRUserInfo sharedKRUserInfo].userPasswd;
        /** 用密码进行授权 */
        [self.xmppStream authenticateWithPassword:pwd error:&error];
    }
    if (error) {
        MYLog(@"%@",error);
    }
}

#pragma mark - 登陆授权成功或失败
/** 授权成功之后 发送在线消息 */
- (void) sendOnLine
{
    /** 默认代表在线 */
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmppStream sendElement:presence];
}

/** 授权成功的方法 */
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    _resultBlock(KRXMPPResultTypeLoginSuccess);
    /** 授权成功就调用代理的成功方法
     if([self.delegate respondsToSelector:@selector(krLoginSuccess)]){
     [self.delegate krLoginSuccess];
     } */
    /** 发送在线消息 */
    [self sendOnLine];
}





#pragma mark XMPPStreamDelegate
/** 注册成功 还是失败 */
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    if (_resultBlock) {
         _resultBlock(KRXMPPResultTypeRegisterSuccess);
    }
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    if (_resultBlock && error) {
       _resultBlock(KRXMPPResultTypeRegisterFaild);
    }
}



/** 授权失败的方法 */
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    MYLog(@"%@",error);
    if (error && _resultBlock) {
        _resultBlock(KRXMPPResultTypeLoginFaild);
    }
    /** 授权成功就调用代理的成功方法
    if([self.delegate respondsToSelector:@selector(krLoginFailed)]){
        [self.delegate krLoginFailed];
    } */
}

- (void) userLogin:(KRResultBlock) block
{
    _resultBlock = block;
    /** 无论之前有没有登录 都断开一次 */
    [self.xmppStream disconnect];
    [self connectHost];
}
/** 用户注册调用的方法 要得到注册的状态
 传入一个block 即可 */
- (void) userRegister:(KRResultBlock) block
{
    _resultBlock = block;
    /** 无论之前 xmppStream 有没有连接
        都直接断开上一次连接 */
    [self.xmppStream disconnect];
    [self connectHost];
}



/**添加好友*/
//--------------------------------------------------
//添加好友
-(void)XMPPaddFriendSubscribe:(NSString *)name{
    NSString *str = [NSString stringWithFormat:@"%@@%@",name,KRXMPPDOMAIN];
    MYLog(@"%@",str);
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",name,KRXMPPDOMAIN]];
    [self.xmppRoster subscribePresenceToUser:jid];
    //    [self connectHost];
    
}
//处理加好友回调 加好友
-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    //获取好友状态 online  offline
    //    NSString *presencType = [NSString stringWithFormat:@"%@",[presence type]];
    MYLog(@"测试的 ");
    //请求用户
    NSString *presenceFromUser = [NSString stringWithFormat:@"%@",[[presence from] user]];
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",presenceFromUser,KRXMPPDOMAIN];
    
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    self.friendJID = jid;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@想添加你为好友",jidStr] message:@"是否同意" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.friendJID andAddToRoster:NO];
    }];
    [alertController addAction:action];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"同意并添加对方为好友" style:0 handler:^(UIAlertAction * _Nonnull action) {
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.friendJID andAddToRoster:YES];
    }];
    [alertController addAction:action2];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"不同意" style:1 handler:^(UIAlertAction * _Nonnull action) {
        
        [self.xmppRoster rejectPresenceSubscriptionRequestFrom:self.friendJID];
    }];
    [alertController addAction:action3];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    //    [self.xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    MYLog(@"%@",presence);
}



-(void)rosterAddfrendWithName:(NSString *)name{
    [self XMPPaddFriendSubscribe:name];
    
}
//------------------------------------------------------------



@end






