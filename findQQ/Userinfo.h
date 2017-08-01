//
//  Userinfo.h
//  findQQ
//
//  Created by 邱永槐 on 2017/4/16.
//  Copyright © 2017年 邱永槐. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Userinfo : NSObject

@property (nonatomic,assign) NSInteger index;
@property (nonatomic,strong) NSMutableArray *skeyArray;//[{skey2:value,uin2:value}]

@property (nonatomic,strong) NSMutableArray *resultArrM;//抢到的qq

@property (nonatomic,strong) NSArray *cookiesArray;

+ (instancetype)shareInstance;

@end
