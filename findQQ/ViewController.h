//
//  ViewController.h
//  findQQ
//
//  Created by 邱永槐 on 2017/3/14.
//  Copyright © 2017年 邱永槐. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GetText)(NSString *dataString);

@interface ViewController : UIViewController

@property (nonatomic,copy) NSString *skey;
@property (nonatomic,copy) NSString *uin;

@property (nonatomic,copy) GetText block;

- (void)setBlock:(GetText)block;

@end

