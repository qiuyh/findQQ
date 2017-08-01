//
//  AppDelegate.m
//  findQQ
//
//  Created by 邱永槐 on 2017/3/14.
//  Copyright © 2017年 邱永槐. All rights reserved.
//

#import "AppDelegate.h"
#import "WebViewController.h"
#import "ViewController.h"
#import "CustomURLProtocol.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    
//    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//    NSDate *oldDate = [user objectForKey:@"date2"];
//    
//    NSDate *nowDate = [NSDate date];
//    
//    if (!oldDate) {
//        oldDate = nowDate;
//    }
//    NSTimeInterval time = [nowDate timeIntervalSinceDate:oldDate];
//    
//    NSString *skey2 = [user objectForKey:@"skey2"];
//    
//    NSLog(@"time:%f,,skey2==%@",time/60/60/24,skey2);
//    
//    NSTimeInterval oneDate = time/60/60/24;
//    
//    if (skey2 && oneDate < 1.0) {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        ViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//        self.window.rootViewController = VC;
//    }else{
        WebViewController *webVC = [[WebViewController alloc] init];
        self.window.rootViewController = webVC;
//    }
    
    
    [self.window makeKeyAndVisible];
    
    
//    //注册protocol
//    [NSURLProtocol registerClass:[CustomURLProtocol class]];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
