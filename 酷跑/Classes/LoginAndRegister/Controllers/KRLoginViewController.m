//
//  KRLoginViewController.m
//  酷跑
//
//  Created by tarena on 15/12/31.
//  Copyright © 2015年 tarena. All rights reserved.
//

#import "KRLoginViewController.h"
#import "KRUserInfo.h"
#import "KRXMPPTool.h"
#import "MBProgressHUD+KR.h"
@interface KRLoginViewController ()@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *userPasswdField;
- (IBAction)loginBtnClick:(id)sender;

@end

@implementation KRLoginViewController
/** 登录成功应该 跳转界面
- (void)krLoginSuccess
{
    UIStoryboard *storyborad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController =
    storyborad.instantiateInitialViewController;
}
- (void)krLoginFailed
{
    MYLog(@"登录失败");
}
- (void)krNetError
{
    MYLog(@"网络错误");
} */
- (void)viewDidLoad {
    [super viewDidLoad];
    /** 设置代理 */
    //[KRXMPPTool sharedKRXMPPTool].delegate = self;
    // Do any additional setup after loading the view.
    
}
//修改状态栏的颜色
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *imageN = [UIImage imageNamed:@"icon"];
    UIImageView *leftN = [[UIImageView alloc]initWithImage:imageN];
    leftN.frame = CGRectMake(0, 0, 35, 20);
    leftN.contentMode = UIViewContentModeCenter;
    self.userNameField.leftViewMode =
         UITextFieldViewModeAlways;
    self.userNameField.leftView = leftN;
    UIImage *imageP = [UIImage imageNamed:@"lock"];
    UIImageView *leftP = [[UIImageView alloc]initWithImage:imageP];
    leftP.frame = CGRectMake(0, 0, 35, 20);
    leftP.contentMode = UIViewContentModeCenter;
    self.userPasswdField.leftViewMode =
    UITextFieldViewModeAlways;
    self.userPasswdField.leftView = leftP;
    
}


- (IBAction)loginBtnClick:(id)sender {
    [KRUserInfo sharedKRUserInfo].registerType = NO;
    KRUserInfo *userInfo = [KRUserInfo sharedKRUserInfo];
    userInfo.userName = self.userNameField.text;
    userInfo.userPasswd = self.userPasswdField.text;
    
    /**判断用户名密码不能为空*/
    if (self.userNameField.text.length == 0 || self.userPasswdField.text.length == 0) {
        [MBProgressHUD showError:@"用户名密码不能为空"];
        return;
    }
    
    [MBProgressHUD showMessage:@"正在登陆"];
    
    // 点击登录按钮 调用工具的登录方法
    __weak  typeof(self) vc = self;
    [[KRXMPPTool sharedKRXMPPTool] userLogin:^(KRXMPPResultType type) {
        [vc handleLoginResultType:type];
    }];
    //[[KRXMPPTool sharedKRXMPPTool]userLogin:nil];
}
/** 处理登录的返回状态 */
- (void) handleLoginResultType:(KRXMPPResultType) type
{
    [MBProgressHUD hideHUD];
    switch (type) {
        case KRXMPPResultTypeLoginSuccess:
        {
            MYLog(@"登录成功");
            // 切换到主界面
            UIStoryboard *stroyborad =
            [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = stroyborad.instantiateInitialViewController;
            break;
        }
        case KRXMPPResultTypeLoginFaild:
            [MBProgressHUD showError:@"登陆失败"];
            break;
        case KRXMPPResultTypeNetError:
            MYLog(@"网络错误");
            break;
        default:
            break;
    }
}

/** 证明这个控制器释放了 */
- (void)dealloc
{
    MYLog(@"登录控制器 %@被释放了",self);
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.userNameField resignFirstResponder];
    [self.userPasswdField resignFirstResponder];
}

@end








