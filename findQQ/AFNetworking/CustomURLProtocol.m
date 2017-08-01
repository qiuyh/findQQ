//
//  CustomURLProtocol.m
//  NSURLProtocolExample
//
//  Created by lujb on 15/6/15.
//  Copyright (c) 2015年 lujb. All rights reserved.
//

#import "CustomURLProtocol.h"

static NSString * const URLProtocolHandledKey = @"URLProtocolHandledKey";

@interface CustomURLProtocol ()<NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation CustomURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    //只处理http和https请求
    NSString *scheme = [[request URL] scheme];
    if ( ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
     [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame))
    {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        
        return YES;
    }
    return NO;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    mutableReqeust = [self redirectHostInRequset:mutableReqeust];
    return mutableReqeust;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    /* 如果想直接返回缓存的结果，构建一个NSURLResponse对象
    if (cachedResponse) {
        
        NSData *data = cachedResponse.data; //缓存的数据
        NSString *mimeType = cachedResponse.mimeType;
        NSString *encoding = cachedResponse.encoding;
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:self.request.URL
                                                            MIMEType:mimeType
                                               expectedContentLength:data.length
                                                    textEncodingName:encoding];
        
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    */
    
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    
    //打标签，防止无限循环
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    
    self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
}

- (void)stopLoading
{
    [self.connection cancel];
}

#pragma mark - NSURLConnectionDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

#pragma mark -- private

+(NSMutableURLRequest*)redirectHostInRequset:(NSMutableURLRequest*)request
{
    if ([request.URL host].length == 0) {
        return request;
    }
    
    
    NSString *originUrlString = [request.URL absoluteString];
    
    NSLog(@"originUrlString==%@",originUrlString);
    
    
    if ([originUrlString rangeOfString:@"http://captcha.qq.com/getimage/pvip_hmpay/?appid=8000202&r="].location != NSNotFound) {
        return nil;
    }
    

//    
//    if ([originUrlString rangeOfString:@"http://i.gtimg.cn/vipstyle/global/img/bg_pop_v2.png"].location != NSNotFound) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"failureTip" object:nil];
//        
//    }else  if ([originUrlString rangeOfString:@"http://hm.vip.qq.com/cgi-bin/VipPricing.fcgi"].location != NSNotFound) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"failureTip" object:nil];
//        
//    }else  if ([originUrlString rangeOfString:@"http://api.unipay.qq.com"].location != NSNotFound) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"successTip" object:nil];
//    }
//    
    
    
    /*
     点击下一步
     
     //hm.vip.qq.com/cgi-bin/HaomaWrap.fcgi
     
     点击了确认支付（没输验证码）
     
     //http://i.gtimg.cn/vipstyle/global/img/bg_pop_v2.png
     
     点击了确认支付(验证码错误或者已经被人购买了)
     
     //http://hm.vip.qq.com/cgi-bin/VipPricing.fcgi
     
     购买成功
     
     //http://api.unipay.qq.com
     
     
     第一页加载完成
     https://huatuocode.huatuo.qq.com/code.cgi
     http://jqmt.qq.com/cdn_dianjiliu.js
     
     */
    
    
    
    
    //    NSString *originHostString = [request.URL host];
    //    NSRange hostRange = [originUrlString rangeOfString:originHostString];
    //    if (hostRange.location == NSNotFound) {
//        return request;
//    }
//    
//    //定向到bing搜索主页
//    NSString *ip = @"cn.bing.com";
//    
//    // 替换host
//    NSString *urlString = [originUrlString stringByReplacingCharactersInRange:hostRange withString:ip];
//    NSURL *url = [NSURL URLWithString:urlString];
//    request.URL = url;

    return request;
}


@end
