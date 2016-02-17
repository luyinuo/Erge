//
//  FeedbackViewController.m
//  Erge
//
//  Created by Maiziedu on 16/2/16.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "FeedbackViewController.h"
#import <BmobSDK/Bmob.h>
#import "DeviceInfo.h"
@interface FeedbackViewController ()
@property (weak, nonatomic) IBOutlet UITextField *contactField;
@property (weak, nonatomic) IBOutlet UITextView *contentView;

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 5;
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(commitFeedback)];
    self.navigationItem.rightBarButtonItem = doneBtn;
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void) commitFeedback
{
    
    if (self.contentView.text.length == 0) {
        [@"请输入反馈信息" showRemind:nil];
        return;
    }
    BmobObject *feedback = [BmobObject objectWithClassName:@"Feedback"];
    [feedback setObject:self.contactField.text forKey:@"contact"];
    [feedback setObject:[DeviceInfo deviceVersion] forKey:@"service"];
    [feedback setObject:self.contentView.text forKey:@"content"];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [feedback saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        //进行操作
        if (isSuccessful) {
            self.contactField.text = @"";
            self.contentView.text = @"";
            [@"提交成功，感谢您的反馈！" showRemind:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else{
            [@"提交失败，请稍后再试！" showRemind:nil];
        }
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
    }];
    
}

@end
