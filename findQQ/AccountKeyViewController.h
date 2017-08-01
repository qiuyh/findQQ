//
//  AccountKeyViewController.h
//  findQQ
//
//  Created by iMacQIU on 2017/5/5.
//  Copyright © 2017年 邱永槐. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GetAccountAndKeys)(NSArray *accountsArray,NSArray *keysArray);

@interface AccountKeyViewController : UIViewController

@property (nonatomic,copy) GetAccountAndKeys block;

- (void)setBlock:(GetAccountAndKeys)block;


@end
