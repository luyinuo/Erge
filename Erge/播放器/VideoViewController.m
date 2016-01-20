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

@end

@implementation VideoViewController{
    
    WKMPMoviePlayerController *moviePlayerController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadMoviePlayer];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
    
    NSString* url = @"http://res2.lefun.net.cn/nnm/res/nnm1.mp4";//model.url;
    
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
