//
//  Config.m
//  Erge
//
//  Created by Maiziedu on 16/1/28.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "Config.h"
#import <sys/xattr.h>

@implementation Config

+ (Config *) sharedConfig
{
    static Config *config = nil;
    @synchronized(self){
        if (!config) {
            config = [[Config alloc] init];
            //创建下载目录
            [[NSFileManager defaultManager] createDirectoryAtPath:downloadFileDir withIntermediateDirectories:YES attributes:nil error:nil];
            [config addSkipBackupAttributeToPath:downloadFileDir];
        }
        return config;
    }
}

/**
 *  设置该目录和该目录包含的所有文件和文件夹不被icloud和itunes同步
 *
 *  @param path 路径
 */
- (void)addSkipBackupAttributeToPath:(NSString*)path {
    u_int8_t b = 1;
    setxattr([path fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
}
@end
