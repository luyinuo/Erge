//
//  NSString+Remind.h
//  Erge
//
//  Created by Maiziedu on 16/2/16.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Remind)

- (void) showRemind:(void(^)())complete;
@end
