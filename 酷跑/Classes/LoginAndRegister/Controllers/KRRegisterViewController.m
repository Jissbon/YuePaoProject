//
//  KRRegisterViewController.m
//  酷跑
//
//  Created by tarena on 16/1/4.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "KRRegisterViewController.h"
#import "KRUserInfo.h"
#import "KRXMPPTool.h"
#import "AFNetworking.h"
#import "NSString+md5.h"
#import "MBProgressHUD+KR.h"
#import "KRWebRegister.h"

@interface KRRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userRegiserNameField;
@property (weak, nonatomic) IBOutlet UITextField *userRegisterPasswdField;
- (IBAction)registerBtnClick:(id)sender;

@end

@implementation KRRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *imageN = [UIImage imageNamed:@"icon"];
    UIImageView *leftN = [[UIImageView alloc]initWithImage:imageN];
    leftN.frame = CGRectMake(0, 0,35, 20);
    leftN.contentMode = UIViewContentModeCenter;
    self.userRegiserNameField.leftViewMode =
    UITextFieldViewModeAlways;
    self.userRegiserNameField.leftView = leftN;
    UIImage *imageP = [UIImage imageNamed:@"lock"];
    UIImageView *leftP = [[UIImageView alloc]initWithImage:imageP];
    leftP.frame = CGRectMake(0, 0, 35, 20);
    leftP.contentMode = UIViewContentModeCenter;
    self.userRegisterPasswdField.leftViewMode =
    UITextFieldViewModeAlways;
    self.userRegisterPasswdField.leftView = leftP;
}


- (IBAction)registerBtnClick:(id)sender {
    [KRUserInfo sharedKRUserInfo].registerType = YES;
    NSString *rname = self.userRegiserNameField.text;
    NSString *rpasswd = self.userRegisterPasswdField.text;
    [KRUserInfo sharedKRUserInfo].userRegisterName = rname;
    [KRUserInfo sharedKRUserInfo].userRegisterPasswd = rpasswd;
    if (rname.length == 0 || rpasswd.length == 0) {
        [MBProgressHUD showError:@"密码或用户名不能为空"];
        return;
    }
    /** 调用工具类的方法 完成注册 */
    __weak  typeof (self) vc = self;
    [[KRXMPPTool sharedKRXMPPTool]userRegister:^(KRXMPPResultType type) {
        /** 处理注册的状态 */
        [vc handleRegisterType:type];
    }];
}

- (void) handleRegisterType:(KRXMPPResultType) type
{
    switch (type) {
        case KRXMPPResultTypeRegisterSuccess:
            // 发起一个web注册 产生web账号
            [self webRegister];
//            [KRWebRegister webRegister];
            [self dismissViewControllerAnimated:YES completion:nil];
            [MBProgressHUD showSuccess:@"注册成功"];
            break;
        case KRXMPPResultTypeRegisterFaild:
            MYLog(@"注册失败");
            break;
        case KRXMPPResultTypeNetError:
            MYLog(@"注册网路错误");
            break;
        default:
            break;
    }
}
/** 用来产生web账号的注册方法 */
- (void) webRegister
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/%@/register.jsp",KRXMPPHOSTNAME,KRALLRUNSERVER];
    
    /** 准备参数 */
    NSMutableDictionary *parameters =
        [NSMutableDictionary dictionary];
    parameters[@"username"] = [KRUserInfo sharedKRUserInfo].userRegisterName;
    // d9f6ef4eafaca226b91b827a107a0a76
    // 289df25c9cbd8e2aabd20ac859ac6220
    parameters[@"md5password"] = [[KRUserInfo sharedKRUserInfo].userRegisterPasswd md5StrXor];
    parameters[@"nikename"] = [KRUserInfo sharedKRUserInfo].userRegisterName;
    
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        UIImage *headImage = [UIImage imageNamed:@"58"];
        NSData *data = UIImagePNGRepresentation(headImage);
        [formData appendPartWithFileData:data name:@"pic" fileName:@"headImage.png" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"%@",error);
    }];
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end











