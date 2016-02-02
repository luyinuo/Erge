//
//  Config.m
//  Erge
//
//  Created by Maiziedu on 16/1/28.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "Config.h"
#import <sys/xattr.h>
#import <UIKit/UIKit.h>
#import "NSFileManager+Extension.h"
@interface Config()<NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSURLConnection *myConnection;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) unsigned long long downloadLength;
@property (nonatomic, assign) unsigned long long cacheCapacity;
@property (nonatomic, assign) unsigned long long expectedLength;
@property (nonatomic, strong) NSFileHandle *fileHanlder;
@property (nonatomic, strong) NSMutableData *cacheData;
@property (nonatomic, assign) NSInteger percent;
@end

@implementation Config

+ (Config *) sharedConfig
{
    static Config *config = nil;
    @synchronized(self){
        if (!config) {
            config = [[Config alloc] init];
            //创建下载目录
            BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:downloadFileDir withIntermediateDirectories:YES attributes:nil error:nil];
            if (result) {
                NSLog(@"创建文件夹成功");
            }else{
                NSLog(@"创建文件夹失败");
            }
//            BOOL res = [[NSFileManager defaultManager] createFileAtPath:downloadPlistPath contents:nil attributes:nil];
//            if (res) {
//                NSLog(@"创建文件成功");
//            }else{
//                NSLog(@"创建文件失败");
//            } 
            [config addSkipBackupAttributeToPath:downloadFileDir];
        }
        return config;
    }
}

- (void) startDownloadProcessWithPause:(BOOL)isPause
{
    if(self.myConnection){
        if (self.cacheData.length != 0) {
            //移动到文件尾部
            [self.fileHanlder seekToEndOfFile];
            //写入文件
            [self.fileHanlder writeData:self.cacheData];
            //清空缓存空间
            [self.cacheData setLength:0];
        }
        [self.myConnection cancel];
    }
    if (self.currentProcessId.length == 0) {
        
        NSMutableDictionary *downloadDic  = [NSMutableDictionary dictionaryWithContentsOfFile:downloadPlistPath];
        NSArray *allKeys = [downloadDic allKeys];
        NSArray *sortKeys = [allKeys sortedArrayUsingFunction:comparator context:NULL];
        for (NSString *key in sortKeys) {
            NSMutableDictionary *item = downloadDic[key];
            if ([item[@"status"] integerValue] == DownloadStatusWait) {
                [item setObject:@(DownloadStatusIng) forKey:@"status"];
                [downloadDic setObject:item forKey:key];
                [downloadDic writeToFile:downloadPlistPath atomically:YES];
                self.currentProcessId = key;
                [self startDownloadWithUrl:item[@"url"]];
                break;
            }
        }
    }else{
        NSMutableDictionary *downloadDic  = [NSMutableDictionary dictionaryWithContentsOfFile:downloadPlistPath];
        NSMutableDictionary *currentItem = [downloadDic objectForKey:self.currentProcessId];
        NSNumber *status = isPause?@(DownloadStatusPause):@(DownloadStatusWait);
        [currentItem setObject:status forKey:@"status"];
        [downloadDic setObject:currentItem forKey:self.currentProcessId];
        NSArray *allKeys = [downloadDic allKeys];
        NSArray *sortKeys = [allKeys sortedArrayUsingFunction:comparator context:NULL];
       
        for (NSString *key in sortKeys) {
            NSMutableDictionary *item = downloadDic[key];
            if ([item[@"status"] integerValue] == DownloadStatusWait) {
                [item setObject:@(DownloadStatusIng) forKey:@"status"];
                [downloadDic setObject:item forKey:key];
                [downloadDic writeToFile:downloadPlistPath atomically:YES];
                self.currentProcessId = key;
                [self startDownloadWithUrl:item[@"url"]];
                break;
            }
        }

    }
}
- (void) startDownloadWithProccessId:(NSString *)processId
{
    if (self.currentProcessId != processId) {
        if (self.cacheData.length != 0) {
            //移动到文件尾部
            [self.fileHanlder seekToEndOfFile];
            //写入文件
            [self.fileHanlder writeData:self.cacheData];
            //清空缓存空间
            [self.cacheData setLength:0];
        }
        NSMutableDictionary *downloadDic  = [NSMutableDictionary dictionaryWithContentsOfFile:downloadPlistPath];
        if(self.currentProcessId.length > 0){
            NSMutableDictionary *currentItem = [downloadDic objectForKey:self.currentProcessId];
            [currentItem setObject:@(DownloadStatusPause) forKey:@"status"];
            [downloadDic setObject:currentItem forKey:self.currentProcessId];
        }
        NSMutableDictionary *targetItem = [downloadDic objectForKey:processId];
        [targetItem setObject:@(DownloadStatusIng) forKey:@"status"];
        [downloadDic setObject:targetItem forKey:processId];
        [downloadDic writeToFile:downloadPlistPath atomically:YES];
        self.currentProcessId = processId;
        [self startDownloadWithUrl:targetItem[@"url"]];
    }
}
/**
 *  排序
 *
 *  @param obj1
 *  @param obj2
 *  @param context
 *
 *  @return
 */
NSInteger comparator(id obj1, id obj2, void *context){
    if ([obj1 integerValue] < [obj2 integerValue]) {
        return NSOrderedAscending;
    }else if ([obj1 integerValue] > [obj2 integerValue]) {
        return NSOrderedDescending;
    }else{
        return NSOrderedSame;
    }
}

- (void) startDownloadWithUrl:(NSString *) url
{
    if(self.myConnection){
        [self.myConnection cancel];
    }
    NSString *fileName = [url lastPathComponent];
    self.filePath = [downloadFileDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.tep",fileName]];
    //记录文件起始位置
    unsigned long long from = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        from = [NSData dataWithContentsOfFile:self.filePath].length;
    }else{
        [[NSFileManager defaultManager] createFileAtPath:self.filePath contents:nil attributes:nil];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *rangeValue = [NSString stringWithFormat:@"bytes=%llu-",from];
    [request addValue:rangeValue forHTTPHeaderField:@"Range"];
    self.downloadLength = from;
    //缓存大小
    self.cacheCapacity = 512 * 1024;
    self.myConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    [self.myConnection start];
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.expectedLength = response.expectedContentLength + self.downloadLength;
    self.fileHanlder  = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
    self.cacheData = [NSMutableData data];
    self.percent = 0;
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.downloadLength += data.length;
    //保存数据
    [self.cacheData appendData:data];
    if (self.cacheData.length >= self.cacheCapacity) {
        //移动到文件尾部
        [self.fileHanlder seekToEndOfFile];
        //检查内存是否小于200M
        if (![self checkFreeSpaceIsEnough]) return;
        [self.fileHanlder writeData:self.cacheData];
        //清空缓存数据
        [self.cacheData setLength:0];
    }
    int percent = 100 * (double)self.downloadLength / (double)self.expectedLength;
    if (self.percent != percent) {
        self.percent = percent;
        NSLog(@"downloading...%i",percent);
        NSMutableDictionary *downloadDic = [NSMutableDictionary dictionaryWithContentsOfFile:downloadPlistPath];
        NSMutableDictionary *itemDic = downloadDic[self.currentProcessId];
        [itemDic setObject:@(percent) forKey:@"percent"];
        [downloadDic setObject:itemDic forKey:self.currentProcessId];
        [downloadDic writeToFile:downloadPlistPath atomically:YES];
        //通知代理 percent改变
        if ([self.delegate respondsToSelector:@selector(downloadFileManagerDidChangePercent)]) {
            [self.delegate downloadFileManagerDidChangePercent];
        }
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSMutableDictionary *downloadDic = [NSMutableDictionary dictionaryWithContentsOfFile:downloadPlistPath];
    NSMutableDictionary *itemDic = [downloadDic[self.currentProcessId] mutableCopy];
    [itemDic setObject:@(DownloadStatusOK) forKey:@"status"];
    [downloadDic setObject:itemDic forKey:self.currentProcessId];
    [downloadDic writeToFile:downloadPlistPath atomically:YES];
    //移动到文件结尾
    [self.fileHanlder seekToEndOfFile];
    //写入文件
    [self.fileHanlder writeData:self.cacheData];
    //清空数据
    [self.cacheData setLength:0];
    //关闭文件操作
    [self.fileHanlder closeFile];
    
    //文件更名
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        [[NSFileManager defaultManager] moveItemAtPath:self.filePath toPath:[self.filePath substringToIndex:self.filePath.length-4] error:nil];
    }
    NSLog(@"下载完成");
    //通知代理 下载完成
    if ([self.delegate respondsToSelector:@selector(downloadFileManagerDidFinished)]) {
        [self.delegate downloadFileManagerDidFinished];
    }
    self.currentProcessId = @"";
    [self startDownloadProcessWithPause:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.cacheData.length != 0) {
        //移动到文件尾部
        [self.fileHanlder seekToEndOfFile];
        //写入文件
        [self.fileHanlder writeData:self.cacheData];
        //清空缓存空间
        [self.cacheData setLength:0];
    }
    //关闭文件操作
    [self.fileHanlder closeFile];
    NSLog(@"网络加载失败");
    self.currentProcessId = @"";
    //通知代理
    if ([self.delegate respondsToSelector:@selector(downloadFileManagerDidChangeSatus)]) {
        [self.delegate downloadFileManagerDidChangeSatus];
    }
}

/**
 *  检查剩余储存空间
 */
- (BOOL) checkFreeSpaceIsEnough
{
    float freeSize = [[NSFileManager freeDiskSpace] doubleValue]/1024.0/1024.0;
    if (freeSize < 200) {//小于200M
        if (self.myConnection) {
            [self.myConnection cancel];
            NSMutableDictionary* downloadFileDic = [[NSMutableDictionary alloc] initWithContentsOfFile:downloadPlistPath];
            NSMutableDictionary* sectionDic = [NSMutableDictionary dictionaryWithDictionary:[downloadFileDic objectForKey:self.currentProcessId]];
            [sectionDic setObject:@(DownloadStatusIng)forKey:@"status"];
            [downloadFileDic setObject:sectionDic forKey:self.currentProcessId];
            [downloadFileDic writeToFile:downloadPlistPath atomically:YES];
            self.currentProcessId = @"";
            //通知代理
            if ([self.delegate respondsToSelector:@selector(downloadFileManagerDidChangeSatus)]) {
                [self.delegate downloadFileManagerDidChangeSatus];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"离线暂停" message:@"容器空间已不足200M,为保护您的设备已为您自动暂停,请清理后继续" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        return NO;
    }
    return YES;
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
- (void) dealloc
{
    NSLog(@"config ... delloc...");
    if (self.myConnection) {
        [self.myConnection cancel];
    }
}
@end
