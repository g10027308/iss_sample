//
//  NSObject+HttpClient.h
//  QRView
//
//  Created by jiangbin on 18/6/15.
//  Copyright © 2018年 RITS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <curl/curl.h>
#import <openssl/ssl.h>
#import <WebKit/WebKit.h>

@interface HttpClient: NSObject
{
    NSMutableData *_dataReceived;
}

// 从一个地址Get
- (int)GetPart:(NSString *)urlText Response:(NSData **)response;

// 从一个地址Get(获得CURLcode后，再使用curl_easy_getinfo来获取response_code)
- (int)GetPartResponseCode:(NSString *)urlText Response:(NSData **)response;

// 向一个地址POST
- (int)PostPart:(NSString *)urlText PostData:(NSString *)postData Response:(NSData **)response isJson:(BOOL)bJSon;

// Use UI Setting Proxy Data
- (int)PostPartWithUISetting:(NSString *)urlText IsUseProxy:(NSString *)strUseProxy ProxyIPAndPort:(NSString *)strProxyIPAddressAndPort UserNameAndPasswd:(NSString *)strUserNameAndPassword PostData:(NSString *)postData Response:(NSData **)response isJson:(BOOL)bJSon;

// Use UI Setting Proxy Data
- (int)GetPartUseUISettings:(NSString *)urlText IsUseProxy:(NSString*)strUseProxy ProxyIPAndPort:(NSString*)strProxyIPAddressAndPort UserNameAndPasswd:(NSString*)strUserNameAndPassword  Response:(NSString **)response APISid:(NSString *)sAPISid;

//Use UI setting Proxy Data
- (int)PostJSONPartUseUISettings:(NSString *)urlText IsUseProxy:(NSString*)strUseProxy ProxyIPAndPort:(NSString*)strProxyIPAddressAndPort UserNameAndPasswd:(NSString*)strUserNameAndPassword PostJSON:(NSMutableDictionary *)postJSON Response:(NSData **)response;
//- (int)PostJSONPartUseUISettings:(NSString *)urlText IsUseProxy:(NSString*)strUseProxy ProxyIPAndPort:(NSString*)strProxyIPAddressAndPort UserNameAndPasswd:(NSString*)strUserNameAndPassword PostJSON:(NSMutableDictionary *)postJSON Response:(NSString **)response;


// 向一个地址POST(JSON)
- (int)PostJSONPart:(NSString *)urlText PostJSON:(NSMutableDictionary *)postJSON Response:(NSData **)response;

// 从String数据中取得一个值(一个层次，需指定一层的key)
//-(NSArray *)GetValueFromString:(NSString *)data sKey:(NSString *)strKey;

// 从JSON数据中取得一个值(一个层次，需指定一层的key)
- (NSArray *)GetValueFromJSONData:(NSData *)data sKey:(NSString *)strKey;

// 从JSON数据中取得一个值(两个层次，需指定两层的key)
-(NSArray *)GetValueFromJSONData2:(NSData *)data sKey1:(NSString *)strKey1 sKey2:(NSString *)strKey2;


-(int)PostJSONToken:(NSString *)urlText IsUseProxy:(NSString*)strUseProxy ProxyIPAndPort:(NSString*)strProxyIPAddressAndPort UserNameAndPasswd:(NSString*)strUserNameAndPassword PostJSON:(NSMutableDictionary *)postJSON Response:(NSData **)response;

@end
