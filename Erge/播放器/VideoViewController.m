//
//  VideoViewController.m
//  Erge
//
//  Created by Maiziedu on 16/1/20.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "VideoViewController.h"
#import "WKMPMoviePlayerController.h"
#import "NSString+Remind.h"

@interface VideoViewController ()<WKMPMoviePlayerControllerDelegate,WKPlayerVideoListDelegate>
@property (nonatomic, strong) NSMutableDictionary *downloadDic;
@end

@implementation VideoViewController{
    
    WKMPMoviePlayerController *moviePlayerController;
}

- (NSMutableDictionary *) downloadDic
{
    _downloadDic = [[NSMutableDictionary alloc] initWithContentsOfFile:downloadPlistPath];
    if (!_downloadDic) {
        _downloadDic = [NSMutableDictionary dictionary];
    }
    return _downloadDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadMoviePlayer];//[UIColor colorWithRed:131/255.0 green:190/255.0 blue:240/255.0 alpha:1]
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 20, 50, 44);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    [backBtn addTarget:self action:@selector(tapBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadBtn.frame = CGRectMake(90, 20, 70, 44);
    [downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
    [downloadBtn setTitle:@"已下载" forState:UIControlStateDisabled];
    NSMutableDictionary *downloadDic = [NSMutableDictionary dictionaryWithContentsOfFile:downloadPlistPath];
    NSArray *allKeys = [downloadDic allKeys];
    for (NSString *key in allKeys) {
        if ([key isEqualToString:[self.targetModel.identity stringValue]]) {
            downloadBtn.enabled = NO;
            break;
        }
    }
    [self.view addSubview:downloadBtn];
    [downloadBtn addTarget:self action:@selector(clickDownload:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
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

- (void) clickDownload:(UIButton*)sender
{
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    [tempDic setObject:self.targetModel.url forKey:@"url"];
    [tempDic setObject:self.targetModel.name forKey:@"name"];
    [tempDic setObject:self.targetModel.avatar forKey:@"avatar"];
    [tempDic setObject:self.targetModel.identity forKey:@"id"];
    [tempDic setObject:@(DownloadStatusWait) forKey:@"status"];
    [tempDic setObject:@0 forKey:@"percent"];
    [self.downloadDic setObject:tempDic forKey:[self.targetModel.identity stringValue]];
    //下载列表写入文件
    if (![[NSFileManager defaultManager] isExecutableFileAtPath:downloadFileDir]) {
        NSLog(@"该路径文件不可执行...........");
    }
    Config *config = [Config sharedConfig];
    NSLog(@"%@",downloadPlistPath);
    BOOL result = [_downloadDic writeToFile:downloadPlistPath atomically:YES];
    if (result) {
        NSLog(@"写入数据成功");
    }
    [config startDownloadProcessWithPause:NO];
    sender.enabled = NO;
    [@"下载成功,请到个人中心我的下载查看" showRemind:nil];
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
