//
//  KREditMyProfileViewController.h
//  酷跑
//
//  Created by apple on 16/3/2.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPvCardTemp.h"

@interface KREditMyProfileViewController : UIViewController

/**用来存储一个用户个人信息的名片*/
@property (nonatomic,strong) XMPPvCardTemp *myProfile;

@end
