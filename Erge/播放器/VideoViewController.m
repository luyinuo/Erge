//
//  VideoViewController.m
//  Erge
//
//  Created by Maiziedu on 16/1/20.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "VideoViewController.h"
#import "WKMPMoviePlayerController.h"

@interface VideoViewController ()<WKMPMoviePlayerControllerDelegate,WKPlayerVideoListDelegate>
@property (nonatomic, strong) NSMutableDictionary *downloadDic;
@end

@implementation VideoViewController{
    
    WKMPMoviePlayerController *moviePlayerController;
}

- (NSMutableDictionary *) downloadDic
{
    _downloadDic = [[NSMutableDictionary alloc] initWithContentsOfFile:downloadPath];
    if (!_downloadDic) {
        _downloadDic = [NSMutableDictionary dictionary];
    }
    return _downloadDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadMoviePlayer];
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 20, 50, 44);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    [backBtn addTarget:self action:@selector(tapBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadBtn.frame = CGRectMake(90, 20, 50, 44);
    [downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
    [self.view addSubview:downloadBtn];
    [downloadBtn addTarget:self action:@selector(clickDownload) forControlEvents:UIControlEventTouchUpInside];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) tapBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) clickDownload
{
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    [tempDic setObject:self.targetModel.url forKey:@"url"];
    [tempDic setObject:self.targetModel.name forKey:@"name"];
    [tempDic setObject:self.targetModel.avatar forKey:@"avatar"];
    [tempDic setObject:self.targetModel.identity forKey:@"id"];
    [tempDic setObject:@0 forKey:@"percent"];
    [self.downloadDic setObject:tempDic forKey:[self.targetModel.identity stringValue]];
    //下载列表写入文件
    if (![[NSFileManager defaultManager] isExecutableFileAtPath:mzDirDownloads]) {
        NSLog(@"  该路径文件不可执行...........");
    }
    Config *config = [Config sharedConfig];
    NSLog(@"%@",downloadPath);
    BOOL result = [_downloadDic writeToFile:downloadPath atomically:YES];
    if (result) {
        NSLog(@"写入数据成功");
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    moviePlayerController.isPop = YES;
    [moviePlayerController stop];
    [moviePlayerController.timerUpdateState invalidate];
    moviePlayerController = nil;
    [[NSFileManager defaultManager] removeItemAtPath:mzDirPlayCache error:nil];
}

//加载播放器
- (void)loadMoviePlayer{
    // 创建播放器
    moviePlayerController = [[WKMPMoviePlayerController alloc] init];
    
    moviePlayerController.movieSourceType = MPMovieSourceTypeUnknown;
    
    moviePlayerController.shouldAutoplay  = YES;
    
    moviePlayerController.controlStyle    = MPMovieControlStyleNone;
    
    [self.view addSubview:moviePlayerController.view];
    
    moviePlayerController.delegate = self;
    //加载全屏播放列表
    moviePlayerController.wkPlayerVideoList = [[WKPlayerVideoList alloc] initWithFrame:CGRectMake(mzScreenHeight, 0, 300, mzScreenWidth)];
    moviePlayerController.wkPlayerVideoList.delegate = self;
    
    [self.view addSubview:moviePlayerController.view];
    moviePlayerController.view.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerDidPlayFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerController];
    
    NSString* url = self.targetModel.url;
    
    [moviePlayerController performSelector:@selector(playVideoWithUrl:) withObject:url afterDelay:0.1];
//    moviePlayerController.wkPlayerVideoList.nowIndex = indexPath.row;
    [moviePlayerController.wkPlayerVideoList.myTabView reloadData];
    [self wkMPMoviePlayerControllerEnterFullScreen:YES];
    
}
#pragma mark - movieplayerController delegate
- (void)moviePlayerDidPlayFinish:(NSNotification*)notification{
    
    //    WKMPMoviePlayerController *moviePlayer = [notification object];
    //    NSInteger sectionListIndex = [self transformCourselistIndexToSectionListIndex:nowIndex.row];
    //    if (moviePlayer.currentPlaybackTime > 0) {
    //        if (sectionListIndex + 1 < [sectionList count]) {
    //            NSInteger courseListIndex = [self updateCourseListWithIndex:sectionListIndex];
    //            [self tableView:_tableViewSection didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:courseListIndex+1 inSection:0]];
    //        }
    //    }
}

-(void)wkMPMoviePlayerControllerClickBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)wkMPMoviePlayerControllerEnterFullScreen:(BOOL)isFullScreen{
    if (isFullScreen) {
        moviePlayerController.view.hidden = NO;
        [moviePlayerController.view.superview bringSubviewToFront:moviePlayerController.view];
    }
}


@end
