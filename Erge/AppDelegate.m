//
//  AppDelegate.m
//  Erge
//
//  Created by Maiziedu on 16/1/19.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"
#import <BmobSDK/Bmob.h>
#import "Constaint.h"
#import "AdwoAdSDK.h"
// 由于工程里没有添加Passbook.framework，因此加上这句话来避免连接错误
ADWO_SDK_WITHOUT_PASSKIT_FRAMEWORK(I do not need PassKit framework)

@interface AppDelegate ()<AWAdViewDelegate>
{
    UIView *AdView;//full screen
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    [Bmob registerWithAppKey:@"fc16b8978032b7ababb8721e77b785b1"];
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"AppInfo"];
    [bquery getObjectInBackgroundWithId:@"pyY6aaak" block:^(BmobObject *object,NSError *error){
        if (error){
            //进行错误处理
        }else{
            //表里有id为0c6db13c的数据
            if (object) {
                //得到playerName和cheatMode
                self.versionNo = [object objectForKey:@"versionNo"];
                self.isOnChecking = [[object objectForKey:@"isCheck"] boolValue];
                NSLog(@"version = %@  and ischecking = %@",self.versionNo,@(self.isOnChecking));
            }
        }
    }];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationWillEnterForeground" object:nil];
    [self showButtonTouched:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"terminate");
    NSMutableDictionary *downloadDic = [NSMutableDictionary dictionaryWithContentsOfFile:downloadPlistPath];
    if ([Config sharedConfig].currentProcessId.length > 0) {
        NSMutableDictionary *item = downloadDic[[Config sharedConfig].currentProcessId];
        if ([item[@"status"] intValue] == DownloadStatusIng) {
            [item setObject:@(DownloadStatusPause) forKey:@"status"];
            [downloadDic setObject:item forKey:[Config sharedConfig].currentProcessId];
            [downloadDic writeToFile:downloadPlistPath atomically:YES];
        }
    }
}

- (void)showButtonTouched:(id)sender
{
    if(AdView != nil)
        return;
    
    // 初始化AWAdView对象
    AdView = AdwoAdGetFullScreenAdHandle(ADWO_PUBLISH_ID_FOR_DEMO, ADWO_FSAD_TEST_MODE, self, ADWOSDK_FSAD_SHOW_FORM_APPFUN_WITH_BRAND);
    if(AdView == nil)
    {
        NSLog(@"Adwo full-screen ad failed to create!");
        return;
    }
    
    // 这里使用ADWO_ADSDK_AD_TYPE_FULL_SCREEN标签来加载全屏广告
    // 全屏广告是立即加载的，因此不需要设置adRequestTimeIntervel属性，当然也不需要设置其frame属性
    if(!AdwoAdLoadFullScreenAd(AdView, NO, NULL))
    {
        NSLog(@"加载失败，由于：%d", AdwoAdGetLatestErrorCode());
        AdView = nil;  // 若加载失败，则SDK将会自动销毁当前的全屏广告对象，此时将全屏广告对象引用置空即可
    }
}

#pragma mark - ad delegate
// 此接口必须被实现，并且不能返回空！
- (UIViewController*)adwoGetBaseViewController
{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

- (void)adwoAdViewDidFailToLoadAd:(UIView*)ad
{
    NSLog(@"Failed to load ad! Because: %@",adwoResponseErrorInfoList[AdwoAdGetLatestErrorCode()]);
    
    AdView = nil;
}

- (void)adwoAdViewDidLoadAd:(UIView*)ad
{
    NSLog(@"Ad did load!");
    
    // 广告加载成功，可以把全屏广告展示上去
    AdwoAdShowFullScreenAd(AdView);
}

- (void)adwoFullScreenAdDismissed:(UIView*)ad
{
    NSLog(@"Full-screen ad closed by user!");
    AdView = nil;
}

- (void)adwoDidPresentModalViewForAd:(UIView*)ad
{
    NSLog(@"Browser presented!");
}

- (void)adwoDidDismissModalViewForAd:(UIView*)ad
{
    NSLog(@"Browser dismissed!");
}

@end
