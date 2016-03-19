//
//  KRMyProfileViewController.m
//  酷跑
//
//  Created by apple on 16/3/2.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "KRMyProfileViewController.h"
#import "XMPPvCardTemp.h"
#import "KRXMPPTool.h"
#import "KRUserInfo.h"
#import "KREditMyProfileViewController.h"
#import "UIImageView+Layout.h"



@interface KRMyProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@end

@implementation KRMyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.headerImageView setRoundLayer];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    XMPPvCardTemp *vCardTemp = [KRXMPPTool sharedKRXMPPTool].xmppvCard.myvCardTemp;
    if (vCardTemp.photo) {
        self.headerImageView.image = [UIImage imageWithData:vCardTemp.photo];
    }else{
        self.headerImageView.image = [UIImage imageNamed:@"QQ"];
    }
    self.userNameLabel.text = [KRUserInfo sharedKRUserInfo].userName;
    self.nickNameLabel.text = vCardTemp.nickname;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[KREditMyProfileViewController class]]) {
        KREditMyProfileViewController *editvc = (KREditMyProfileViewController *)destVc;//强制转型id类型
        editvc.myProfile = [KRXMPPTool sharedKRXMPPTool].xmppvCard.myvCardTemp;
    }
}

- (IBAction)backBtn:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**我的运动记录*/
- (IBAction)mySports:(UIButton *)sender {
    MYLog(@"我的运动记录");
}

/**我的消息*/
- (IBAction)myMostRecntMessages:(UIButton *)sender {
    MYLog(@"我的消息");
}

/**退出登录*/
- (IBAction)logout:(UIButton *)sender {
    MYLog(@"退出登录");
    /**不管是否为新浪登陆的,都要把标记设置为NO*/
    [KRUserInfo sharedKRUserInfo].sinaLogion = NO;
    
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[KRXMPPTool sharedKRXMPPTool].xmppStream sendElement:presence];
    [[KRXMPPTool sharedKRXMPPTool].xmppStream disconnect];
    // 切换到登录界面
    UIStoryboard *stroyborad = [UIStoryboard storyboardWithName:@"LoginAndRegister" bundle:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController = stroyborad.instantiateInitialViewController;

}

@end
