//
//  WKMPMoviePlayerController.m
//  MaiZiEdu
//
//  Created by terrPang on 14-9-12.
//  Copyright (c) 2014年 maiziedu. All rights reserved.
//

#import "WKMPMoviePlayerController.h"
#import "WKPlayerVolume.h"
//#import "WKConfig.h"
//#import "WKNetWork.h"
#import <AVFoundation/AVAudioSession.h>



@interface WKMPMoviePlayerController()
@property (nonatomic, strong) NSMutableArray *rateButtons;
@property (nonatomic, strong) NSMutableArray *rateArrays;
@end
@implementation WKMPMoviePlayerController{
    float x;
    float y;
    WKPlayerVolume* wkPlayerVolume;
    UIDeviceOrientation oldDeviceOrientation;//保存设备最新方向
    UIView* ydView;
    MPVolumeView *volumeView;
    //播放器的自定义控制界面
    UIView* controlsView;
    UIButton* controlsTouch;//touch板
    UIButton* controlsPlay;//播放按钮
    UIButton* controlsFullScreen;//全屏按钮
    UIView* controlsProgressAll;//总进度条
    UIView* controlsProgressCache;//缓存进度条
    UIView* controlsProgressPlay;//播放进度条
    UIButton* controlsProgressBt;//进度条调整的按钮
    UILabel* controlsTimeNow;//播放时间
    UILabel* controlsTimeAll;//视频总时间
    MPVolumeView *airPlayView;
    UIView* controlsNavBox;//播放器全屏时顶部bar
    UIButton* controlsNavBack;//bar上的返回按钮
    UILabel* controlsNavTitle;//bar上的title
    UIButton* controlsNavSecIcon;//bar上的弹出章节列表的bt
    UIView *rateBackgroundView;
    UIButton *currentRateButton;
}

- (NSMutableArray *) rateButtons
{
    if (!_rateButtons) {
        _rateButtons = [NSMutableArray array];
    }
    return _rateButtons;
}
- (NSMutableArray *)rateArrays
{
    if (!_rateArrays) {
        _rateArrays = [NSMutableArray array];
        [_rateArrays addObjectsFromArray:@[@{@"title":@"⚡️光速闪过",@"rate":@(2.5)},
                                           @{@"title":@"😫来不及了",@"rate":@(2.0)},
                                           @{@"title":@"😖宝宝尿急",@"rate":@(1.5)},
                                           @{@"title":@"正常",@"rate":@(1.0)}]];
    }
    return _rateArrays;
}
-(id)init{
    self = [super init];
    
    if (self) {
        //定时检测设备方向
        _timerUpdateState = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(deviceOri) userInfo:nil repeats:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:self];

//        [self.view setFrame:CGRectMake(0, mzIos7Later?20+44:44, mzScreenWidth, mzScreenWidth/16.00*9.00)];
        CGFloat height = mzScreenWidth/16.00*9.00;
        CGFloat width = mzScreenWidth;
        CGFloat frameX = 0;
        CGFloat frameY = (mzScreenHeight- height)/2.0;
        [self.view setFrame:CGRectMake(frameX, frameY, width, height)];
    
        //加载loading
        _viewPlayerLoading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-15, self.view.frame.size.height/2-15, 30, 30)];
        [_viewPlayerLoading setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [_viewPlayerLoading startAnimating];
        [self.view addSubview:_viewPlayerLoading];
        
        //加载错误提示框
        _lbLoadErr = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-75, self.view.frame.size.height/2-15, 150, 30)];
        [_lbLoadErr setText:@"播发失败"];
        [_lbLoadErr setHidden:YES];
        [_lbLoadErr setTextColor:mzThemeColorC2];
        [_lbLoadErr setBackgroundColor:[UIColor blackColor]];
        [_lbLoadErr setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:_lbLoadErr];
        
        //加载自定义控制器
        UIView* controlsBox = [[[NSBundle mainBundle] loadNibNamed:@"playerControls" owner:nil options:nil] objectAtIndex:0];
        [controlsBox setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
        [self.view addSubview:controlsBox];
        
        //赋值控制元素
        controlsView          = [controlsBox viewWithTag:201];
        [controlsView setHidden:YES];

        controlsPlay          = (UIButton*)[controlsBox viewWithTag:202];
        controlsFullScreen    = (UIButton*)[controlsBox viewWithTag:203];
        controlsProgressAll   = [controlsBox viewWithTag:204];
        controlsProgressCache = [controlsBox viewWithTag:205];
        controlsProgressPlay  = [controlsBox viewWithTag:206];
        controlsProgressBt    = (UIButton*)[controlsBox viewWithTag:207];
        controlsTimeNow       = (UILabel*)[controlsBox viewWithTag:208];
        controlsTimeAll       = (UILabel*)[controlsBox viewWithTag:209];
        controlsNavBox        = [controlsBox viewWithTag:211];
        controlsNavBack       = (UIButton*)[controlsBox viewWithTag:212];
        controlsNavTitle      = (UILabel*)[controlsBox viewWithTag:213];
        controlsNavSecIcon    = (UIButton*)[controlsBox viewWithTag:214];
        
        airPlayView           = (MPVolumeView*)[controlsBox viewWithTag:210];
        [airPlayView setShowsVolumeSlider:NO];
        [airPlayView sizeToFit];
        
        [controlsFullScreen addTarget:self action:@selector(clickFullScreen:) forControlEvents:UIControlEventTouchUpInside];
        [controlsPlay addTarget:self action:@selector(clickPlay) forControlEvents:UIControlEventTouchUpInside];
        [controlsNavSecIcon addTarget:self action:@selector(clickSecIcon:) forControlEvents:UIControlEventTouchUpInside];
        [controlsNavBack addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    
        [controlsProgressBt addTarget:self action:@selector(touchDragProgress:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [controlsProgressBt addTarget:self action:@selector(touchDownProgress:withEvent:) forControlEvents:UIControlEventTouchDown];
        [controlsProgressBt addTarget:self action:@selector(touchEndProgress:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [controlsProgressBt addTarget:self action:@selector(touchEndProgress:withEvent:) forControlEvents:UIControlEventTouchUpOutside];
        
        //初始化touch板
        controlsTouch = (UIButton*)[controlsBox viewWithTag:200];
        [controlsTouch addTarget:self action:@selector(touchPlayerMoved:forEvent:) forControlEvents:UIControlEventTouchDragInside];
        [controlsTouch addTarget:self action:@selector(touchPlayerBegan:forEvent:) forControlEvents:UIControlEventTouchDown];
        [controlsTouch addTarget:self action:@selector(touchPlayerEnded:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        [controlsTouch addTarget:self action:@selector(touchPlayerEnded:forEvent:) forControlEvents:UIControlEventTouchUpOutside];
        //初始化倍速
        currentRateButton = (UIButton*)[controlsBox viewWithTag:215];
        [currentRateButton addTarget:self action:@selector(showRateView) forControlEvents:UIControlEventTouchUpInside];
        [currentRateButton setTitle:@"正常" forState:UIControlStateNormal];
        rateBackgroundView = [controlsBox viewWithTag:216];
        UIButton *button1 = (UIButton*)[rateBackgroundView viewWithTag:217];
        UIButton *button2 = (UIButton*)[rateBackgroundView viewWithTag:218];
        UIButton *button3 = (UIButton*)[rateBackgroundView viewWithTag:219];
        [button1 addTarget:self action:@selector(didSelectedRate:) forControlEvents:UIControlEventTouchUpInside];
        [button2 addTarget:self action:@selector(didSelectedRate:) forControlEvents:UIControlEventTouchUpInside];
        [button3 addTarget:self action:@selector(didSelectedRate:) forControlEvents:UIControlEventTouchUpInside];
        [self.rateButtons addObject:button1];
        [self.rateButtons addObject:button2];
        [self.rateButtons addObject:button3];
        [self reloadRateButtons];
        [self hiddenRateView];
        //解决外放没有声音
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        self.isPop = NO;
    }
    
    return self;
}
- (void) reloadRateButtons{
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSDictionary *dic in self.rateArrays) {
        if (![dic[@"title"] isEqualToString:currentRateButton.currentTitle ]) {
            [tempArray addObject:dic];
        }
    }

    for (NSInteger index=0;index < 3; index++) {
        NSDictionary *dic = tempArray[index];
        UIButton *button = self.rateButtons[index];
        [button setTitle:dic[@"title"] forState:UIControlStateNormal];
    }
}
- (void) didSelectedRate:(UIButton*) sender
{
    [self hiddenRateView];
    NSInteger index = sender.tag - 217;
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSDictionary *dic in self.rateArrays) {
        if (![dic[@"title"] isEqualToString:currentRateButton.currentTitle ]) {
            [tempArray addObject:dic];
        }
    }
    [currentRateButton setTitle:tempArray[index][@"title"] forState:UIControlStateNormal];
    self.currentPlaybackRate = [tempArray[index][@"rate"] floatValue];
    [self reloadRateButtons];
}
//根据设备方向调整播放器
- (void)deviceOri{
    
    if (_isPlaying) {
        
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        
        if (UIDeviceOrientationIsLandscape(deviceOrientation) && deviceOrientation!=oldDeviceOrientation){
            
            oldDeviceOrientation = deviceOrientation;
            
            [self enterFullScreen:YES];
        }else if(deviceOrientation == UIDeviceOrientationPortrait && deviceOrientation!=oldDeviceOrientation){
            
            oldDeviceOrientation = deviceOrientation;
            
            [self enterFullScreen:NO];
        }
        
        if (!_isPop && !isnan(self.currentPlaybackTime) ) {
            float timeAll = self.duration;
            float timeNow = self.currentPlaybackTime;
            float timePlayable = self.playableDuration;
            float timeNowWidth = timeNow/timeAll*controlsProgressAll.frame.size.width;
            float timePlayableWidth = timePlayable/timeAll*controlsProgressAll.frame.size.width;
            if(self.progressOperation && self.playbackState == MPMoviePlaybackStatePlaying){
//                NSLog(@"progress------%f",timeNow/timeAll);
                self.progressOperation(timeNow/timeAll);
            }

            [controlsProgressPlay setFrame:CGRectMake(controlsProgressPlay.frame.origin.x, controlsProgressPlay.frame.origin.y, timeNowWidth, controlsProgressPlay.frame.size.height)];
            [controlsProgressCache setFrame:CGRectMake(controlsProgressCache.frame.origin.x, controlsProgressCache.frame.origin.y, timePlayableWidth, controlsProgressCache.frame.size.height)];
            if (controlsProgressBt.layer.name.length==0) {
                [controlsProgressBt setCenter:CGPointMake(controlsProgressPlay.frame.origin.x+timeNowWidth, controlsProgressBt.center.y)];
                [controlsTimeNow setText:[NSString stringWithFormat:@"%02d:%02d",(int)timeNow/60,(int)timeNow%60]];
            }
            
            if(self.playbackState & MPMoviePlaybackStatePlaying){
                [controlsPlay setSelected:YES];
            }else{
                [controlsPlay setSelected:NO];
            }
        }
    }

}

#pragma mark 播放器的通知回调

- (void) moviePlayerLoadStateDidChange:(NSNotification*)notification {
    WKMPMoviePlayerController *player = notification.object;
    MPMovieLoadState loadState = self.loadState;
    
    [_viewPlayerLoading setAlpha:0];
    _lbLoadErr.hidden = YES;
    
    if(loadState == MPMovieLoadStateUnknown){
        NSLog(@"MPMovieLoadStateUnknown");
        player.contentURL = self.contentURL;
        [player prepareToPlay];
        return;
    }
    if(loadState & MPMovieLoadStatePlayable){
        //第一次加载，或者前后拖动完成之后 /
        NSLog(@"MPMovieLoadStatePlayable");
        [controlsView setHidden:NO];
        
        [controlsTimeAll setText:[NSString stringWithFormat:@"%02d:%02d",(int)self.duration/60,(int)self.duration%60]];
        
        if (self.isPop) {
            [self stop];
        }
    }
    if(loadState & MPMovieLoadStatePlaythroughOK){
        NSLog(@"MPMovieLoadStatePlaythroughOK");
        _isPlaying = YES;
        [controlsView setHidden:NO];
    }
    if(loadState & MPMovieLoadStateStalled){
        //网络不好，开始缓冲了
        NSLog(@"MPMovieLoadStateStalled");
    }
}

- (void)enterFullScreen:(BOOL)isEnter{
    
    if (controlsFullScreen.isSelected != isEnter) {
        
        [controlsFullScreen setSelected:isEnter];
        [controlsNavBox setHidden:!isEnter];
        
        [[UIApplication sharedApplication] setStatusBarHidden:isEnter];
        
        [_delegate wkMPMoviePlayerControllerEnterFullScreen:isEnter];
        
        if (isEnter) {
            currentRateButton.hidden = NO;
            [controlsPlay setImage:[UIImage imageNamed:@"player_playS"] forState:UIControlStateNormal];
            [controlsPlay setImage:[UIImage imageNamed:@"player_pauseS"] forState:UIControlStateSelected];
            
            [UIView animateWithDuration:0.4 animations:^{
                
                [self.view setTransform:CGAffineTransformIdentity];
                
                [self.view setFrame:CGRectMake((mzScreenWidth-mzScreenHeight)/2, (mzScreenHeight-mzScreenWidth)/2-(mzIos7Later?0:20), mzScreenHeight, mzScreenWidth)];
                [self.view setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, oldDeviceOrientation == UIDeviceOrientationLandscapeLeft?M_PI_2:-M_PI_2)];
                
            } completion:^(BOOL finished) {
                
                if (!wkPlayerVolume) {
                    //加载弹出层
                    wkPlayerVolume = [[WKPlayerVolume alloc] initWithFrame:CGRectMake(mzScreenHeight/2-154/2, mzScreenWidth/2-154/2, 154, 154)];
                    [self.view addSubview:wkPlayerVolume];
                    [self.view addSubview:_wkPlayerVideoList];
                    [controlsNavTitle setText:_myTitle];
                }
                
                //加载声音控件
                volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, -1000, 100, 20)];
                [self.view addSubview:volumeView];
                
                //加载第一次进入的引导层
                BOOL isFirst = [[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLoadFullScreen"];
                if (!isFirst) {//[WKNetWork sharedNetWork].isPlayerYd
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstLoadFullScreen"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    ydView = [[[NSBundle mainBundle] loadNibNamed:@"courseInfoYd" owner:nil options:nil] objectAtIndex:0];
                    [ydView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapYdView)]];
                    ydView.frame = CGRectMake(0, 0, mzScreenHeight, mzScreenWidth);
                    [self.view addSubview:ydView];
                    
//                    [WKNetWork sharedNetWork].isPlayerYd = NO;
                }
            }];
        }else{
            
            [_wkPlayerVideoList setHidden:YES];
            [self hiddenRateView];
            currentRateButton.hidden = YES;
            
            [controlsPlay setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
            [controlsPlay setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateSelected];
            
            [UIView animateWithDuration:0.4 animations:^{
                
                [self.view setTransform:CGAffineTransformIdentity];
                CGFloat height = mzScreenWidth/16.00*9.00;
                CGFloat width = mzScreenWidth;
                CGFloat frameX = 0;
                CGFloat frameY = (mzScreenHeight- height)/2.0;
//                [self.view setFrame:CGRectMake(0, mzIos7Later?20+44:0+44, mzScreenWidth, mzScreenWidth/16.00*9.00)];
                [self.view setFrame:CGRectMake(frameX, frameY, width, height)];
                
            } completion:^(BOOL finished) {
                [volumeView removeFromSuperview];
                
                [ydView removeFromSuperview];
            }];
        }
        
        [_viewPlayerLoading setFrame:CGRectMake(self.view.frame.size.width/2-15, self.view.frame.size.height/2-15, 30, 30)];
        
    }
}

//点击视频引导页
- (void)tapYdView{
    [ydView removeFromSuperview];
}

//切换视频播放源
- (void)playVideoWithUrl:(NSString *)urlString{
    
    [_viewPlayerLoading setAlpha:1];
    [controlsView setHidden:YES];

    if ([urlString isKindOfClass:[NSString class]] && ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"])) {
        self.isPlaying = NO;
        [self stop];
        
        //查看缓存文件
        NSString *fileName = [urlString lastPathComponent];
        
        NSString* filePath = [NSString stringWithFormat:@"%@/%@", downloadFileDir,fileName];
        NSLog(@"filePath----%@",filePath);
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){ // 已经存在
            
//            NSData* videoData = [NSData dataWithContentsOfFile:filePath];
            
            //创建下载目录
//            [[NSFileManager defaultManager] createDirectoryAtPath:mzDirPlayCache withIntermediateDirectories:YES attributes:nil error:nil];
//            
//            if ([[[NSString alloc] initWithData:[videoData subdataWithRange:NSMakeRange(0, 5)] encoding:NSUTF8StringEncoding] isEqual:@"mzedu"]) {
//                [[videoData subdataWithRange:NSMakeRange(5, videoData.length-5)] writeToFile:[mzDirPlayCache stringByAppendingPathComponent:fileName] atomically:YES];
//            }
        
//            [self setContentURL:[NSURL fileURLWithPath:[mzDirPlayCache stringByAppendingPathComponent:fileName]]];
            [self setContentURL:[NSURL fileURLWithPath:filePath]];
        }else{
            /*
            if ([[WKNetWork sharedNetWork] currntNetworkType] == nil) {
                _lbLoadErr.hidden = NO;
                return;
            }else if (![[[NSUserDefaults standardUserDefaults] objectForKey:mzWwanPlay] isEqual:@"1"] && [[[WKNetWork sharedNetWork] currntNetworkType] isEqual:@"3G"]) {
                [mzLocalString(@"set_wwan_no") showRemind:YES];
                
                [self.viewPlayerLoading setAlpha:0];
            }else{
                [self setContentURL:[NSURL URLWithString:urlString]];NSLog(@"%@",urlString);
            }*/
             [self setContentURL:[NSURL URLWithString:urlString]];
            NSLog(@"%@",urlString);
        }
        [self play];
    }else{
#warning
//        [mzLocalString(@"player_url_err") showRemind:YES];
        _lbLoadErr.hidden = NO;
        [_viewPlayerLoading setAlpha:0];

    }
    
}

- (void)clickFullScreen:(UIButton *)sender{
    [self enterFullScreen:!sender.selected];
}

- (void)clickPlay{
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        [self pause];
        if ([self.delegate respondsToSelector:@selector(wkMpMoviePlayerControllerClickPause)]) {
            [self.delegate wkMpMoviePlayerControllerClickPause];
        }
    }else{
        [self play];
    }
}

- (void)clickSecIcon:(UIButton *)sender{
    
    sender.selected = !sender.isSelected;
    
    if (sender.selected) {
        [_wkPlayerVideoList showView];
        [UIView animateWithDuration:0.5 animations:^{
            controlsView.alpha = 0;
            controlsNavBox.alpha = 0;
            
        } completion:^(BOOL finished) {
            controlsView.hidden = YES;
            controlsNavBox.hidden = YES;
            
        }];
    }else{
        [_wkPlayerVideoList myHidden];
    }
}

- (void)clickBack{
    [_delegate wkMPMoviePlayerControllerClickBack];
}

- (void)touchDownProgress:(UIButton *)sender withEvent:(UIEvent *)event{
    
    if (_isPlaying) {
        
        UITouch *touch = [event.allTouches anyObject];
        CGPoint touchPoint = [touch locationInView:sender];
        
        sender.layer.name = [NSString stringWithFormat:@"%f",touchPoint.x];
    }
}

- (void)touchDragProgress:(UIButton *)sender withEvent:(UIEvent *)event{
    
    if (_isPlaying) {
        
        UITouch *touch = [event.allTouches anyObject];
        CGPoint touchPoint = [touch locationInView:sender];
        
        float oldX = [sender.layer.name floatValue];
        float nowX = touchPoint.x;
        float okX = sender.center.x+nowX-oldX;

        okX = MAX(okX, controlsProgressAll.frame.origin.x);
        okX = MIN(okX, controlsProgressAll.frame.origin.x+controlsProgressAll.frame.size.width);
        
        [sender setCenter:CGPointMake(okX, sender.center.y)];
        
        float timeAll = self.duration;
        float timeNow = (sender.center.x-controlsProgressAll.frame.origin.x)/controlsProgressAll.frame.size.width*timeAll;
        
        [controlsTimeNow setText:[NSString stringWithFormat:@"%02d:%02d",(int)timeNow/60,(int)timeNow%60]];
    }
}

- (void)touchEndProgress:(UIButton *)sender withEvent:(UIEvent *)event{
    
    if (_isPlaying) {
        
        float timeAll = self.duration;
        float timeNow = (sender.center.x-controlsProgressAll.frame.origin.x)/controlsProgressAll.frame.size.width*timeAll;
        
        [self setCurrentPlaybackTime:timeNow];
        
        sender.layer.name = @"";
    }
}

#pragma mark 获取touch坐标来做手势操作

- (void)touchPlayerMoved:(UIButton *)sender forEvent:(UIEvent *)event{
    
    if (controlsFullScreen.selected) {
        UITouch *touch = [event.allTouches anyObject];
        CGPoint touchPoint = [touch locationInView:sender];
        
        float nowX = touchPoint.x;
        float nowY = touchPoint.y;
        
        //向下滑
        if ((nowY - y) >= 10 && fabsf(nowX - x) <= 40 && (wkPlayerVolume.playerTouchState == mzPlayerTouchStateNone || wkPlayerVolume.playerTouchState == mzPlayerTouchStateUpDown) ){
            
            if (nowX > sender.frame.size.width/2) {
                //减小音量
                MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
                if ((mpc.volume - 0.1) <= 0){
                    mpc.volume = 0;
                }else{
                    mpc.volume = mpc.volume - 0.05;
                }
                
                [wkPlayerVolume showView:mzPlayerWithVolume withValue:mpc.volume];
            }else{
                //调低亮度
                for (int i=0; i<10; i++) {
                    float nowBright = [UIScreen mainScreen].brightness;
                    if (nowBright - 0.01 <=0) {
                        nowBright = 0;
                    }else{
                        nowBright-=0.01;
                    }
                    [[UIScreen mainScreen] setBrightness:nowBright];
                }
                [wkPlayerVolume showView:mzPlayerWithLight withValue:[UIScreen mainScreen].brightness];
            }
            
            y = nowY;
            
            wkPlayerVolume.playerTouchState = mzPlayerTouchStateUpDown;
            
        }else if ((y - nowY) >= 10 && fabsf(nowX - x) <= 40 && (wkPlayerVolume.playerTouchState == mzPlayerTouchStateNone || wkPlayerVolume.playerTouchState == mzPlayerTouchStateUpDown) ){//向上滑
            
            if (nowX > sender.frame.size.width/2) {
                //加大音量
                MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
                if ((mpc.volume + 0.1) >= 1){
                    mpc.volume = 1;
                }else{
                    mpc.volume = mpc.volume + 0.05;
                }
                
                [wkPlayerVolume showView:mzPlayerWithVolume withValue:mpc.volume];
            }else{
                //调高亮度
                for (int i=0; i<10; i++) {
                    float nowBright = [UIScreen mainScreen].brightness;
                    if (nowBright + 0.01 >=1) {
                        nowBright = 1;
                    }else{
                        nowBright+=0.01;
                    }
                    [[UIScreen mainScreen] setBrightness:nowBright];
                }
                [wkPlayerVolume showView:mzPlayerWithLight withValue:[UIScreen mainScreen].brightness];
            }
            
            y = nowY;
            
            wkPlayerVolume.playerTouchState = mzPlayerTouchStateUpDown;
            
        }else if ((nowX - x) >= 10 && fabsf(nowY - y) <= 30 && (wkPlayerVolume.playerTouchState == mzPlayerTouchStateNone || wkPlayerVolume.playerTouchState == mzPlayerTouchStateGoBack) ){//快进
            
            wkPlayerVolume.goPlaybackTime+=10;
            [wkPlayerVolume showView:mzPlayerWithQuickGo withValue:wkPlayerVolume.goPlaybackTime];
            wkPlayerVolume.goBackState = mzPlayerGo;
            
            x = nowX;
            wkPlayerVolume.playerTouchState = mzPlayerTouchStateGoBack;
            
        }else if ((x - nowX) >= 10 && fabsf(nowY - y) <= 30 && (wkPlayerVolume.playerTouchState == mzPlayerTouchStateNone || wkPlayerVolume.playerTouchState == mzPlayerTouchStateGoBack) ){//快退
            
            wkPlayerVolume.goPlaybackTime-=10;
            [wkPlayerVolume showView:mzPlayerWithQuickBack withValue:wkPlayerVolume.goPlaybackTime];
            wkPlayerVolume.goBackState = mzPlayerBack;
            
            x = nowX;
            wkPlayerVolume.playerTouchState = mzPlayerTouchStateGoBack;
        }
    }
}

- (void)touchPlayerBegan:(UIButton *)sender forEvent:(UIEvent *)event{
    
    UITouch *touch = [event.allTouches anyObject];
    CGPoint touchPoint = [touch locationInView:sender];
    
    x = touchPoint.x;
    y = touchPoint.y;
    
    if (controlsFullScreen.selected){
        wkPlayerVolume.allTime = self.duration;
        wkPlayerVolume.goPlaybackTime = self.currentPlaybackTime;
        wkPlayerVolume.goBackState = mzPlayerNone;
        wkPlayerVolume.playerTouchState = mzPlayerTouchStateNone;
    }
}

- (void)touchPlayerEnded:(UIButton *)sender forEvent:(UIEvent *)event{
    
    UITouch *touch = [event.allTouches anyObject];
    CGPoint touchPoint = [touch locationInView:sender];
    
    float nowX = touchPoint.x;
    float nowY = touchPoint.y;
    
    if (controlsFullScreen.selected && wkPlayerVolume.goBackState != mzPlayerNone) {
        [self setCurrentPlaybackTime:wkPlayerVolume.goPlaybackTime];
    }

    if (fabsf(nowX-x) < 10 && fabsf(nowY-y) < 10) {
        
        if (controlsView.hidden) {
            
            if (controlsNavSecIcon.selected) {
                [_wkPlayerVideoList myHidden];
                [controlsNavSecIcon setSelected:NO];
            }else{
                controlsView.alpha = 0;
                controlsView.hidden = NO;
                if (controlsFullScreen.selected) {
                    controlsNavBox.alpha = 0;
                    controlsNavBox.hidden = NO;
                }
                
                [UIView animateWithDuration:0.5 animations:^{
                    controlsView.alpha = 1;
                    if (controlsFullScreen.selected) {
                        controlsNavBox.alpha = 1;
                    }
                } completion:^(BOOL finished) {
                    
                }];
            }

        }else{
            //隐藏修改播放速度view
            [self hiddenRateView];
            [UIView animateWithDuration:0.5 animations:^{
                controlsView.alpha = 0;
                controlsNavBox.alpha = 0;

            } completion:^(BOOL finished) {
                controlsView.hidden = YES;
                controlsNavBox.hidden = YES;
            
            }];
            if (controlsFullScreen.selected) {
                [_wkPlayerVideoList myHidden];
                [controlsNavSecIcon setSelected:NO];
            }
        }
    }
}
- (void) hiddenRateView
{
    rateBackgroundView.hidden = YES;
}
- (void) showRateView
{
    if (rateBackgroundView.hidden == YES) {
        rateBackgroundView.hidden = NO;
    }
    
}
@end
