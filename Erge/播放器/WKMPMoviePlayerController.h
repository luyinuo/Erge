//
//  WKMPMoviePlayerController.h
//  MaiZiEdu
//
//  Created by terrPang on 14-9-12.
//  Copyright (c) 2014年 maiziedu. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "WKPlayerVideoList.h"
//系统是否为7.0以上
#define mzIos7Later ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
//设备屏幕尺寸
#define mzScreenHeight   ([UIScreen mainScreen].bounds.size.height)
#define mzScreenWidth    ([UIScreen mainScreen].bounds.size.width)
#define mzThemeColorC2 [UIColor colorWithRed:191.00000f/255.00000f green:205.00000f/255.00000f blue:202.00000f/255.00000f alpha:1]
//视频下载目录
#define mzDirDownloads [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"downloadsN"]
//视频临时播放目录
#define mzDirPlayCache [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp"]

@protocol WKMPMoviePlayerControllerDelegate <NSObject>

- (void)wkMPMoviePlayerControllerClickBack;
- (void)wkMPMoviePlayerControllerEnterFullScreen:(BOOL )isFullScreen;

@end

typedef void(^ProgressOperation)(float );

@interface WKMPMoviePlayerController : MPMoviePlayerController

@property (nonatomic,weak) id<WKMPMoviePlayerControllerDelegate> delegate;
@property (nonatomic,strong) WKPlayerVideoList * wkPlayerVideoList;
@property (nonatomic,assign) BOOL              isPlaying;
@property (nonatomic,assign) BOOL              isPop;
@property (nonatomic,strong) NSTimer           * timerUpdateState;
@property (nonatomic,strong) NSString          * myTitle;
@property (nonatomic,strong) UIActivityIndicatorView* viewPlayerLoading;
@property (nonatomic,strong) UILabel* lbLoadErr;
@property (nonatomic,copy) ProgressOperation progressOperation;
- (void)playVideoWithUrl:(NSString *)urlString;

@end
