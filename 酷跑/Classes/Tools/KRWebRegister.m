//
//  KRWebRegister.m
//  酷跑
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "KRWebRegister.h"
#import "AFNetworking.h"
#import "KRUserInfo.h"
#import "NSString+md5.h"
@implementation KRWebRegister
+(void)webRegister{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSString *urlString = [NSString stringWithFormat:@"http://%@:8080/%@/register.jsp",KRXMPPHOSTNAME,KRALLRUNSERVER1];
//    /**准备参数*/
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    parameters[@"username"] = [KRUserInfo sharedKRUserInfo].userRegisterName;
//    parameters[@"md5password"] = [[KRUserInfo sharedKRUserInfo].userRegisterPasswd md5StrXor];
//    //post 可上传文件的post方法
//    [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {//这block就是上传文件
//        UIImage *image = [UIImage imageNamed:@"bell_pepper.png"];
//        NSData *data = UIImagePNGRepresentation(image);
//        //第三个参数是上传到web的文件名字 第四个是格式
//        [formData appendPartWithFileData:data name:@"pic" fileName:@"headImage.png" mimeType:@"image/jpeg"];
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        MYLog(@"%@",responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        MYLog(@"请求失败%@",error);
//    }];
}

@end
