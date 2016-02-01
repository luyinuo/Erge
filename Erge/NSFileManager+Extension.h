//
//  NSFileManager+Extension.h
//  MaiZiEduLPS
//
//  Created by Maiziedu on 15/10/13.
//  Copyright (c) 2015年 maiziedu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Extension)
//总容量
+ (NSNumber *)totalDiskSpace;
//可用容量
+ (NSNumber *)freeDiskSpace;
@end
