//
//  AppDelegate.m
//  酷跑
//
//  Created by tarena on 15/12/31.
//  Copyright © 2015年 tarena. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setThme];
    
    self.manager = [[BMKMapManager alloc]init];
    [self.manager start:@"QYPBodqEEN4mhUIrDWtXE6G9" generalDelegate:self];
    
    
    return YES;
}

/**设置统一的导航栏*/
-(void)setThme
{
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setBackgroundImage:[UIImage imageNamed:@"矩形"] forBarMetrics:UIBarMetricsDefault];
    bar.barStyle = UIBarStyleBlack;
    bar.tintColor = [UIColor whiteColor];
}

/** 地图联网状态 */
-(void)onGetNetworkState:(int)iError
{
    if (iError==0) {
        MYLog(@"联网成功");
    }else{
        MYLog(@"onGetNetWorkState%d",iError);
    }
}

/**授权状况*/
- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        MYLog(@"授权成功");
    }else
    {
        MYLog(@"onGetPermissionState:%d",iError);
    }
}
@end
