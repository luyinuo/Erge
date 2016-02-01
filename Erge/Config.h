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
typedef NS_ENUM(NSUInteger, DownloadStatus){
    DownloadStatusWait = 0, //队列中等待下载
    DownloadStatusIng,      //正在下载
    DownloadStatusOK        //下载成功
};
@protocol DownloadConfigDelegate <NSObject>

- (void) downloadFileManagerDidChangePercent;
- (void) downloadFileManagerDidChangeSatus;
- (void) downloadFileManagerDidFinished;
@end
@interface Config : NSObject
@property (nonatomic, copy) id<DownloadConfigDelegate> delegate;
+ (Config*) sharedConfig;
- (void) startDownloadProcessWithPause:(BOOL) isPause;
@end
