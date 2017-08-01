//
//  QYHNextViewController.h
//  findQQ
//
//  Created by iMacQIU on 2017/4/10.
//  Copyright © 2017年 邱永槐. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYHNextViewController : UIViewController

@property (nonatomic,copy) NSString *dataString;
@property (nonatomic,copy) NSString *skey;
@property (nonatomic,copy) NSString *ouin;


@property (nonatomic,assign) BOOL isNeedRereshAuth;//是否要刷新验证码

@property (nonatomic,assign) BOOL isSecond;//判断第二次进来

@end
