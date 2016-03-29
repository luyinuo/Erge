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
#define ADWO_FSAD_TEST_MODE             YES
#define ADWO_PUBLISH_ID_FOR_DEMO @"c3d1b7e7744a4d6283e461c23dfdcbb9"
static NSString* const adwoResponseErrorInfoList[] = {
    @"操作成功",
    @"广告初始化失败",
    @"当前广告已调用了加载接口",
    @"不该为空的参数为空",
    @"参数值非法",
    @"非法广告对象句柄",
    @"代理为空或adwoGetBaseViewController方法没实现",
    @"非法的广告对象句柄引用计数",
    @"意料之外的错误",
    @"广告请求太过频繁",
    @"广告加载失败",
    @"全屏广告已经展示过",
    @"全屏广告还没准备好来展示",
    @"全屏广告资源破损",
    @"开屏全屏广告正在请求",
    @"当前全屏已设置为自动展示",
    @"当前事件触发型广告已被禁用",
    @"没找到相应合法尺寸的事件触发型广告",
    
    @"服务器繁忙",
    @"当前没有广告",
    @"未知请求错误",
    @"PID不存在",
    @"PID未被激活",
    @"请求数据有问题",
    @"接收到的数据有问题",
    @"当前IP下广告已经投放完",
    @"当前广告都已经投放完",
    @"没有低优先级广告",
    @"开发者在Adwo官网注册的Bundle ID与当前应用的Bundle ID不一致",
    @"服务器响应出错",
    @"设备当前没连网络，或网络信号不好",
    @"请求URL出错"
};
#endif /* Constaint_h */
