
//
//  Userinfo.m
//  findQQ
//
//  Created by 邱永槐 on 2017/4/16.
//  Copyright © 2017年 邱永槐. All rights reserved.
//

#import "Userinfo.h"

@implementation Userinfo

static Userinfo *user = nil;
+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[Userinfo alloc] init];
    });
    
    return user;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _skeyArray = [NSMutableArray array];
        _index = 0;
        
        _resultArrM = [NSMutableArray array];
    }
    return self;
}



@end
