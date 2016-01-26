//
//  ViewController.m
//  Erge
//
//  Created by Maiziedu on 16/1/19.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "VideoModel.h"
#import "VideoViewController.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScrollHeight self.mainScrollView.frame.size.height

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UITableView *oneTableView;
@property (weak, nonatomic) IBOutlet UITableView *twoTableView;
@property (weak, nonatomic) IBOutlet UITableView *threeTable;
@property (nonatomic, strong) NSMutableArray *ergeArray;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *segmentButtons;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.oneTableView.rowHeight = 114;
    self.twoTableView.rowHeight = 114;
    self.threeTable.rowHeight = 114;
    self.mainScrollView.delegate = self;
    [self scrollViewDidEndDecelerating:self.mainScrollView];
    self.oneTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.twoTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.threeTable.separatorStyle = UITableViewCellSelectionStyleNone;
    [self setTabBarItemIcon:@"icon_home_h"];
    
    [self loadData];
}

- (void) loadData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"source" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *array = dic[@"erge"];
    NSMutableArray *revertArray = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        VideoModel *model = [VideoModel modelWithDic:dic];
        [revertArray addObject:model];
    }
    self.ergeArray = [NSMutableArray array];
    NSMutableArray *tempArray;
    for (NSInteger i = 0; i < revertArray.count; i++) {
        if (i%2 == 0) {
            tempArray = [NSMutableArray array];
            [tempArray addObject:revertArray[i]];
            if (i == array.count-1) {
                [self.ergeArray addObject:tempArray];
            }
        }else if (i%2 == 1){
            [tempArray addObject:revertArray[i]];
            [self.ergeArray addObject:tempArray];
        }
        
    }
    [self.oneTableView reloadData];
    NSLog(@"%@",self.ergeArray);
}

- (IBAction)onClickSegmentButton:(UIButton *)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.mainScrollView.contentOffset = CGPointMake(ScreenWidth * sender.tag, 0);
        [self scrollViewDidEndDecelerating:self.mainScrollView];
    }];
}

#pragma mark - scrollview delegate
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView != self.mainScrollView) {
        return;
    }
    NSInteger index = scrollView.contentOffset.x / ScreenWidth;
    for (UIButton * button in self.segmentButtons) {
        UIColor *color = [UIColor colorWithRed:251/255.0 green:156/255.0 blue:151/255.0 alpha:1];
        [button setTitleColor:color forState:UIControlStateNormal];
    }
    UIButton *button = self.segmentButtons[index];
    [button setTitleColor:[UIColor colorWithRed:158/255.0 green:59/255.0 blue:59/255.0 alpha:1] forState:UIControlStateNormal];
}

#pragma mark - tableview datasource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.ergeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ergeCell"];
    if (!cell) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ergeCell"];
    }
    cell.models = self.ergeArray[indexPath.row];
    cell.clickPlayerOperation = ^(VideoModel *model){
        VideoViewController *controler = [[VideoViewController alloc] init];
        controler.targetModel = model;
        [self presentViewController:controler animated:YES completion:nil];
    };
    return cell;
    
}


@end
