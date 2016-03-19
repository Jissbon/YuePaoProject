//
//  KRLastMsgCell.h
//  酷跑
//
//  Created by apple on 16/3/6.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KRLastMsgCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *friendHeadImage;

@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
