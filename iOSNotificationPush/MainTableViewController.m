//
//  MainTableViewController.m
//  iOS Remote Notification Push of APNs &. VoIP 
//
//  Created by viviwu on 2015/5/17.
//  Copyright © 2015 viviwu. All rights reserved.
//

#import "MainTableViewController.h"
#import "AppDelegate+Push.h"

@interface MainTableViewController ()

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  self.title = @"APNs &. VoIP Notifications Push";
  
  self.tableView.tableFooterView = [UIView new];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePushTokenToServerIfNeeded) name:kUpdatePushTokenToServerNotification object:nil];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)updatePushTokenToServerIfNeeded{
  [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self fixApplicationIconBadgeNumber];
}

- (void)fixApplicationIconBadgeNumber
{
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
  {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
  }
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (1 == indexPath.section) {
        if (0==indexPath.row) {
            [AppDelegate presentNotification:@"☎️" body:@"100123456" categoryIdentifier:kIncomingCall sound:@"phone.wav"];
        }else if(1==indexPath.row){
            [AppDelegate presentNotification:@"✉️" body:@"I❤️U" categoryIdentifier:kIncomingMsg sound:@"notify.caf"];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    // Configure the cell...
  if(0==indexPath.section){
      cell.accessoryType =UITableViewCellAccessoryNone;
      if (0==indexPath.row) {
          cell.textLabel.text = @"apnsPushToken";
          cell.detailTextLabel.text = kAppDel.apnsPushToken;
      }else if(1==indexPath.row){
          cell.textLabel.text = @"voipPushToken";
          cell.detailTextLabel.text = kAppDel.voipPushToken;
      }
  }if (1==indexPath.section) {
      cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
      if(0==indexPath.row) {
          cell.textLabel.text = @"Present kIncomingCall Notification";
      }else if(1==indexPath.row){
          cell.textLabel.text = @"Present kIncomingMsg Notification";
      }
  }else{
      cell.accessoryType =UITableViewCellAccessoryNone;
  }
    return cell;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED
{
  UITableViewRowAction *copyAction = [UITableViewRowAction rowActionWithStyle: UITableViewRowActionStyleDefault title:@"Copy" handler: ^(UITableViewRowAction *action, NSIndexPath *indexPath) {
    UIPasteboard * psb = [UIPasteboard generalPasteboard];
    if(0==indexPath.section){
        if (0==indexPath.row) {
            psb.string = kAppDel.apnsPushToken;
        }else if(1==indexPath.row){
            psb.string = kAppDel.voipPushToken;
        }
    }else{ }
  }];
 
  copyAction.backgroundColor = [UIColor greenColor];
  copyAction.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  return  @[copyAction];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (0 == indexPath.section) {
        return YES;
    }else
        return NO;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (0 == section) {
        return @"Slide left to copy to pasteboard";
    }else if(1 == section){
        return @"UserLocalNotification";
    }else{
        return @" ";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}
/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
