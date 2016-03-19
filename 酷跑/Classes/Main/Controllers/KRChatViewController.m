
//
//  KRChatViewController.m
//  酷跑
//
//  Created by apple on 16/3/3.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "KRChatViewController.h"
#import "KRXMPPTool.h"
#import "KRUserInfo.h"
#import "UIImageView+Layout.h"
#import "KRMyMessageCell.h"


@interface KRChatViewController ()<NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForBottom;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;

/**结果集控制器*/
@property (nonatomic,strong) NSFetchedResultsController *krResultController;

@end

@implementation KRChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.friendJid.user;
    [self.tableView setTableFooterView:[UIView new]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //点击空白处收起键盘
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.tableView addGestureRecognizer:singleTap];
    //加载聊天记录
    [self loadMassage];
    //让tablecell自动布局高度
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 1000;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    //键盘即将弹出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openkeyboard:) name:UIKeyboardWillShowNotification object:nil];
    
    //键盘即将收起
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closekeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
    //监听键盘打开与收起的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}

//打开键盘的时候执行方法改变约束
-(void)openkeyboard:(NSNotification *)notification
{
    
    CGRect keyboardFrame = [notification.userInfo [UIKeyboardFrameEndUserInfoKey]CGRectValue];
    
     self.heightForBottom.constant = keyboardFrame.size.height;
    
//    //键盘的动画时间
//    NSTimeInterval durations = [notification.userInfo [UIKeyboardAnimationDurationUserInfoKey]doubleValue];
//   
//    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    
//    [UIImageView animateWithDuration:durations delay:0 options:options animations:^{
//       
//        [self.tableView layoutIfNeeded];
//    } completion:^(BOOL finished) {
//        
//    }];
    
}

//键盘收起时,执行方法,改变约束
-(void)closekeyboard:(NSNotification *)notification
{
    self.heightForBottom.constant = 0;
}


//点击tableview收起键盘
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
}

#pragma mark 加载聊天记录
-(void)loadMassage
{
  //获取上下文
    NSManagedObjectContext *context = [[KRXMPPTool sharedKRXMPPTool].xmppMsagArchStore mainThreadManagedObjectContext];
  //关联实体
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
   //过滤条件,只需要当前聊天对象的聊天记录
    NSString *myJid = [KRUserInfo sharedKRUserInfo].jidStr;
    NSString *friendJid = [NSString stringWithFormat:@"%@@%@",self.friendJid.user,KRXMPPDOMAIN];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ and bareJidStr = %@",myJid,friendJid];
    
    /**设置排序 以聊天时间排序*/
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    
    request.predicate = predicate;
    request.sortDescriptors = @[sortDes];
    
    //执行查询,获取数据;
    NSError *error = nil;
    self.krResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.krResultController.delegate = self;
    [self.krResultController performFetch:&error];
    if (error) {
        MYLog(@"%@",error);
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.krResultController.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KRMyMessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"myMsgCell"];
    XMPPMessageArchiving_Message_CoreDataObject *msgObject = self.krResultController.fetchedObjects[indexPath.row];
    
    if (msgObject.isOutgoing) {
        
        //自己发出消息,对头像进行设置
        NSData *myheadImageData = [[KRXMPPTool sharedKRXMPPTool].xmppvCardAvar photoDataForJID:[XMPPJID jidWithString:[KRUserInfo sharedKRUserInfo].jidStr]];
        if (myheadImageData) {
            cell.headImageView.image = [UIImage imageWithData:myheadImageData];
        }else{
            cell.headImageView.image = [UIImage imageNamed:@"QQ"];
        }
        [cell.headImageView setRoundLayer];
        
        //对聊天内容与用户名的label进行赋值
        NSRange range = [msgObject.streamBareJidStr rangeOfString:@"@"];
        cell.userNameLabel.text = [msgObject.streamBareJidStr substringToIndex:range.location];
        
        if ([msgObject.body hasPrefix:@"text:"]) {
            cell.messageBodyLabel.text = [msgObject.body substringFromIndex:5];
            cell.msgImageView.image = nil;
        }else if ([msgObject.body hasPrefix:@"image:"])
        {
            NSString *dataStr = [msgObject.body substringFromIndex:6];
            NSData *imageData = [[NSData alloc]initWithBase64EncodedString:dataStr options:0];
            UIImage *msgImage = [UIImage imageWithData:imageData];
            cell.msgImageView.image = msgImage;
            cell.messageBodyLabel.text = @"";
        }
        
    }else {
        
        NSData *friendHeadImageData = [[KRXMPPTool sharedKRXMPPTool].xmppvCardAvar photoDataForJID:msgObject.bareJid];
        if (friendHeadImageData) {
             cell.headImageView.image = [UIImage imageWithData:friendHeadImageData];
        }else{
            cell.headImageView.image = [UIImage imageNamed:@"QQ"];
        }
       
        [cell.headImageView setRoundLayer];
        
        cell.userNameLabel.text = self.friendJid.user;
    
//        cell.messageBodyLabel.text = msgObject.body;
//        cell.msgImageView.image = nil;
        if ([msgObject.body hasPrefix:@"text:"]) {
            cell.messageBodyLabel.text = [msgObject.body substringFromIndex:5];
            cell.msgImageView.image = nil;
        }else if ([msgObject.body hasPrefix:@"image:"])
        {
            NSString *dataStr = [msgObject.body substringFromIndex:6];
            NSData *imageData = [[NSData alloc]initWithBase64EncodedString:dataStr options:0];
            UIImage *msgImage = [UIImage imageWithData:imageData];
            cell.msgImageView.image = msgImage;
            cell.messageBodyLabel.text = @"";
        }
    }
    
    return cell;
}


//输入框输入完成后发送消息
- (IBAction)sendMessage:(UITextField *)sender {
    [self sendtextMessage];
}

/**数据变化*/
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    self.messageTextField.text = @"";
    [self.tableView reloadData];
    //调用 最后一行滑动到底部的方法 
    [self scorllTableViewCell];
}

/**tableview滚动表格的最后一行*/
-(void)scorllTableViewCell
{
    
    NSInteger index = self.krResultController.fetchedObjects.count-1;
    if (index<0) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (IBAction)sendmessage:(UIButton *)sender {
    [self sendtextMessage];
}

//发送文本消息的方法
-(void)sendtextMessage
{
    //组装一条消息用来发送
    NSString *msgText = [NSString stringWithFormat:@"text:%@",self.messageTextField.text];
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [msg addBody:msgText];
    
    /**发消息*/
    [[KRXMPPTool sharedKRXMPPTool].xmppStream sendElement:msg];
}


//点击图片按钮
- (IBAction)sendImageButton:(UIButton *)sender {
    UIImagePickerController *picController = [UIImagePickerController new];
    picController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picController.allowsEditing = YES;
    picController.delegate = self;
    [self presentViewController:picController animated:YES completion:nil];
}


#pragma mark UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    //获取相册中选中的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];

    /**生成缩略图*/
    UIImage *thumbImage = [self thumbNailWithImage:image size:CGSizeMake(100,100)];
    NSData *data = UIImageJPEGRepresentation(thumbImage, 0.5);
    
    MYLog(@"%ld",data.length);
    
    /*
     Base64编码表
     码值/字符/码值/字符/码值/字符/码值/字符
     0	  A	  16	Q  32	g	48	w
     1	  B	  17	R  33	h	49	x
     2	  C	  18	S  34	i	50	y
     3	  D	  19	T  35	j	51	z
     4	  E	  20	U  36	k	52	0
     5	  F   21	V  37	l	53	1
     6	  G	  22	W  38	m	54	2
     7	  H	  23	X  39	n	55	3
     8	  I	  24	Y  40	o	56	4
     9	  J	  25	Z  41	p	57	5
     10	  K	  26	a  42	q	58	6
     11	  L	  27	b  43	r	59	7
     12	  M	  28	c  44	s	60	8
     13	  N	  29	d  45	t	61	9
     14	  O	  30	e  46	u	62	+
     15	  P	  31	f  47	v	63	/
     */
    
    [self sendImageMethod:data];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**生成缩略图的方法*/
-(UIImage *)thumbNailWithImage:(UIImage *)image size:(CGSize)size
{
    
    UIImage *newImg = nil;
    if (image == nil) {
        return newImg;
    }else
    {
        //指定缩略图的size
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        newImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return newImg;
    }
}

/**发送图片信息*/
-(void)sendImageMethod:(NSData *)data
{
    //使用base64Str的方法 把 data 转成字符串 组装消息
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    NSString *dataStr = [NSString stringWithFormat:@"image:%@",base64Str];
    
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [msg addBody:dataStr];
    
    /** 用xmppstream 发送消息*/
    [[KRXMPPTool sharedKRXMPPTool].xmppStream sendElement:msg];
    
}

@end
