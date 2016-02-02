//
//  Config.h
//  Erge
//
//  Created by Maiziedu on 16/1/28.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import <Foundation/Foundation.h>
#define downloadPlistPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"downloads/downloads.plist"]
//视频下载目录
#define downloadFileDir [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"downloads"]
//系统是否为7.0以上
#define Ios7Later ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
//保存应用在商店中的的apple id
#define AppleId @"914713849"
typedef NS_ENUM(NSUInteger, DownloadStatus){
    DownloadStatusWait = 0, //队列中等待下载
    DownloadStatusPause,    //暂停
    DownloadStatusIng,      //正在下载
    DownloadStatusOK        //下载成功
};
@protocol DownloadConfigDelegate <NSObject>

- (void) downloadFileManagerDidChangePercent;
- (void) downloadFileManagerDidChangeSatus;
- (void) downloadFileManagerDidFinished;
@end
@interface Config : NSObject
@property (nonatomic, weak) id<DownloadConfigDelegate> delegate;
@property (nonatomic, strong) NSString *currentProcessId;
+ (Config*) sharedConfig;
- (void) startDownloadProcessWithPause:(BOOL) isPause;
- (void) startDownloadWithProccessId:(NSString *)processId;
@end
