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

#endif /* Constaint_h */
