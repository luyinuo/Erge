//
//  BaseViewController.m
//  Erge
//
//  Created by Maiziedu on 16/1/26.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)setTabBarItemIcon:(NSString *)icon
{
    [self.tabBarItem setSelectedImage:[[UIImage imageNamed:icon] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
