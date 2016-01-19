//
//  WKPlayerVideoList.h
//  MaiZiEdu
//
//  Created by terrPang on 14-8-18.
//  Copyright (c) 2014年 maiziedu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WKPlayerVideoListDelegate <NSObject>

- (void)wkPlayerVideoSelect:(NSInteger)index;

@end

@interface WKPlayerVideoList : UIView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak) id<WKPlayerVideoListDelegate> delegate;
@property (nonatomic,assign) NSInteger nowIndex;
@property (nonatomic,strong) UITableView* myTabView;

- (void)reloadList:(NSArray *)list;
- (void)showView;
-(void)myHidden;

@end