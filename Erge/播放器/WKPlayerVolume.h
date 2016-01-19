//
//  WKPlayerVolume.h
//  MaiZiEdu
//
//  Created by terrorPang on 14-8-17.
//  Copyright (c) 2014年 maiziedu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    mzPlayerWithVolume,
    mzPlayerWithLight,
    mzPlayerWithQuickGo,
    mzPlayerWithQuickBack
} mzPlayerShow;

typedef enum : int {
    mzPlayerGo,
    mzPlayerBack,
    mzPlayerNone
} mzPlayerGoOrBack;

typedef enum : int {
    mzPlayerTouchStateUpDown,
    mzPlayerTouchStateGoBack,
    mzPlayerTouchStateNone
} mzPlayerTouchState;

@interface WKPlayerVolume : UIView

@property (nonatomic) NSTimeInterval allTime;
@property (nonatomic) NSTimeInterval goPlaybackTime;
@property (nonatomic) mzPlayerGoOrBack goBackState;
@property (nonatomic) mzPlayerTouchState playerTouchState;

- (void)showView:(mzPlayerShow)theView withValue:(float)value;

@end
