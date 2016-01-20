//
//  VideoModel.m
//  Erge
//
//  Created by Maiziedu on 16/1/20.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import "VideoModel.h"

@implementation VideoModel

- (id) initWithDic:(NSDictionary *) dic
{
    self = [super init];
    if (self) {
        self.name = dic[@"name"];
        self.avatar = dic[@"avatar"];
        self.url = dic[@"url"];
        self.identity = dic[@"identity"];
    }
    return self;
}

+ (id) modelWithDic:(NSDictionary *)dic
{
   return [[self alloc] initWithDic:dic];
}
@end
