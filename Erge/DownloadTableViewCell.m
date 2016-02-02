//
//  DownloadTableViewCell.m
//  Erge
//
//  Created by Maiziedu on 16/2/2.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "DownloadTableViewCell.h"

@implementation DownloadTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (void) setItem:(NSMutableDictionary *)itemDic
{
    _item = itemDic;
    self.avatarBtn.enabled = !([itemDic[@"status"] integerValue] == DownloadStatusWait);
    [self.avatarBtn setBackgroundImage:[UIImage imageNamed:itemDic[@"avatar"]] forState:UIControlStateNormal];
    [self.avatarBtn setBackgroundImage:[UIImage imageNamed:itemDic[@"avatar"]] forState:UIControlStateDisabled];
    NSString *title = ([itemDic[@"status"] integerValue] == DownloadStatusIng)?@"下载中...":([itemDic[@"status"] integerValue] == DownloadStatusPause) ? @"暂停中":@"";
    [self.avatarBtn setTitle:@"排队等待中" forState:UIControlStateDisabled];
    [self.avatarBtn setTitle:title forState:UIControlStateNormal];
    self.nameLabel.text = itemDic[@"name"];
    self.percentLabel.text = [NSString stringWithFormat:@"%@%%",itemDic[@"percent"]];
}

- (IBAction)pauseOrStart:(id)sender {
    if (self.clickPauseOrStartOperation) {
        self.clickPauseOrStartOperation([self.item[@"id"] stringValue],[self.item[@"status"] intValue]);
    }
}

@end
