//
//  Constaint.h
//  Erge
//
//  Created by Maiziedu on 16/3/8.
//  Copyright © 2016年 com.lyn. All rights reserved.
//

#import "AppDelegate.h"
#ifndef Constaint_h
#define Constaint_h

#define version_no 1
//审核期间关闭当前审核版本的下载功能
#define isHideDownload ([((AppDelegate *)[UIApplication sharedApplication].delegate).versionNo integerValue] == version_no && ((AppDelegate *)[UIApplication sharedApplication].delegate).isOnChecking)
#define kIdentifyForADIAP @"com.lyn.ergerAdIap"
#define kVIP @"isVIP"
#define mogoId @"310533ed086343ee8b4aa996d456605c"
#define kAnwoID @"c3d1b7e7744a4d6283e461c23dfdcbb9"
#endif /* Constaint_h */
