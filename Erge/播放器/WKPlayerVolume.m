//
//  WKPlayerVolume.m
//  MaiZiEdu
//
//  Created by terrorPang on 14-8-17.
//  Copyright (c) 2014年 maiziedu. All rights reserved.
//

#import "WKPlayerVolume.h"

@implementation WKPlayerVolume{
    NSTimer* hideViewTime;
    UIImageView* volumeIm;
    UIImageView* lightIm;
    UIImageView* quickIm;
    UILabel* titleLb;
    UIView* valueView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        titleLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 30)];
        [titleLb setBackgroundColor:[UIColor clearColor]];
        [titleLb setText:@"音量"];
        [titleLb setFont:[UIFont systemFontOfSize:16]];
        [titleLb setTextColor:[UIColor whiteColor]];
        [titleLb setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:titleLb];
        
        volumeIm = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2.0-75.0/2.0, 55, 75, 63)];
        [volumeIm setImage:[UIImage imageNamed:@"courseInfo_volume"]];
        volumeIm.hidden = YES;
        [self addSubview:volumeIm];
        
        lightIm = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2.0-71.0/2.0, 51, 71, 71)];
        [lightIm setImage:[UIImage imageNamed:@"courseInfo_light"]];
        [self addSubview:lightIm];
        
        quickIm = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2.0-67.0/2.0, 68, 67, 53)];
        [quickIm setImage:[UIImage imageNamed:@"courseInfo_quickGo"]];
        [self addSubview:quickIm];
        
        valueView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width/2.0-129.0/2.0, 135, 129, 8)];
        valueView.backgroundColor = [UIColor clearColor];
//        valueView.layer.borderColor = [[UIColor whiteColor] CGColor];
//        valueView.layer.borderWidth = 0.5;
        
        for (int i=0; i<16; i++) {
            UIView* valueViewItem = [[UIView alloc] initWithFrame:CGRectMake(1+i*8, 1, 7, 6)];
            valueViewItem.tag = i+1;
            [valueViewItem setBackgroundColor:[UIColor whiteColor]];
            [valueView addSubview:valueViewItem];
        }
        
        [self addSubview:valueView];
        
        self.alpha = 0;
        self.hidden = YES;
        self.userInteractionEnabled = NO;
    }
    return self;
}

-(void)showView:(mzPlayerShow)theView withValue:(float)value{
    
    if (theView == mzPlayerWithVolume || theView == mzPlayerWithLight) {
        
        quickIm.hidden = YES;
        valueView.hidden = NO;
        [titleLb setFrame:CGRectMake(0, 10, self.frame.size.width, 30)];
        
        if (theView == mzPlayerWithVolume) {
            volumeIm.hidden = NO;
            lightIm.hidden = YES;
            titleLb.text = @"音量";
        }else{
            volumeIm.hidden = YES;
            lightIm.hidden = NO;
            titleLb.text = @"亮度";
        }
        
        int index = value*16;
        
        for (int i=0; i<16; i++) {
            [[valueView viewWithTag:i+1] setHidden:i<index?NO:YES];
        }
        
    }else{
        
        quickIm.hidden = NO;
        volumeIm.hidden = YES;
        lightIm.hidden = YES;
        valueView.hidden = YES;
        [titleLb setFrame:CGRectMake(0, 20, self.frame.size.width, 30)];

        if (value > _allTime) {
            value = _allTime;
        }
        if (value < 0) {
            value = 0;
        }
        _goPlaybackTime = value;
        if (theView == mzPlayerWithQuickGo) {
            [quickIm setImage:[UIImage imageNamed:@"courseInfo_quickGo"]];
            titleLb.text = [NSString stringWithFormat:@"快进%02d:%02d/%02d:%02d",(int)value/60,(int)value%60,(int)_allTime/60,(int)_allTime%60];
        }else{
            [quickIm setImage:[UIImage imageNamed:@"courseInfo_quickBack"]];
            titleLb.text = [NSString stringWithFormat:@"快退%02d:%02d/%02d:%02d",(int)value/60,(int)value%60,(int)_allTime/60,(int)_allTime%60];
        }
    }
    
    self.alpha = 1;
    self.hidden = NO;
    
    if (hideViewTime) {
        [hideViewTime invalidate];
    }
    hideViewTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(myHidden) userInfo:nil repeats:NO];
}

-(void)myHidden{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0;
    }];
    
}

@end
