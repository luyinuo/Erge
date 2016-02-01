//
//  NSFileManager+Extension.m
//  MaiZiEduLPS
//
//  Created by Maiziedu on 15/10/13.
//  Copyright (c) 2015年 maiziedu. All rights reserved.
//

#import "NSFileManager+Extension.h"

@implementation NSFileManager (Extension)


//总容量
+ (NSNumber *)totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

//可用容量
+ (NSNumber *)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

@end
