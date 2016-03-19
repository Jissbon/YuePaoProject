//
//  KRMyLastMessageTableViewController.m
//  酷跑
//
//  Created by apple on 16/3/6.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "KRMyLastMessageTableViewController.h"
#import "KRXMPPTool.h"
#import "KRUserInfo.h"
#import "UIImageView+Layout.h"
#import "KRLastMsgCell.h"
#import "KRChatViewController.h"

@interface KRMyLastMessageTableViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic,strong) NSFetchedResultsController *fetchController;

@end

@implementation KRMyLastMessageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadLastMsg];
}

/**加载最后的消息的方法*/
-(void)loadLastMsg{
    
    /** 获取上下文  */
    NSManagedObjectContext *context = [[KRXMPPTool sharedKRXMPPTool].xmppMsagArchStore mainThreadManagedObjectContext];
    
    /** 关联实体 */
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"XMPPMessageArchiving_Contact_CoreDataObject"];
    
    /**设置过滤条件,只获取当前登陆账号的好友*/
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[KRUserInfo sharedKRUserInfo].jidStr];
    request.predicate = pre;
    
    //排序好友列表
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending:YES];
    request.sortDescriptors = @[sortDes];
    
    //获取数据;
    NSError *error = nil;
    self.fetchController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchController.delegate = self;
    [self.fetchController performFetch:&error];
    if (error) {
        MYLog(@"%@",error);
    }
    
    
}
- (IBAction)back:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark  UItableViewdataSource/UItableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchController.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    XMPPMessageArchiving_Contact_CoreDataObject *obj = self.fetchController.fetchedObjects[indexPath.row];
    if ([obj.mostRecentMessageBody hasPrefix:@"image:"]) {
       cell.textLabel.text = @"[图片]";
    }else if ([obj.mostRecentMessageBody hasPrefix:@"text:"]){
        cell.textLabel.text = [obj.mostRecentMessageBody substringFromIndex:5];
    }else
    {
        cell.textLabel.text = obj.mostRecentMessageBody;
    }
    NSData *data = [[KRXMPPTool sharedKRXMPPTool].xmppvCardAvar photoDataForJID:obj.bareJid];
    if (data) {
         cell.imageView.image = [UIImage imageWithData:data];
    }else{
        cell.imageView.image = [UIImage imageNamed:@"QQ"];
    }
   
    
    return cell;
}

/**选中某一行的时候跳转*/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPMessageArchiving_Contact_CoreDataObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    
    [self performSegueWithIdentifier:@"chatSegue2" sender:friend.bareJid];
}

/**跳转之前设置参数*/
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id desVC = segue.destinationViewController;
    if ([desVC isKindOfClass:[KRChatViewController class]])
    {
        KRChatViewController *chatVc = (KRChatViewController *)desVC;
        chatVc.friendJid = sender;
    }
}



@end
