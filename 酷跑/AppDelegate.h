//
//  AppDelegate.h
//  酷跑
//
//  Created by tarena on 15/12/31.
//  Copyright © 2015年 tarena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) BMKMapManager *manager;

#pragma mark 使用百度地图至少有一个.mm后缀的文件 ,引文百度地图是用C++写的
@end

