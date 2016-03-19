//
//  KRSinaLoginViewController.m
//  酷跑
//
//  Created by apple on 16/3/1./Users/apple/Desktop/酷跑/酷跑/Classes/LoginAndRegister/Controllers/KRSinaLoginViewController.m
//  Copyright © 2016年 tarena. All rights reserved.
//




//#define  APPKEY       @"2075708624"//老师给的APPKEY
#define APPKEY  @"1041121262" //我注册的APPKEY
#define  REDIRECT_URI @"http://www.tedu.cn"//老师给的回调URL/我自己写的回调URL也是这个
//#define  APPSECRET    @"36a3d3dec55af644cd94a316fdd8bfd8"
#define  APPSECRET  @"ebc4039376cb7067c4882b9dff165682" //我注册啊APPSECRET

#import "KRSinaLoginViewController.h"
#import "AFNetworking.h"
#import "KRUserInfo.h"
#import "KRXMPPTool.h"
#import "MBProgressHUD+KR.h"
#import "NSString+md5.h"

#import "KRWebRegister.h"

@interface KRSinaLoginViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation KRSinaLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**按照新浪微博请求url*/
    NSString *url = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&redirect_uri=%@",APPKEY,REDIRECT_URI];
    self.webView.delegate = self;
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]]];
}

- (IBAction)backItem:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    MYLog(@"%@",request.URL.absoluteString);
    NSString *urlPath = request.URL.absoluteString;
    /** 把urlPath ?code= 后边的内容截取 */
    
    NSRange  range = [urlPath rangeOfString:[NSString stringWithFormat:@"%@/?code=",REDIRECT_URI]];
    NSString *code = nil;
    if (range.length > 0) {
        code = [urlPath substringFromIndex:range.length];
        MYLog(@"test");
        /** 使用code 换取 access_token */
        [self getaccessTokenWithCode:code];
        
        return NO;
    }
    return YES;
}
-(void)getaccessTokenWithCode:(NSString *)code
{
    /**导入AFNetWorking 发请求,获取access_token*/
    /** 导入AFN  发请求 获得access_token */
    NSString *url = @"https://api.weibo.com/oauth2/access_token";
    AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dictnary = [NSMutableDictionary dictionary];
    dictnary[@"client_id"] = APPKEY;
    dictnary[@"client_secret"] = APPSECRET;
    dictnary[@"grant_type"] = @"authorization_code";
    dictnary[@"code"] = code;
    dictnary[@"redirect_uri"] = REDIRECT_URI;
    
    [manager POST:url parameters:dictnary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        MYLog(@"%@",responseObject);
        
        /** 把获取的信息 转换成程序内部账号 */
        [KRUserInfo sharedKRUserInfo].userRegisterName = responseObject[@"uid"];
        [KRUserInfo sharedKRUserInfo].userRegisterPasswd = responseObject[@"access_token"];
        [KRUserInfo sharedKRUserInfo].registerType = YES;
        
        __weak typeof (self) vc = self;
        
        [[KRXMPPTool sharedKRXMPPTool] userRegister:^(KRXMPPResultType type) {
            [vc handleRegisterResultType:type];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"%@",error);
    }];
}

/** 处理注册的逻辑 */
- (void) handleRegisterResultType:(KRXMPPResultType) type
{
    switch (type) {
        case KRXMPPResultTypeRegisterSuccess:
            /** 如果需要web账号也应该注册一个*/
            [self webRegister];
//            [KRWebRegister webRegister];
            
        case KRXMPPResultTypeRegisterFaild:
        {
            /** 无论注册成功与否都登录 */
            [KRUserInfo sharedKRUserInfo].userName = [KRUserInfo sharedKRUserInfo].userRegisterName;
            [KRUserInfo sharedKRUserInfo].userPasswd = [KRUserInfo sharedKRUserInfo].userRegisterPasswd;
            [KRUserInfo sharedKRUserInfo].registerType = NO;
            
            __weak typeof (self) vc = self;
            [[KRXMPPTool sharedKRXMPPTool]userLogin:^(KRXMPPResultType type) {
                [vc handleLoginResultType:type];
            }];
         }
            break;
        case  KRXMPPResultTypeNetError:
            MYLog(@"sina register net error");
            break;
        default:
            break;
    }
}

-(void)handleLoginResultType:(KRXMPPResultType)type
{
    switch (type) {
        case KRXMPPResultTypeLoginSuccess:
        {
            MYLog(@"登录成功");
            
            /**为属性赋值,标记是新浪登陆*/
            [KRUserInfo sharedKRUserInfo].sinaLogion = YES;
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
@end
