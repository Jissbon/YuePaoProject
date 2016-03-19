//
//  UIImageView+Layout.m
//  酷跑
//
//  Created by apple on 16/3/2.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "UIImageView+Layout.h"

@implementation UIImageView (Layout)

- (void) setRoundLayer
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width*0.5;
    self.layer.borderWidth = 1;//边框的宽度
    self.layer.borderColor = [[UIColor whiteColor]CGColor]; //边框的颜色
}

@end
