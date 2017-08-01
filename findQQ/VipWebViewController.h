//
//  VipWebViewController.h
//  findQQ
//
//  Created by iMacQIU on 2017/4/18.
//  Copyright © 2017年 邱永槐. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VipWebViewController : UIViewController

@property (nonatomic,copy) NSString *num;
@property (nonatomic,copy) NSString *phone;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,copy) NSString *authString;

@property (nonatomic,assign) BOOL isFromCache;//判断是否点击先缓存数据进来的，如果是，就不请求验证码，直接返回

@end
