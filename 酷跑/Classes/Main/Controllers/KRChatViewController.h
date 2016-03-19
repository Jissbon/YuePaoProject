//
//  KRChatViewController.h
//  酷跑
//
//  Created by apple on 16/3/3.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPJID.h"

@interface KRChatViewController : UIViewController

/**把要聊天的对象传递过来*/
@property (nonatomic,strong) XMPPJID *friendJid;


@end
