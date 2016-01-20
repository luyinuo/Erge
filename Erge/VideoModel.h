//
//  VideoModel.h
//  Erge
//
//  Created by Maiziedu on 16/1/20.
//  Copyright (c) 2016年 com.lyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSNumber *identity;
+ (id) modelWithDic:(NSDictionary *) dic;
- (id) initWithDic:(NSDictionary *) dic;
@end
