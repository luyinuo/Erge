//
//  MyDownloadTableViewController.m
//  Erge
//
//  Created by Maiziedu on 16/2/2.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "MyDownloadTableViewController.h"
#import "Config.h"
#import "DownloadTableViewCell.h"
#import "VideoViewController.h"
#import "VideoModel.h"

@interface MyDownloadTableViewController ()<DownloadConfigDelegate>
@property (nonatomic, strong) NSMutableArray *downloadList;
@end

@implementation MyDownloadTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerNib:[UINib nibWithNibName:@"DownloadTableViewCell" bundle:nil] forCellReuseIdentifier:@"DownloadTableViewCell"];
    self.tableView.rowHeight = 122;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self initianizedData];
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [Config sharedConfig].delegate = self;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [Config sharedConfig].delegate = nil;
}
- (void) initianizedData
{
    NSMutableDictionary *downloadDic = [NSMutableDictionary dictionaryWithContentsOfFile:downloadPlistPath];
    NSArray *allKeys = [downloadDic allKeys];
    NSArray *sortKeys = [allKeys sortedArrayUsingFunction:floatSorted context:NULL];
    self.downloadList = [NSMutableArray array];
    for (NSString *key in sortKeys) {
        [self.downloadList addObject:downloadDic[key]];
    }
    if(self.downloadList.count == 0) return;
    [self.downloadList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSInteger status1 = [[obj1 objectForKey:@"status"] integerValue];
        NSInteger status2 = [[obj2 objectForKey:@"status"] integerValue];
        if (status1 == status2) {
            if ([[obj1 objectForKey:@"id"] integerValue] < [[obj2 objectForKey:@"id"] integerValue]) {
                return NSOrderedAscending;
            }else if ([[obj1 objectForKey:@"id"] integerValue] > [[obj2 objectForKey:@"id"] integerValue]){
                return NSOrderedDescending;
            }else{
                return NSOrderedSame;
            }
        }
        if (status1 < status2) {
            return NSOrderedDescending;
        }else if(status1 > status2){
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    [self.tableView reloadData];
}

/**
 *  排序
 *
 *  @param num1
 *  @param num2
 *  @param context
 *
 *  @return
 */
NSInteger floatSorted(id num1, id num2, void *context)
{
    float v1 = [num1 floatValue];
    float v2 = [num2 floatValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}
#pragma mark - DownloadDelegate
- (void)downloadFileManagerDidChangePercent
{
    [self initianizedData];
}

- (void)downloadFileManagerDidChangeSatus
{

}

- (void)downloadFileManagerDidFinished
{
    [self initianizedData];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloadList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadTableViewCell" forIndexPath:indexPath];
    NSMutableDictionary *itemDic = self.downloadList[indexPath.row];
    // Configure the cell...
    cell.item = itemDic;
    cell.clickPauseOrStartOperation = ^(NSString *downloadId,DownloadStatus status){
        NSMutableDictionary *downloadDic = [NSMutableDictionary dictionaryWithContentsOfFile:downloadPlistPath];
        NSMutableDictionary *item = [downloadDic objectForKey:downloadId];
        if (status == DownloadStatusIng) {
            [item setObject:@(DownloadStatusPause) forKey:@"status"];
            [downloadDic setObject:item forKey:downloadId];
            [downloadDic writeToFile:downloadPlistPath atomically:YES];
            [[Config sharedConfig] startDownloadProcessWithPause:YES];
        }else if(status == DownloadStatusPause){
            [item setObject:@(DownloadStatusIng) forKey:@"status"];
            [downloadDic setObject:item forKey:downloadId];
            [downloadDic writeToFile:downloadPlistPath atomically:YES];
            [[Config sharedConfig] startDownloadWithProccessId:downloadId];
        }
        [self initianizedData];
    };
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSMutableDictionary *downloadDic = [NSMutableDictionary dictionaryWithContentsOfFile:downloadPlistPath];
        NSMutableDictionary *item = self.downloadList[indexPath.row];
        [downloadDic removeObjectForKey:[[self.downloadList[indexPath.row] objectForKey:@"id"] stringValue]] ;
        [downloadDic writeToFile:downloadPlistPath atomically:YES];
        NSString *fileName = [item[@"url"] lastPathComponent];
        if ([[item objectForKey:@"status"] intValue] == DownloadStatusOK) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",downloadFileDir,fileName]]) {
                [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",downloadFileDir,fileName] error:nil];
            }
        }else{
            if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.tep",downloadFileDir,fileName]]) {
                [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@.tep",downloadFileDir,fileName] error:nil];
            }
            
        }
        [self.downloadList removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self initianizedData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary *item = self.downloadList[indexPath.row];
    if (!([[item objectForKey:@"status"] intValue] == DownloadStatusOK)) {
        return;
    }
    VideoViewController *controler = [[VideoViewController alloc] init];
    controler.targetModel = [VideoModel modelWithDic:item];
    [self presentViewController:controler animated:YES completion:nil];
}
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
