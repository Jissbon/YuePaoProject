//
//  KRAddFriendViewController.m
//  酷跑
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "KRAddFriendViewController.h"
#import "KRXMPPTool.h"
#import "KRUserInfo.h"
@interface KRAddFriendViewController ()
@property (weak, nonatomic) IBOutlet UITextField *friendUserName;

@end

@implementation KRAddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"添加好友";
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}
//点击确认添加按钮
- (IBAction)addFriendBtn:(UIButton *)sender {
    [[KRXMPPTool sharedKRXMPPTool] rosterAddfrendWithName:self.friendUserName.text];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)back:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
