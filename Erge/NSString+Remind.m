//
//  NSString+Remind.m
//  Erge
//
//  Created by Maiziedu on 16/2/16.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "NSString+Remind.h"
#import "Config.h"
#define remindTag 1616


@implementation NSString (Remind)

- (void) showRemind:(void(^)())complete
{
    UIView *hubView = [[[[UIApplication sharedApplication] delegate] window] viewWithTag:remindTag];
    if (!hubView) {
        hubView = [[[NSBundle mainBundle] loadNibNamed:@"Remind" owner:nil options:nil] firstObject];
        hubView.tag = remindTag;
        hubView.hidden = YES;
        hubView.frame = CGRectMake(0, -hubView.frame.size.height,ScreenWidth, hubView.frame.size.height);
        [[[[UIApplication sharedApplication] delegate] window] addSubview:hubView];
    }
    UILabel *messageLabel = (UILabel*)[hubView viewWithTag:3];
    messageLabel.text = self;
    if (hubView.isHidden) {
        hubView.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            [hubView setFrame:CGRectMake(0, 0, ScreenWidth, hubView.frame.size.height)];
        } completion:^(BOOL finished) {
            [self performSelector:@selector(hiddenView:) withObject:complete afterDelay:1];
        }];
    }
    
}
- (void) hiddenView:(void(^)()) complete
{
    UIView *view = [[[[UIApplication sharedApplication] delegate] window] viewWithTag:remindTag];
    [UIView animateWithDuration:0.5 animations:^{
        view.frame = CGRectMake(0, -view.frame.size.height,ScreenWidth, view.frame.size.height);
    } completion:^(BOOL finished) {
        view.hidden = YES;
        if (complete) {
            complete();
        }
    }];
    
}
@end
