//
//  Config.h
//  Erge
//
//  Created by Maiziedu on 16/1/28.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import <Foundation/Foundation.h>
#define downloadPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"downloads/downloads.plist"]
//视频下载目录
#define downloadFileDir [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"downloads"]
@interface Config : NSObject

+ (Config*) sharedConfig;
@end
