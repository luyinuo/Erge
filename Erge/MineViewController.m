//
//  MineViewController.m
//  Erge
//
//  Created by Maiziedu on 16/1/26.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "MineViewController.h"
#import "Config.h"
@interface MineViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTabBarItemIcon:@"icon_mine_h"];
    self.title = @"个人中心";
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)openAppLink:(UIButton *)sender {
    
    NSString *address;
    
    if (Ios7Later) {
        address = [NSString stringWithFormat:
                   @"itms-apps://itunes.apple.com/app/id%@",
                   AppleId];
    }else{
        address = [NSString stringWithFormat:
                   @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",
                   AppleId];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:address]];
}

@end
