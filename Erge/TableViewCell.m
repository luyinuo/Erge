//
//  TableViewCell.m
//  Erge
//
//  Created by Maiziedu on 16/1/19.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:nil options:nil] lastObject];

    }
    return self;
}

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)clickPlayerBtn:(UIButton *)sender {
    
    NSInteger tag = sender.tag;
    VideoModel *model = self.models[tag];
    if (self.clickPlayerOperation) {
        self.clickPlayerOperation(model);
    }
}

- (void)setModels:(NSArray *)models
{
    _models = models;
    VideoModel *leftModel = models[0];
    VideoModel *rightModel = models.count > 1?models[1]:nil;
    self.rightView.hidden = !rightModel;
    
    self.leftTitle.text = leftModel.name;
    [self.leftButton setBackgroundImage:[UIImage imageNamed:leftModel.avatar] forState:UIControlStateNormal];
    self.rightTitle.text = rightModel?rightModel.name:@"";
    [self.rightButton setBackgroundImage:[UIImage imageNamed:rightModel?rightModel.avatar:@""] forState:UIControlStateNormal];
    
}
@end
