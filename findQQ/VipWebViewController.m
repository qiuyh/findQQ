//
//  VipWebViewController.m
//  findQQ
//
//  Created by iMacQIU on 2017/4/18.
//  Copyright © 2017年 邱永槐. All rights reserved.
//

#import "VipWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "UIButton+WebCache.h"
#import "Userinfo.h"
#import "AFHTTPRequestOperationManager.h"

@interface VipWebViewController ()<UIWebViewDelegate>
{
    UIWebView *_webView;//可以加载网页数据的View
}

@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *absoluteString;

@property (nonatomic,strong) JSContext *context;

@property (nonatomic,assign) NSInteger loadCount;


@property (nonatomic,assign) NSInteger isSuccessCount;
@property (nonatomic,assign) NSInteger getCodeCount;
@property (nonatomic,assign) NSInteger requestCount;

@property (nonatomic,strong) NSTimer *timer;

@end

@implementation VipWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.url = [NSString stringWithFormat:@"http://haoma.qq.com/pay_v2.html?num=%@&type=10070&month=5&price=0&actid=0&openType=1&dear=1&phone=%@",_num,_phone];
    
    self.view.backgroundColor = [UIColor colorWithRed:248/255.0 green:239/255.0 blue:252/255.0 alpha:1.0];
    
//    [self removeAllCached];
    
    
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



- (void)getAuthCode{
    
    if (_requestCount>5 || _getCodeCount>4) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    _requestCount++;
    NSString *str = @"http://captcha.qq.com/getimage/pvip_hmpay/?appid=8000202";
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
    
    NSString *pictureDataString=[data base64Encoding];
    NSDictionary *parameters = @{@"user":@"fenghuai",
                                 @"pass":@"7720401ABC",
                                 @"softid":@"893354",
                                 @"codetype":@"1901",
                                 @"len_min":@"0",
                                 @"time_add":@"0",
                                 @"str_debug":@"0",
                                 @"file_base64":pictureDataString
                                 };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    [manager POST:@"http://upload.chaojiying.net/Upload/Processing.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"responseObject==%@",responseObject);
        
        
        if (responseObject) {
            NSInteger err_no  = [[responseObject objectForKey:@"err_no"] integerValue];
            NSString *err_str = [responseObject objectForKey:@"err_str"];
            
            if (err_str && err_no == 0 && [err_str isEqualToString:@"OK"]) {
                NSString *pic_id  = [responseObject objectForKey:@"pic_id"];
                NSString *pic_str = [responseObject objectForKey:@"pic_str"];
                
                if (pic_id) {
                    
                }
                
                if (pic_str) {
                    self.authString = pic_str;
                    _getCodeCount++;
                    if (_loadCount > 2) {//判断是否已经第一次点击支付
                        [self pay];
                    }
                    
                }else{
                    [self getAuthCode];
                }
            }else{
                [self getAuthCode];
            }
            
        }else{
            [self getAuthCode];
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error==%@",error);
        [self getAuthCode];
    }];
}


- (void)getSuccessTip{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"getSuccessTip");
    });
    
}


- (void)getFailureTip{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *info_alert = @"document.getElementById('lianghaoDialog').getElementsByClassName('info_alert')[0].getElementsByTagName('p')[0].innerHTML;";
        NSString *infoTip = [[_webView stringByEvaluatingJavaScriptFromString:info_alert] mutableCopy];
        
        if (infoTip.length) {
            NSString *closeButton = @"document.getElementById('closeButton').click();";
            [_webView stringByEvaluatingJavaScriptFromString:closeButton];
            
            NSString *alert = @"document.getElementById('lianghaoDialog').getElementsByClassName('info_alert')[0].getElementsByTagName('p')[0].innerHTML='';";
            [_webView stringByEvaluatingJavaScriptFromString:alert];

            if ([infoTip rangeOfString:@"验证码错误"].location != NSNotFound) {
                NSLog(@"验证码错误,infoTip==%@",infoTip);
                
                if (_isFromCache) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    [self getAuthCode];
                }
            }else if ([infoTip rangeOfString:@"系统繁忙"].location != NSNotFound) {
                NSLog(@"系统繁忙,infoTip==%@",infoTip);
                if (_isFromCache) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    [self getAuthCode];
                }
            }else if ([infoTip rangeOfString:@"请填写验证码"].location != NSNotFound) {
                NSLog(@"请填写验证码,infoTip==%@",infoTip);
                if (_isFromCache) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    [self getAuthCode];
                }
            }else if ([infoTip rangeOfString:@"您下手慢了"].location != NSNotFound) {
                NSLog(@"您下手慢了,infoTip==%@",infoTip);
                [self dismissViewControllerAnimated:YES completion:nil];
            }else if ([infoTip rangeOfString:@"其它用户正在支付该号码"].location != NSNotFound) {
                NSLog(@"其它用户正在支付该号码,infoTip==%@",infoTip);
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                NSLog(@"不知道什么原因,infoTip==%@",infoTip);
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
            
            if ([_timer isValid]) {
                [_timer invalidate];
                _timer = nil;
            }
            
        }else{
            
            NSString *fusion_dialog_mask = @"document.getElementsByClassName('fusion_dialog_mask').length;";
            NSString *success = [_webView stringByEvaluatingJavaScriptFromString:fusion_dialog_mask];
            
            if ([success integerValue] == 1) {
                
                if ([_timer isValid]) {
                    [_timer invalidate];
                    _timer = nil;
                }

                
                NSLog(@"抢到了,success==%@",success);
                Userinfo *userInfo = [Userinfo shareInstance];
                
                NSDictionary *userDic = userInfo.skeyArray[userInfo.skeyArray.count-1];
                NSString *uin ;
                if (userDic) {
                    uin = [[userDic objectForKey:@"uin2"] substringFromIndex:1];
                    
                }
                
                NSDate *date = [NSDate date];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
                NSString *dateTime = [formatter stringFromDate:date];
                
                NSString *obj = [NSString stringWithFormat:@"%@   \n用%@抢到了%@",dateTime,uin,_num];
                [[Userinfo shareInstance].resultArrM addObject:obj];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
                // 18520477660       [[NSNotificationCenter defaultCenter] postNotificationName:@"isSuccess" object:obj];
            }
            
            NSLog(@"getFailureTip == %@",success);
        }
        
        NSLog(@"infoTip==%@",infoTip);
    });
}


//加载web
- (void)initWebView
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame = CGRectMake(8, 35, 60, 44);
    backButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backButton];
    
    
//    UIButton *authButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    authButton.frame = CGRectMake(128, 35, 60, 44);
////    authButton.titleLabel.font = [UIFont systemFontOfSize:20];r
////    [authButton setTitle:@"返回" forState:UIControlStateNormal];
//    NSInteger random = arc4random() % 10000000000000000 + 10000000000000000;
//    
//    NSString *str = [NSString stringWithFormat:@"http://captcha.qq.com/getimage/pvip_hmpay/?appid=8000202&r=0.%ld",random];
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
//    [authButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
//    [authButton addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:authButton];

    
    
    _loadCount = 0;
    _isSuccessCount = 0;
    _getCodeCount = 0;
    _requestCount = 0;
    
    
    Userinfo *user = [Userinfo shareInstance];
    NSArray *nCookies = user.cookiesArray;
    
    NSHTTPCookie *cookie;
    for (id c in nCookies)
    {
        if ([c isKindOfClass:[NSHTTPCookie class]]){
            cookie=(NSHTTPCookie *)c;
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }

    
    //初始化_webView
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20)];
    _webView.delegate=self;
    [self.view addSubview:_webView];
    [self.view sendSubviewToBack:_webView];
    [_webView setScalesPageToFit:YES];
    
    
    [self loadWebView];
}

//- (void)refresh:(UIButton *)btn{
//    NSInteger random = arc4random() % 10000000000000000 + 10000000000000000;
//    
//    NSString *str = [NSString stringWithFormat:@"http://captcha.qq.com/getimage/pvip_hmpay/?appid=8000202&r=0.%ld",random];
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
//    [btn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
//}

- (void)loadWebView{
    
    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //加载一个网页地址
    [_webView loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _loadCount++;
    NSLog(@"webViewDidFinishLoad");
    //document.getElementById('iframe的ID').contentWindow.document.getElementById('元素的ID')
    //document.getElementById('login_frame').contentWindow.document.getElementById('title_2').innerHTML
    //    NSString *tempString = [NSString stringWithFormat:@"document.getElementById('login_frame').contentWindow.document.getElementById('login').innerHTML='%@';",@"797000880"];
    
    NSString *tempString = [NSString stringWithFormat:@"document.getElementById('password').value='%@';",_password];
    NSString *tempString1 = [NSString stringWithFormat:@"document.getElementById('password2').value='%@';",_password];
    [_webView stringByEvaluatingJavaScriptFromString:tempString];
    [_webView stringByEvaluatingJavaScriptFromString:tempString1];
    
    
    for (int i = 0; i<5; i++) {
        NSString *li = [NSString stringWithFormat:@"document.getElementById('openMonth').getElementsByTagName('li')[%d].className='';",i];
        [_webView stringByEvaluatingJavaScriptFromString:li];
        
        NSString *liI = [NSString stringWithFormat:@"document.getElementById('openMonth').getElementsByTagName('li')[%d].getElementsByTagName('i')[0].className='';",i];
        
        [_webView stringByEvaluatingJavaScriptFromString:liI];
        
    }
    
    
    NSString *selctedLi = [NSString stringWithFormat:@"document.getElementById('openMonth').getElementsByTagName('li')[%d].className='select';",0];
    [_webView stringByEvaluatingJavaScriptFromString:selctedLi];
    
    NSString *selctedI = [NSString stringWithFormat:@"document.getElementById('openMonth').getElementsByTagName('li')[%d].getElementsByTagName('i')[0].className='ico_select';",0];
    
    [_webView stringByEvaluatingJavaScriptFromString:selctedI];
    
    
    
    
    NSString *authImage = @"document.getElementById('authImage').innerHTML='';";
    [_webView stringByEvaluatingJavaScriptFromString:authImage];
    
    NSString *changeAuthCode = [NSString stringWithFormat:@"document.getElementById('changeAuthCode').innerHTML='%@';",@""];
    [_webView stringByEvaluatingJavaScriptFromString:changeAuthCode];
    
    
    NSString *authCode = [NSString stringWithFormat:@"document.getElementById('authCode').value='%@';",_authString];
    NSString *AU = [_webView stringByEvaluatingJavaScriptFromString:authCode];
    
    if (_loadCount==2) {
        //点击下一步
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *btn = @"document.getElementById('nextStep').click();";//nextStep,onclick();
            [_webView stringByEvaluatingJavaScriptFromString:btn];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self pay];
            });
            
        });
        
        //        NSLog(@"authString==%@,AU==%@",_authString,AU);
    }   
}


- (void)pay{
    //点击支付
    
    NSString *authCode = [NSString stringWithFormat:@"document.getElementById('authCode').value='%@';",_authString];
    [_webView stringByEvaluatingJavaScriptFromString:authCode];
    
    if (_authString && _authString.length==4) {
        _loadCount++;
        NSString *pay = @"document.getElementById('pay').click();";
        [_webView stringByEvaluatingJavaScriptFromString:pay];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
//            [self getFailureTip];
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(getFailureTip) userInfo:nil repeats:YES];
        });
    }
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    _absoluteString = request.URL.absoluteString;
    
    if ([_absoluteString rangeOfString:@"http://api.unipay.qq.com"].location != NSNotFound) {
//        _isSuccessCount++;
//        
//        if (_isSuccessCount==2) {
        
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                Userinfo *userInfo = [Userinfo shareInstance];
//                
//                NSDictionary *userDic = userInfo.skeyArray[userInfo.skeyArray.count-1];
//                NSString *uin ;
//                if (userDic) {
//                    uin = [[userDic objectForKey:@"uin2"] substringFromIndex:1];
//                    
//                }
//                
//                NSString *obj = [NSString stringWithFormat:@"用%@抢到了%@",uin,_num];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"isSuccess" object:obj];
//                
//                [self back];
//            });
//        }
        
        
//        return NO;
    }
        NSLog(@"shouldStartLoadWithRequest==%@",request.URL.absoluteString);
    
    return YES;
}


@end
