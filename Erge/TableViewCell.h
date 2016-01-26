//
//  TableViewCell.h
//  Erge
//
//  Created by Maiziedu on 16/1/19.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"


@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (nonatomic, strong) NSArray *models;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UILabel *leftTitle;
@property (weak, nonatomic) IBOutlet UILabel *rightTitle;


@property (copy, nonatomic) void (^clickPlayerOperation)(VideoModel *model);

@end
