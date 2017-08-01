//
//  WebViewController.m
//  findQQ
//
//  Created by iMacQIU on 2017/4/14.
//  Copyright © 2017年 邱永槐. All rights reserved.
//

#import "WebViewController.h"
//#import "ViewController.h"
#import "Userinfo.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "QYHProgressHUD.h"
#import "QYHNextViewController.h"
#import "LoginInfoViewController.h"
#import "AccountKeyViewController.h"

@interface WebViewController ()<UIWebViewDelegate>
{
    UIWebView *_webView;//可以加载网页数据的View
}

@property (nonatomic,copy) NSString *url;

@property (nonatomic,strong) JSContext *context;

@property (nonatomic,assign) BOOL isloginNewAccount;//判断是否点击了登陆新账号

@property (nonatomic,assign) NSInteger didLoadCount;//判断是否运行几次

@property (nonatomic,strong) NSArray *accoutsArray;
@property (nonatomic,strong) NSArray *keysArray;
@property (nonatomic,assign) NSInteger index;


@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.url = @"http://id.qq.com/index.html";
    self.url = @"https://ui.ptlogin2.qq.com/cgi-bin/login?style=9&appid=522005705&daid=4&s_url=https%3A%2F%2Fw.mail.qq.com%2Fcgi-bin%2Flogin%3Fvt%3Dpassport%26vm%3Dwsk%26delegate_url%3D%26f%3Dxhtml%26target%3D&hln_css=http%3A%2F%2Fmail.qq.com%2Fzh_CN%2Fhtmledition%2Fimages%2Flogo%2Fqqmail%2Fqqmail_logo_default_200h.png&low_login=1&hln_autologin=%E8%AE%B0%E4%BD%8F%E7%99%BB%E5%BD%95%E7%8A%B6%E6%80%81&pt_no_onekey=1";
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    navView.backgroundColor = [UIColor colorWithRed:248/255.0 green:239/255.0 blue:252/255.0 alpha:1.0];
    
    [[UIApplication sharedApplication].keyWindow addSubview:navView];
    
    self.view.backgroundColor = [UIColor colorWithRed:248/255.0 green:239/255.0 blue:252/255.0 alpha:1.0];
    
    _isloginNewAccount = NO;
    _didLoadCount = 0;
    _index = 0;
    //调用加载web
    [self initWebView];
}

- (void)removeAllCached{
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    //缓存web清除
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSURL *url = [NSURL URLWithString:_url];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    if (url) {//清除所有cookie
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *)[cookies objectAtIndex:i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            
        }
    }
    //清除某一特定的cookie方法
    NSArray * cookArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    for (NSHTTPCookie*cookie in cookArray) {
        if ([cookie.name isEqualToString:@"cookiename"]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

//返回
- (void)back{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


//加载web
- (void)initWebView
{
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    backButton.frame = CGRectMake(0, 20, 60, 44);
//    backButton.titleLabel.font = [UIFont systemFontOfSize:20];
//    [backButton setTitle:@"刷新" forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(loadWebView) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:backButton];
    
    UIButton *againtLoginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    againtLoginBtn.frame = CGRectMake(115, 20, 100, 44);
    againtLoginBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [againtLoginBtn setTitle:@"登陆账号" forState:UIControlStateNormal];
    [againtLoginBtn addTarget:self action:@selector(againtLogin) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:againtLoginBtn];
    
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    loginButton.frame = CGRectMake(self.view.frame.size.width - 100, 20, 100, 44);
    loginButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [loginButton setTitle:@"确认登陆" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:loginButton];
    
    
    UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    checkBtn.frame = CGRectMake(0, 20, 100, 44);
    checkBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [checkBtn setTitle:@"查看参数" forState:UIControlStateNormal];
    [checkBtn addTarget:self action:@selector(checkBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:checkBtn];

    

    //初始化_webView
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 20)];
     _webView.delegate=self;
    [self.view addSubview:_webView];
    [self.view sendSubviewToBack:_webView];
//    [_webView setScalesPageToFit:YES];
    
//    [self removeAllCached];
//    [self loadWebView];
}

- (void)loadWebView{
    
    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _didLoadCount = 0;
    
    //加载一个网页地址
    [_webView loadRequest:request];
}

- (void)againtLogin{
    
    AccountKeyViewController *akVC = [[AccountKeyViewController alloc] initWithNibName:@"AccountKeyViewController" bundle:nil];
    
    __weak typeof(self) weakself = self;
    
    [akVC setBlock:^(NSArray *accountsArray, NSArray *keysArray) {
        weakself.accoutsArray = [accountsArray mutableCopy];
        weakself.keysArray    = [keysArray mutableCopy];
        
        Userinfo *user = [Userinfo shareInstance];
        [user.skeyArray removeAllObjects];
        
        weakself.index = 0;
        [weakself loginWeb];
        
    }];
    
    [self presentViewController:akVC animated:YES completion:nil];
    

}

- (void)loginWeb{
    
    _isloginNewAccount = YES;
    [self removeAllCached];
    [self loadWebView];
}

- (void)checkBtnAction{
    
    LoginInfoViewController *loginInfoVC = [[LoginInfoViewController alloc] initWithNibName:@"LoginInfoViewController" bundle:nil];
    
    NSMutableArray *arrM = [NSMutableArray array];
    
     Userinfo *user = [Userinfo shareInstance];
    
    [user.skeyArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = (NSDictionary *)obj;
        
        //{skey2:value,uin2:value}
        [arrM addObject:[NSString stringWithFormat:@"skey=%@,,uin==%@",[dic objectForKey:@"skey2"],[dic objectForKey:@"uin2"]]];
        
    }];
    
    loginInfoVC.dataArray = [arrM mutableCopy];
    
    [self presentViewController:loginInfoVC animated:YES completion:nil];
}

- (void)login{
    
    
    Userinfo *user = [Userinfo shareInstance];
    if (!user.skeyArray.count) {
        [QYHProgressHUD showErrorHUD:nil message:@"至少要登陆一个QQ才能进入主界面"];
        return;
    }
    
//    if (_isloginNewAccount) {
//        [QYHProgressHUD showErrorHUD:nil message:@"点击了登陆新账号，需要登陆账号才能进入主界面"];
//        return;
//    }
    
//    [self removeAllCached];
    
    QYHNextViewController *nextVC = [[QYHNextViewController alloc] initWithNibName:@"QYHNextViewController" bundle:nil];
    
    [UIApplication sharedApplication].keyWindow.rootViewController = nextVC;
    
}



//加载完成后设置偏移量
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
//    _webView.scrollView.contentInset=UIEdgeInsetsMake(-50, 0, 0, 0);

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    //document.getElementById('iframe的ID').contentWindow.document.getElementById('元素的ID')
//    //document.getElementById('login_frame').contentWindow.document.getElementById('title_2').innerHTML
    
    _didLoadCount++;
    
    if (_didLoadCount == 2) {
        
        if (_index < self.accoutsArray.count) {
            NSString *tempString = [NSString stringWithFormat:@"document.getElementById('u').value='%@@qq.com';",self.accoutsArray[_index]];
            
             NSLog(@"qq===%@",self.accoutsArray[_index]);
            
            NSString *key = _index < self.keysArray.count ? self.keysArray[_index] : [self.keysArray firstObject];
            
            NSString *tempString1 = [NSString stringWithFormat:@"document.getElementById('p').value='%@';",key];
            [_webView stringByEvaluatingJavaScriptFromString:tempString];
            [_webView stringByEvaluatingJavaScriptFromString:tempString1];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *btn = @"document.getElementById('go').click();";
                [_webView stringByEvaluatingJavaScriptFromString:btn];
                
            });
        }
        
    }
    
    
//     if (_didLoadCount < 4) {
//         return;
//     }
   
//    _webView.scrollView.contentOffset=CGPointMake(560, 0);
    
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    
    NSArray *nCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
   
    NSHTTPCookie *cookie;
    for (id c in nCookies)
    {
        if ([c isKindOfClass:[NSHTTPCookie class]]){
            cookie=(NSHTTPCookie *)c;
            
//            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//            NSLog(@"%@: %@", cookie.name, cookie.value);
            [dicM setObject:cookie.value forKey:cookie.name];
        }
    }
    /*http://ptlogin2.id.qq.com/check_sig?pttype=1&uin=1039540465&service=login&nodirect=0&ptsigx=886ef2f522391472ba2a5fc8085cf7ccc7d667d6cfb1fc486b47e6666e20a8c96d18fd373866174a8467bf7058f84ef7b772c03b48b16b1f67fd698cd9fd15c4&s_url=http%3A%2F%2Fid.qq.com%2Findex.html&f_url=&ptlang=2052&ptredirect=101&aid=1006102&daid=1&j_later=0&low_login_hour=0&regmaster=0&pt_login_type=1&pt_aid=0&pt_aaid=0&pt_light=0&pt_3rd_aid=0
     
     */
    NSLog(@"dicM==%@",dicM);
    
    if (dicM) {
        NSArray *keys = [dicM allKeys];
        if ([keys containsObject:@"skey"]) {
            
//            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            _isloginNewAccount = NO;
            
            NSMutableDictionary *userDic = [NSMutableDictionary dictionary];
            
            NSString *uin  = [dicM objectForKey:@"uin"];
            NSString *skey = [dicM objectForKey:@"skey"];
//            NSString *ldw  = [dicM objectForKey:@"ldw"];
//            NSString *itkn = [dicM objectForKey:@"itkn"];
            
            if (_index < self.accoutsArray.count) {
                
                NSLog(@"11==%@,22==%@",uin,self.accoutsArray[_index]);
                if ([uin rangeOfString:self.accoutsArray[_index]].location == NSNotFound) {
                    [self loginWeb];
                    return;
                }
            }
            
            if (uin) {
                [userDic setObject:[uin mutableCopy] forKey:@"uin2"];
//                [user setObject:[uin mutableCopy] forKey:@"uin2"];
            }
            if (skey) {
                [userDic setObject:[skey mutableCopy] forKey:@"skey2"];
//                [user setObject:[skey mutableCopy] forKey:@"skey2"];
            }
//            if (ldw) {
//                [user setObject:[ldw mutableCopy] forKey:@"ldw2"];
//            }
//            if (itkn) {
//                [user setObject:[itkn mutableCopy] forKey:@"itkn2"];
//            }
//            
//            NSDate *date = [NSDate date];
//            [user setObject:date forKey:@"date2"];
//            
//
            if (userDic && uin && skey) {
                Userinfo *user = [Userinfo shareInstance];
                user.cookiesArray = [nCookies mutableCopy];
                
                __block BOOL isSame = NO;
                
                [user.skeyArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSDictionary *dic = (NSDictionary *)obj;
                    if ([[dic objectForKey:@"uin2"] isEqualToString:[userDic objectForKey:@"uin2"]] && [[dic objectForKey:@"skey2"] isEqualToString:[userDic objectForKey:@"skey2"]]) {
                        isSame = YES;
                        *stop = YES;
                    }
                }];
                
                if (!isSame) {
                    _index++;
                    [user.skeyArray addObject:[userDic mutableCopy]];
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                     NSLog(@"userDic==%@",userDic);
                    
                    if (_index >= self.accoutsArray.count) {
                        [QYHProgressHUD showSuccessHUD:nil message:[NSString stringWithFormat:@"总共 %ld 个qq号登录完成！",_index]];
                    }else{
                        [self loginWeb];
                    }
                });
            }
        }
    }
    
}


//https://ssl.ptlogin2.qq.com/check?pt_tea=2&uin=1039724903@qq.com&appid=522005705&ptlang=2052&regmaster=&pt_uistyle=9&r=0.1965404435395437
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if ([request.URL.absoluteString rangeOfString:@"https://ssl.ptlogin2.qq.com/check"].location != NSNotFound) {
        NSLog(@"shouldStartLoadWithRequest");
    }

//    NSLog(@"shouldStartLoadWithRequest==%@",request.URL.absoluteString);
    
    return YES;
}



@end
