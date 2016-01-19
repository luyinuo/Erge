//
//  WKPlayerVideoList.m
//  MaiZiEdu
//
//  Created by terrPang on 14-8-18.
//  Copyright (c) 2014年 maiziedu. All rights reserved.
//

#import "WKPlayerVideoList.h"
#import "WKConfig.h"

@implementation WKPlayerVideoList{
    NSArray* videoList;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self setHidden:YES];
    }
    return self;
}

-(void)reloadList:(NSArray *)list{
    _myTabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_myTabView setBackgroundColor:[UIColor colorWithWhite:50.00000f/255.00000f alpha:0.9]];
    [_myTabView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:_myTabView];
    
    videoList = list;
    
    _myTabView.delegate = self;
    _myTabView.dataSource = self;
}

-(void)showView{
    
    [self setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^{

        CGRect frame = self.frame;
        frame.origin.x = mzScreenHeight - frame.size.width;
        self.frame = frame;
    } completion:^(BOOL finished) {
        [_myTabView reloadData];
    }];
}

-(void)myHidden{
    
    [UIView animateWithDuration:0.5 animations:^{

        CGRect frame = self.frame;
        frame.origin.x = mzScreenHeight;
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self setHidden:YES];
    }];
}

#pragma mark tableView的delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [videoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"playerVideoList"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"playerVideoList"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        
        
        [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
        
        UIImageView* lineIm = [[UIImageView alloc] initWithFrame:CGRectMake(15, 79, cell.frame.size.width-15, 1)];
        [lineIm setImage:[UIImage imageNamed:@"L3"]];
        [cell addSubview:lineIm];
    }
    
    if (indexPath.row == _nowIndex) {
        [cell.textLabel setTextColor:mzThemeColorC4];
    }else{
        [cell.textLabel setTextColor:mzThemeColorC3];
    }
    
    [cell.textLabel setText:[videoList[indexPath.row] objectForKey:@"video_name"]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_delegate wkPlayerVideoSelect:indexPath.row];
    [tableView reloadData];
}

@end
