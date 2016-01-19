//
//  WKMPMoviePlayerController.h
//  MaiZiEdu
//
//  Created by terrPang on 14-9-12.
//  Copyright (c) 2014年 maiziedu. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "WKPlayerVideoList.h"

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
