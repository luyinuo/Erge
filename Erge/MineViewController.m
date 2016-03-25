//
//  MineViewController.m
//  Erge
//
//  Created by Maiziedu on 16/1/26.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "MineViewController.h"
#import "Config.h"
#import "Constaint.h"
#import <StoreKit/StoreKit.h>
@interface MineViewController ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>
@property (weak, nonatomic) IBOutlet UIView *downloadView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (assign, nonatomic) long num1;
@property (assign, nonatomic) long num2;
@property (copy, nonatomic) void (^isParent)();
@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTabBarItemIcon:@"icon_mine_h"];
    self.title = @"个人中心";
    self.downloadView.hidden = isHideDownload;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
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
    [self showAlertViewWith:@"score"];
   
}
- (void) openLink
{
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    if ([identifier isEqualToString:@"feedback"]) {
        [self showAlertViewWith:identifier];
        return NO;
    }
    return YES;
}

- (IBAction)deleteAD:(UIButton *)sender {
    if ([SKPaymentQueue canMakePayments]) {
        [self getProductInfo];
    }else{
        NSLog(@"失败，用户禁止应用内付费");
    }
    
}
/**
 *  获取商品信息
 */
- (void) getProductInfo
{
    NSSet *set = [NSSet setWithArray:@[kIdentifyForADIAP]];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
}

#pragma mark SKProductDelegate method
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    if (products.count == 0) {
        NSLog(@"无法获取到商品信息");
        return;
    }
    SKPayment *payment = [SKPayment paymentWithProduct:products[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
#pragma mark - SKPaymentQueueObserv

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *transition in transactions) {
        switch (transition.transactionState) {
            case SKPaymentTransactionStatePurchased://交易完成
                
                NSLog(@"交易完成 --%@",transition);
                [self transitionCompleted];
                break;
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"交易失败");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"已购买");
                [self transitionRestored];
                break;
            default:
                break;
        }
    }
}
/**
 *  交易完成
 */
- (void) transitionCompleted
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kVIP];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
/**
 *  已购买
 */
- (void) transitionRestored
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kVIP];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) showAlertViewWith:(NSString *) identifier
{
    self.num1 = random()%9 + 1;
    self.num2 = random()%9 + 1;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入正确答案获取家长控制" message:[NSString stringWithFormat:@"%li x %li = ?",self.num1,self.num2] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *field = [alertView textFieldAtIndex:0];
    field.keyboardType = UIKeyboardTypeNumberPad;
    [alertView show];
    typeof(self) weakSelf = self;
    self.isParent = ^(){
        if ([identifier isEqualToString:@"score"]) {
            [weakSelf openLink];
        }else{
            [weakSelf performSegueWithIdentifier:identifier sender:nil];
        }
        
    };
    return NO;

}

-(void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //得到输入框
    UITextField *tf=[alertView textFieldAtIndex:0];
    [tf resignFirstResponder];
    if (buttonIndex == 1) {
        if ([tf.text integerValue] == self.num1 * self.num2) {
            NSLog(@"success");
            if(self.isParent){
                self.isParent();
            }
        }
    }
    
}
@end
