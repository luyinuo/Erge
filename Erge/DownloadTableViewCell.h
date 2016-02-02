//
//  DownloadTableViewCell.h
//  Erge
//
//  Created by Maiziedu on 16/2/2.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"

@interface DownloadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *avatarBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (strong, nonatomic) NSMutableDictionary *item;
@property (nonatomic, copy) void (^clickPauseOrStartOperation)(NSString *downloadId,DownloadStatus status);

@end
