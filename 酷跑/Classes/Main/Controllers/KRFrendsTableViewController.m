//
//  KRFrendsTableViewController.m
//  酷跑
//
//  Created by apple on 16/3/3.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "KRFrendsTableViewController.h"
#import "KRXMPPTool.h"
#import "KRUserInfo.h"
#import "UIImageView+Layout.h"
#import "KRFriendCell.h"
#import "KRChatViewController.h"

@interface KRFrendsTableViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic,strong) NSArray *friends;

@property (nonatomic,strong) NSFetchedResultsController *fetchController;

@end

@implementation KRFrendsTableViewController


- (IBAction)backBtnClick:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setTableFooterView:[UIView new]];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //用结果集加载好友列表
    [self loadFirend2];
}

-(void)loadFirend2
{
    /** 获取上下文  */
    NSManagedObjectContext *context = [[KRXMPPTool sharedKRXMPPTool].xmppRosterStorage mainThreadManagedObjectContext];
    
    /** 关联实体 */
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    
    /**设置过滤条件,只获取当前登陆账号的好友*/
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[KRUserInfo sharedKRUserInfo].jidStr];
    request.predicate = pre;
    
    //排序好友列表
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.friends.count;
    return self.fetchController.fetchedObjects.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   static NSString *identifer = @"friendCell";
     KRFriendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifer];
    
//    XMPPUserCoreDataStorageObject *friend = self.friends[indexPath.row];//通过数组实现
    XMPPUserCoreDataStorageObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    
    NSData *data = [[KRXMPPTool sharedKRXMPPTool].xmppvCardAvar photoDataForJID:friend.jid];
    if (data) {
        cell.headImageView.image = [UIImage imageWithData:data];
    }else
    {
        cell.headImageView.image = [UIImage imageNamed:@"QQ"];
    }
    [cell.headImageView setRoundLayer];
    
    NSRange range =[friend.jidStr rangeOfString:@"@"];
    NSString *friendname = [friend.jidStr substringToIndex:range.location];
    cell.userNameLabel.text = friendname;
    
    switch ([friend.sectionNum intValue]) {
        case 0:
            cell.friendStatusLabel.text = @"在线";
            break;
        case 1:
            cell.friendStatusLabel.text = @"离开";
            break;
        case 2:
            cell.friendStatusLabel.text = @"离线";
            break;
        default:
            break;
    }
    
    return cell;
}
/**数据变化*/
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}
/**删除好友*/
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[KRXMPPTool sharedKRXMPPTool].xmppRoster removeUser:friend.jid];
    }
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

/**选中某一行的时候跳转*/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    
    [self performSegueWithIdentifier:@"chatSegue" sender:friend.jid];
}


@end
