//
//  KREditMyProfileViewController.m
//  酷跑
//
//  Created by apple on 16/3/2.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "KREditMyProfileViewController.h"
#import "KRXMPPTool.h"
#import "UIImageView+Layout.h"

@interface KREditMyProfileViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UITextField *nickNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailfield;

@end

@implementation KREditMyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.myProfile.photo) {
        self.headImageView.image = [UIImage imageWithData:self.myProfile.photo];
    }else{
        self.headImageView.image = [UIImage imageNamed:@"QQ"];
    }
    self.nickNameField.text = self.myProfile.nickname;
    //xmpp自身没有实现emailAddresses 的实现
//    self.emailfield.text = self.myProfile.emailAddresses;
    
    self.emailfield.text = self.myProfile.mailer;
    [self.headImageView setRoundLayer];
    
    /**打开用户交互*/
    self.headImageView.userInteractionEnabled = YES;
    //增加手势
    [self.headImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headImageViewtap)]];
    
}

-(void)headImageViewtap
{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相机" otherButtonTitles:@"相册", nil];
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0://点击相机
       
            //判断是在模拟器运行还是在真机测试
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                //调出相机
                UIImagePickerController *pc = [[UIImagePickerController alloc]init];
                pc.allowsEditing = YES;
                pc.sourceType = UIImagePickerControllerSourceTypeCamera;
                pc.delegate = self;
                [self presentViewController:pc animated:YES completion:nil];
            }
            break;
        case 1://点击相册
        {
            //调出相册
            UIImagePickerController *pc = [[UIImagePickerController alloc]init];
            pc.allowsImageEditing = YES;//允许打开相册后的图片可编辑
            pc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pc.delegate = self;
            [self presentViewController:pc animated:YES completion:nil];
        }
            break;
        case 2://点击取消
            break;
        default:
            break;
    }
}

/**选择图片*/
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    self.headImageView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)yesBtnClick:(UIButton *)sender {
    self.myProfile.nickname = self.nickNameField.text;
    self.myProfile.mailer = self.emailfield.text;
    /**修改头像*/
    NSData *data = UIImagePNGRepresentation(self.headImageView.image);
    self.myProfile.photo = data;
    
    /**使用xmppvCard模块 更新数据*/
    [[KRXMPPTool sharedKRXMPPTool].xmppvCard updateMyvCardTemp:self.myProfile];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backBarBtnClick:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
