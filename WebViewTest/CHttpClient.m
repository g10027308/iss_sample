//
//  NSObject+HttpClient.m
//  QRView
//
//  Created by jiangbin on 18/6/15.
//  Copyright © 2018年 RITS. All rights reserved.
//

#import "CHttpClient.h"
//#import "SettingWindow.h"
#import <curl/curl.h>

#include <sys/types.h>
#include <pwd.h>

// Create private interface
@interface HttpClient (Private)
- (void)receivedData:(NSData *)data;
@end

size_t write_data(char *ptr, size_t size, size_t nmemb, void *userdata) {
    const size_t sizeInBytes = size*nmemb;
    
    HttpClient *vc = (__bridge HttpClient *)userdata;
    NSData *data = [[NSData alloc] initWithBytes:ptr length:sizeInBytes];
    
    [vc receivedData:data];  // send to viewcontroller
    
    return sizeInBytes;
}


@implementation  HttpClient

-(id)init
{
    if (self=[super init]) {
        //初始化
        _dataReceived = [[NSMutableData alloc] init];
        
    }
    return self;
}

- (void)receivedData:(NSData *)data
{
    [_dataReceived appendData:data];
}

- (int)GetPart:(NSString *)urlText Response:(NSData **)response{
    
    CURLcode theResult;
    if (urlText && ![urlText isEqualToString:@""]) {
        
        *response = [[NSData alloc]init];
        CURL* curl = curl_easy_init();
        if(NULL == curl)
        {
            NSLog(@"failed to init curl_easy_init");
            return CURLE_FAILED_INIT;
        }
        
        NSString *resultText = @""; // clear viewer
        [_dataReceived setLength:0U];
        
        // Set CURL callback functions
        curl_easy_setopt(curl,CURLOPT_WRITEFUNCTION, write_data);//对返回的数据进行操作的函数地址
        curl_easy_setopt(curl,CURLOPT_WRITEDATA, self); //这是write_data的第四个参数值
        
        // set proxy
 /*
        NSString *strUseProxy = [SettingWindow getUseProxy];
 
        if(YES == [strUseProxy isEqualToString:@"1"]){
            NSString *strProxyIPAddress = [SettingWindow getProxyIPAddress];
            NSString *strPort = [SettingWindow getProxyPort];
            NSString *strUserName = [SettingWindow getUserName];
            NSString *strPassword = [SettingWindow getPassword];
            NSString *strProxyIPAddressAndPort = [NSString stringWithFormat:@"%@:%@", strProxyIPAddress, strPort];
            NSString *strUserNameAndPassword = [NSString stringWithFormat:@"%@:%@", strUserName, strPassword];
            curl_easy_setopt(curl, CURLOPT_PROXY, [strProxyIPAddressAndPort UTF8String]);
            curl_easy_setopt(curl, CURLOPT_PROXYUSERPWD, [strUserNameAndPassword UTF8String]);
        }
 */
        // Set some CURL options
        curl_easy_setopt(curl,CURLOPT_HEADER, 0L);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10);
        curl_easy_setopt(curl,CURLOPT_HTTPGET, 1L); //设置问非0表示本次操作为get
        curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1L);
        curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 10);
        
        // SSL verify peer
        curl_easy_setopt(curl,CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(curl,CURLOPT_SSL_VERIFYHOST, 0L); //设置为非0,响应头信息location
        // CA root certs - loaded into project from libcurl http://curl.haxx.se/ca/cacert.pem
        NSString *cacertPath = [[NSBundle mainBundle] pathForResource:@"cacert" ofType:@"pem"];
        curl_easy_setopt(curl, CURLOPT_CAINFO, [cacertPath UTF8String]); // set root CA certs
        
        // set URL
        curl_easy_setopt(curl, CURLOPT_URL, [urlText UTF8String]);
        //curl_easy_setopt(curl, CURLOPT_POSTFIELDS, [strField UTF8String]); //post参数
        
        theResult = curl_easy_perform(curl);
        if (theResult == CURLE_OK) {
            
            NSString *infoStr= [[NSString alloc]initWithData:_dataReceived encoding:NSUTF8StringEncoding];
            *response = [infoStr dataUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"theResult: OK");
        }
        else {
            resultText = [resultText stringByAppendingFormat:@"\n** TRANSFER INTERRUPTED - ERROR [%d]\n", theResult];
            if (theResult == 6) {
                resultText = [resultText stringByAppendingString:@"\n** Host Not Found - Check URL or Network\n"];
            }
            NSLog(@"ERROR: %@", resultText);
        }
        
        curl_easy_cleanup(curl);
    } else {
        theResult = CURLE_URL_MALFORMAT;
        NSLog(@"ERROR: Invalid _urlText passed.");
    }
    
    return theResult;
}

-(NSString *) getloginUser{
    uid_t current_user_id = getuid();
    struct passwd *pwentry = getpwuid(current_user_id);
    char *loginUser = pwentry->pw_name;
    NSString *loginName = [[NSString alloc] initWithUTF8String:loginUser];
    return loginName;
}

- (int)GetPartUseUISettings:(NSString *)urlText IsUseProxy:(NSString*)strUseProxy ProxyIPAndPort:(NSString*)strProxyIPAddressAndPort UserNameAndPasswd:(NSString*)strUserNameAndPassword  Response:(NSString **)response{
    
    CURLcode theResult;
    if (urlText && ![urlText isEqualToString:@""]) {
        
        //*response = [[NSData alloc]init];
        
        CURL* curl = curl_easy_init();
        if(NULL == curl)
        {
            NSLog(@"failed to init curl_easy_init");
            return CURLE_FAILED_INIT;
        }
        
        NSString *resultText = @""; // clear viewer
        [_dataReceived setLength:0U];
        
        // Set CURL callback functions
        curl_easy_setopt(curl,CURLOPT_WRITEFUNCTION, write_data);//对返回的数据进行操作的函数地址
        curl_easy_setopt(curl,CURLOPT_WRITEDATA, self); //这是write_data的第四个参数值
        
        // set proxy
        //NSString *strUseProxy = [SettingWindow getUseProxy];
        if(YES == [strUseProxy isEqualToString:@"1"]){
            curl_easy_setopt(curl, CURLOPT_PROXY, [strProxyIPAddressAndPort UTF8String]);
            curl_easy_setopt(curl, CURLOPT_PROXYUSERPWD, [strUserNameAndPassword UTF8String]);
        }
        
        // Set some CURL options
        curl_easy_setopt(curl,CURLOPT_HEADER, 0L);//不使用header为0，用为1
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10);
        curl_easy_setopt(curl,CURLOPT_HTTPGET, 1L); //设置问非0表示本次操作为get
        curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1L);
        curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 10);
        
        // SSL verify peer
        curl_easy_setopt(curl,CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(curl,CURLOPT_SSL_VERIFYHOST, 0L); //设置为非0,响应头信息location
        // CA root certs - loaded into project from libcurl http://curl.haxx.se/ca/cacert.pem
        NSString *cacertPath = [[NSBundle mainBundle] pathForResource:@"cacert" ofType:@"pem"];
        curl_easy_setopt(curl, CURLOPT_CAINFO, [cacertPath UTF8String]); // set root CA certs
        
        // set URL
        curl_easy_setopt(curl, CURLOPT_URL, [urlText UTF8String]);
        //curl_easy_setopt(curl, CURLOPT_POSTFIELDS, [strField UTF8String]); //post参数
        
        NSString *loginName = [self getloginUser];
        NSString *cookiesName = [NSString stringWithFormat:@"/private/tmp/cookies_na_sample_%@.txt",loginName];
        const char *cookies = [cookiesName UTF8String];
        curl_easy_setopt(curl, CURLOPT_COOKIEFILE, cookies);
        
        theResult = curl_easy_perform(curl);
        if (theResult == CURLE_OK) {
            
            NSString *infoStr= [[NSString alloc]initWithData:_dataReceived encoding:NSUTF8StringEncoding];
            *response = infoStr;
            
            NSLog(@"theResult: OK");
        }
        else {
            resultText = [resultText stringByAppendingFormat:@"\n** TRANSFER INTERRUPTED - ERROR [%d]\n", theResult];
            if (theResult == 6) {
                resultText = [resultText stringByAppendingString:@"\n** Host Not Found - Check URL or Network\n"];
            }
            NSLog(@"ERROR: %@", resultText);
        }
        
        curl_easy_cleanup(curl);
    } else {
        theResult = CURLE_URL_MALFORMAT;
        NSLog(@"ERROR: Invalid _urlText passed.");
    }
    
    return theResult;
}


- (int)GetPartResponseCode:(NSString *)urlText Response:(NSData **)response{
    
    static int response_code = 0;
    
    CURLcode theResult;
    if (urlText && ![urlText isEqualToString:@""]) {
        
        *response = [[NSData alloc]init];
        CURL* curl = curl_easy_init();
        if(NULL == curl)
        {
            NSLog(@"failed to init curl_easy_init");
            return CURLE_FAILED_INIT;
        }
        
        NSString *resultText = @""; // clear viewer
        [_dataReceived setLength:0U];
        
        // Set CURL callback functions
        curl_easy_setopt(curl,CURLOPT_WRITEFUNCTION, write_data);//对返回的数据进行操作的函数地址
        curl_easy_setopt(curl,CURLOPT_WRITEDATA, self); //这是write_data的第四个参数值
        
        // set proxy
 /*
        NSString *strUseProxy = [SettingWindow getUseProxy];
        if(YES == [strUseProxy isEqualToString:@"1"]){
            NSString *strProxyIPAddress = [SettingWindow getProxyIPAddress];
            NSString *strPort = [SettingWindow getProxyPort];
            NSString *strUserName = [SettingWindow getUserName];
            NSString *strPassword = [SettingWindow getPassword];
            NSString *strProxyIPAddressAndPort = [NSString stringWithFormat:@"%@:%@", strProxyIPAddress, strPort];
            NSString *strUserNameAndPassword = [NSString stringWithFormat:@"%@:%@", strUserName, strPassword];
            curl_easy_setopt(curl, CURLOPT_PROXY, [strProxyIPAddressAndPort UTF8String]);
            curl_easy_setopt(curl, CURLOPT_PROXYUSERPWD, [strUserNameAndPassword UTF8String]);
        }
 */
        // Set some CURL options
        curl_easy_setopt(curl,CURLOPT_HEADER, 0L);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10);
        curl_easy_setopt(curl,CURLOPT_HTTPGET, 1L); //设置问非0表示本次操作为get
        curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1L);
        curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 10);
        
        // SSL verify peer
        curl_easy_setopt(curl,CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(curl,CURLOPT_SSL_VERIFYHOST, 0L); //设置为非0,响应头信息location
        // CA root certs - loaded into project from libcurl http://curl.haxx.se/ca/cacert.pem
        NSString *cacertPath = [[NSBundle mainBundle] pathForResource:@"cacert" ofType:@"pem"];
        curl_easy_setopt(curl, CURLOPT_CAINFO, [cacertPath UTF8String]); // set root CA certs
        
        // set URL
        curl_easy_setopt(curl, CURLOPT_URL, [urlText UTF8String]);
        //curl_easy_setopt(curl, CURLOPT_POSTFIELDS, [strField UTF8String]); //post参数
        
        theResult = curl_easy_perform(curl);
        if (theResult == CURLE_OK) {
            
            NSString *infoStr= [[NSString alloc]initWithData:_dataReceived encoding:NSUTF8StringEncoding];
            *response = [infoStr dataUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"theResult: OK");
        }
        else {
            resultText = [resultText stringByAppendingFormat:@"\n** TRANSFER INTERRUPTED - ERROR [%d]\n", theResult];
            if (theResult == 6) {
                resultText = [resultText stringByAppendingString:@"\n** Host Not Found - Check URL or Network\n"];
            }
            NSLog(@"ERROR: %@", resultText);
        }
        
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
        
        curl_easy_cleanup(curl);
    } else {
//        theResult = CURLE_URL_MALFORMAT;
        NSLog(@"ERROR: Invalid _urlText passed.");
    }
    
    
    
    return response_code;
}

- (int)PostPart:(NSString *)urlText PostData:(NSString *)postData Response:(NSData **)response isJson:(BOOL)bJSon{
    
    CURLcode theResult;
    if (urlText && ![urlText isEqualToString:@""]) {
        
        *response = [[NSData alloc]init];
        CURL* curl = curl_easy_init();
        if(NULL == curl)
        {
            NSLog(@"failed to init curl_easy_init");
            return CURLE_FAILED_INIT;
        }
        
        NSString *resultText = @""; // clear viewer
        [_dataReceived setLength:0U];
        
        // SSL verify peer
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10);
        curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 10);  //set connect timeout to 3 senconds
        // CA root certs - loaded into project from libcurl http://curl.haxx.se/ca/cacert.pem
        NSString *cacertPath = [[NSBundle mainBundle] pathForResource:@"cacert" ofType:@"pem"];
        curl_easy_setopt(curl, CURLOPT_CAINFO, [cacertPath UTF8String]); // set root CA certs
        
        // set proxy
 /*
        NSString *strUseProxy = [SettingWindow getUseProxy];
        if(YES == [strUseProxy isEqualToString:@"1"]){
            NSString *strProxyIPAddress = [SettingWindow getProxyIPAddress];
            NSString *strPort = [SettingWindow getProxyPort];
            NSString *strUserName = [SettingWindow getUserName];
            NSString *strPassword = [SettingWindow getPassword];
            NSString *strProxyIPAddressAndPort = [NSString stringWithFormat:@"%@:%@", strProxyIPAddress, strPort];
            NSString *strUserNameAndPassword = [NSString stringWithFormat:@"%@:%@", strUserName, strPassword];
            curl_easy_setopt(curl, CURLOPT_PROXY, [strProxyIPAddressAndPort UTF8String]);
            curl_easy_setopt(curl, CURLOPT_PROXYUSERPWD, [strUserNameAndPassword UTF8String]);
        }
 */
        // Set URL & PostData
        curl_easy_setopt(curl, CURLOPT_URL, [urlText UTF8String]);
        
        if (postData && ![postData isEqualToString:@""]) {
            
            //curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)[postData length]);
            curl_easy_setopt(curl, CURLOPT_POSTFIELDS, [postData UTF8String]);
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, self);
        }
        
        if(bJSon){
            struct curl_slist *headers = NULL;
            headers=curl_slist_append(headers, "Content-Type:application/json;charset=UTF-8");
            curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        }
        else{
            // Disable "Expect: 100-continue
            struct curl_slist *headers = NULL;
            headers = curl_slist_append(headers, "Expect:");
            curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        }
        
        theResult = curl_easy_perform(curl);
        if (theResult == CURLE_OK)
        {
            NSString *infoStr= [[NSString alloc]initWithData:_dataReceived encoding:NSUTF8StringEncoding];
            *response = [infoStr dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"theResult: OK");
        }
        else {
            resultText = [resultText stringByAppendingFormat:@"\n** TRANSFER INTERRUPTED - ERROR [%d]\n", theResult];
            if (theResult == 6) {
                resultText = [resultText stringByAppendingString:@"\n** Host Not Found - Check URL or Network\n"];
            }
            NSLog(@"ERROR: %@", resultText);
        }
        
        curl_easy_cleanup(curl);
    } else {
        theResult = CURLE_URL_MALFORMAT;
        NSLog(@"ERROR: Invalid _urlText passed.");
    }
    
    return theResult;
}


- (int)PostPartWithUISetting:(NSString *)urlText IsUseProxy:(NSString *)strUseProxy ProxyIPAndPort:(NSString *)strProxyIPAddressAndPort UserNameAndPasswd:(NSString *)strUserNameAndPassword PostData:(NSString *)postData Response:(NSData **)response isJson:(BOOL)bJSon{
    
    CURLcode theResult;
    if (urlText && ![urlText isEqualToString:@""]) {
        
        *response = [[NSData alloc]init];
        CURL* curl = curl_easy_init();
        if(NULL == curl)
        {
            NSLog(@"failed to init curl_easy_init");
            return CURLE_FAILED_INIT;
        }
        
        NSString *resultText = @""; // clear viewer
        [_dataReceived setLength:0U];
        
        // SSL verify peer
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10);
        curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 10);  //set connect timeout to 3 senconds
        // CA root certs - loaded into project from libcurl http://curl.haxx.se/ca/cacert.pem
        NSString *cacertPath = [[NSBundle mainBundle] pathForResource:@"cacert" ofType:@"pem"];
        curl_easy_setopt(curl, CURLOPT_CAINFO, [cacertPath UTF8String]); // set root CA certs
        
        //NSString *strUseProxy = [SettingWindow getUseProxy];
        if(YES == [strUseProxy isEqualToString:@"1"]){
            curl_easy_setopt(curl, CURLOPT_PROXY, [strProxyIPAddressAndPort UTF8String]);
            curl_easy_setopt(curl, CURLOPT_PROXYUSERPWD, [strUserNameAndPassword UTF8String]);
        }
        
        // Set URL & PostData
        curl_easy_setopt(curl, CURLOPT_URL, [urlText UTF8String]);
        
        if (postData && ![postData isEqualToString:@""]) {
            
            //curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)[postData length]);
            curl_easy_setopt(curl, CURLOPT_POSTFIELDS, [postData UTF8String]);
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, self);
        }
        
        if(bJSon){
            struct curl_slist *headers = NULL;
            headers=curl_slist_append(headers, "Content-Type:application/json;charset=UTF-8");
            curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        }
        else{
            // Disable "Expect: 100-continue
            struct curl_slist *headers = NULL;
            headers = curl_slist_append(headers, "Expect:");
            curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        }
        
        theResult = curl_easy_perform(curl);
        if (theResult == CURLE_OK)
        {
            NSString *infoStr= [[NSString alloc]initWithData:_dataReceived encoding:NSUTF8StringEncoding];
            *response = [infoStr dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"theResult: OK");
        }
        else {
            resultText = [resultText stringByAppendingFormat:@"\n** TRANSFER INTERRUPTED - ERROR [%d]\n", theResult];
            if (theResult == 6) {
                resultText = [resultText stringByAppendingString:@"\n** Host Not Found - Check URL or Network\n"];
            }
            NSLog(@"ERROR: %@", resultText);
        }
        
        curl_easy_cleanup(curl);
    } else {
        theResult = CURLE_URL_MALFORMAT;
        NSLog(@"ERROR: Invalid _urlText passed.");
    }
    
    return theResult;
}


- (int)PostJSONPart:(NSString *)urlText PostJSON:(NSMutableDictionary *)postJSON Response:(NSData **)response
{
    CURLcode theResult;
    if (urlText && ![urlText isEqualToString:@""]) {
        
        *response = [[NSData alloc]init];
        CURL* curl = curl_easy_init();
        if(NULL == curl)
        {
            NSLog(@"failed to init curl_easy_init");
            return CURLE_FAILED_INIT;
        }
        
        NSString *resultText = @""; // clear viewer
        [_dataReceived setLength:0U];
        
        // SSL verify peer
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10);
        curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 10);  //set connect timeout to 3 senconds
        // CA root certs - loaded into project from libcurl http://curl.haxx.se/ca/cacert.pem
        NSString *cacertPath = [[NSBundle mainBundle] pathForResource:@"cacert" ofType:@"pem"];
        curl_easy_setopt(curl, CURLOPT_CAINFO, [cacertPath UTF8String]); // set root CA certs
        
        // set proxy
    /*
        NSString *strUseProxy = [SettingWindow getUseProxy];
        if(YES == [strUseProxy isEqualToString:@"1"]){
            NSString *strProxyIPAddress = [SettingWindow getProxyIPAddress];
            NSString *strPort = [SettingWindow getProxyPort];
            NSString *strUserName = [SettingWindow getUserName];
            NSString *strPassword = [SettingWindow getPassword];
            NSString *strProxyIPAddressAndPort = [NSString stringWithFormat:@"%@:%@", strProxyIPAddress, strPort];
            NSString *strUserNameAndPassword = [NSString stringWithFormat:@"%@:%@", strUserName, strPassword];
            curl_easy_setopt(curl, CURLOPT_PROXY, [strProxyIPAddressAndPort UTF8String]);
            curl_easy_setopt(curl, CURLOPT_PROXYUSERPWD, [strUserNameAndPassword UTF8String]);
        }
   */
        // Set URL & PostData
        curl_easy_setopt(curl, CURLOPT_URL, [urlText UTF8String]);
        
        // NSMutableDictionary to JSON NSString
        NSData *data=[NSJSONSerialization dataWithJSONObject:postJSON options:NSJSONWritingPrettyPrinted error:nil];
        NSString *postData=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        if (postData && ![postData isEqualToString:@""]) {
            
            //curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)[postData length]);
            curl_easy_setopt(curl, CURLOPT_POSTFIELDS, [postData UTF8String]);
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, self);
        }
        
        // JSON Type
        struct curl_slist *headers = NULL;
        headers=curl_slist_append(headers, "Content-Type:application/json;charset=UTF-8");
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        
        theResult = curl_easy_perform(curl);
        if (theResult == CURLE_OK)
        {
            NSString *infoStr= [[NSString alloc]initWithData:_dataReceived encoding:NSUTF8StringEncoding];
            *response = [infoStr dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"theResult: OK");
        }
        else {
            resultText = [resultText stringByAppendingFormat:@"\n** TRANSFER INTERRUPTED - ERROR [%d]\n", theResult];
            if (theResult == 6) {
                resultText = [resultText stringByAppendingString:@"\n** Host Not Found - Check URL or Network\n"];
            }
            NSLog(@"ERROR: %@", resultText);
        }
        
        curl_easy_cleanup(curl);
    } else {
        theResult = CURLE_URL_MALFORMAT;
        NSLog(@"ERROR: Invalid _urlText passed.");
    }
    
    return theResult;
}


//- (int)PostJSONPartUseUISettings:(NSString *)urlText IsUseProxy:(NSString*)strUseProxy ProxyIPAndPort:(NSString*)strProxyIPAddressAndPort UserNameAndPasswd:(NSString*)strUserNameAndPassword PostJSON:(NSMutableDictionary *)postJSON Response:(NSData **)response
- (int)PostJSONPartUseUISettings:(NSString *)urlText IsUseProxy:(NSString*)strUseProxy ProxyIPAndPort:(NSString*)strProxyIPAddressAndPort UserNameAndPasswd:(NSString*)strUserNameAndPassword PostJSON:(NSMutableDictionary *)postJSON Response:(NSString **)response
{
    CURLcode theResult;
    
    if (urlText && ![urlText isEqualToString:@""]) {
        
        //*response = [[NSData alloc]init];
        
        CURL* curl = curl_easy_init();
        if(NULL == curl)
        {
            NSLog(@"failed to init curl_easy_init");
            return CURLE_FAILED_INIT;
        }
        
        NSString *resultText = @""; // clear viewer
        [_dataReceived setLength:0U];
        
        // SSL verify peer
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10);
        curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 10);  //set connect timeout to 3 senconds
        // CA root certs - loaded into project from libcurl http://curl.haxx.se/ca/cacert.pem
        NSString *cacertPath = [[NSBundle mainBundle] pathForResource:@"cacert" ofType:@"pem"];
        curl_easy_setopt(curl, CURLOPT_CAINFO, [cacertPath UTF8String]); // set root CA certs
        
        // set proxy
        
        //NSString *strUseProxy = [SettingWindow getUseProxy];
        if(YES == [strUseProxy isEqualToString:@"1"]){
            curl_easy_setopt(curl, CURLOPT_PROXY, [strProxyIPAddressAndPort UTF8String]);
            curl_easy_setopt(curl, CURLOPT_PROXYUSERPWD, [strUserNameAndPassword UTF8String]);
        }
        
        // Set URL & PostData
        curl_easy_setopt(curl, CURLOPT_URL, [urlText UTF8String]);
        
        // NSMutableDictionary to JSON NSString
        NSData *data=[NSJSONSerialization dataWithJSONObject:postJSON options:NSJSONWritingPrettyPrinted error:nil];
        NSString *postData=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        if (postData && ![postData isEqualToString:@""]) {
            
            //curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)[postData length]);
            curl_easy_setopt(curl, CURLOPT_POSTFIELDS, [postData UTF8String]);
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, self);
        }
        
        // JSON Type
        struct curl_slist *headers = NULL;
        //headers=curl_slist_append(headers, "Content-Type:application/json;charset=UTF-8");
        headers=curl_slist_append(headers, "Content-Type:application/json");
        headers=curl_slist_append(headers, "charset=UTF-8");
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        
        NSString *loginName = [self getloginUser];
        NSString *cookiesName = [NSString stringWithFormat:@"/private/tmp/cookies_na_sample_%@.txt",loginName];
        const char *cookies = [cookiesName UTF8String];
        
        FILE *fp = fopen(cookies, "wb");
        curl_easy_setopt(curl, CURLOPT_COOKIEJAR, cookies);
        fclose(fp);
        
        theResult = curl_easy_perform(curl);
        if (theResult == CURLE_OK)
        {
            
            long retcode = 0;
            theResult = curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE , &retcode);
            NSNumber *longNumber = [NSNumber numberWithLong:retcode];
            *response = [longNumber stringValue];
            /*
            NSString *infoStr= [[NSString alloc]initWithData:_dataReceived encoding:NSUTF8StringEncoding];
            *response = [infoStr dataUsingEncoding:NSUTF8StringEncoding];
            */
            NSLog(@"theResult: OK");
        }
        else {
            resultText = [resultText stringByAppendingFormat:@"\n** TRANSFER INTERRUPTED - ERROR [%d]\n", theResult];
            if (theResult == 6) {
                resultText = [resultText stringByAppendingString:@"\n** Host Not Found - Check URL or Network\n"];
            }
            NSLog(@"ERROR: %@", resultText);
        }
        
        curl_easy_cleanup(curl);
        
    } else {
        theResult = CURLE_URL_MALFORMAT;
        NSLog(@"ERROR: Invalid _urlText passed.");
    }
    
    return theResult;
}


- (int)PostJSONToken:(NSString *)urlText IsUseProxy:(NSString*)strUseProxy ProxyIPAndPort:(NSString*)strProxyIPAddressAndPort UserNameAndPasswd:(NSString*)strUserNameAndPassword PostJSON:(NSMutableDictionary *)postJSON Response:(NSData **)response
{
    CURLcode theResult;
    
    if (urlText && ![urlText isEqualToString:@""]) {
        
        *response = [[NSData alloc]init];
        CURL* curl = curl_easy_init();
        if(NULL == curl)
        {
            NSLog(@"failed to init curl_easy_init");
            return CURLE_FAILED_INIT;
        }
        
        NSString *resultText = @""; // clear viewer
        [_dataReceived setLength:0U];
        
        // SSL verify peer
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10);
        curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 10);  //set connect timeout to 3 senconds
        // CA root certs - loaded into project from libcurl http://curl.haxx.se/ca/cacert.pem
        NSString *cacertPath = [[NSBundle mainBundle] pathForResource:@"cacert" ofType:@"pem"];
        curl_easy_setopt(curl, CURLOPT_CAINFO, [cacertPath UTF8String]); // set root CA certs
        
        // set proxy
        
        //NSString *strUseProxy = [SettingWindow getUseProxy];
        if(YES == [strUseProxy isEqualToString:@"1"]){
            curl_easy_setopt(curl, CURLOPT_PROXY, [strProxyIPAddressAndPort UTF8String]);
            curl_easy_setopt(curl, CURLOPT_PROXYUSERPWD, [strUserNameAndPassword UTF8String]);
        }
        
        // Set URL & PostData
        curl_easy_setopt(curl, CURLOPT_URL, [urlText UTF8String]);
        
        // NSMutableDictionary to JSON NSString
        NSData *data=[NSJSONSerialization dataWithJSONObject:postJSON options:NSJSONWritingPrettyPrinted error:nil];
        NSString *postData=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        if (postData && ![postData isEqualToString:@""]) {
            
            //curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)[postData length]);
            curl_easy_setopt(curl, CURLOPT_POSTFIELDS, [postData UTF8String]);
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, self);
        }
        
        // JSON Type
        struct curl_slist *headers = NULL;
        //headers=curl_slist_append(headers, "Content-Type:application/json;charset=UTF-8");
        headers=curl_slist_append(headers, "Content-Type:application/json");
        headers=curl_slist_append(headers, "charset=UTF-8");
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        
        theResult = curl_easy_perform(curl);
        if (theResult == CURLE_OK)
        {
            NSString *infoStr= [[NSString alloc]initWithData:_dataReceived encoding:NSUTF8StringEncoding];
            *response = [infoStr dataUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"theResult: OK");
        }
        else {
            resultText = [resultText stringByAppendingFormat:@"\n** TRANSFER INTERRUPTED - ERROR [%d]\n", theResult];
            if (theResult == 6) {
                resultText = [resultText stringByAppendingString:@"\n** Host Not Found - Check URL or Network\n"];
            }
            NSLog(@"ERROR: %@", resultText);
        }
        
        curl_easy_cleanup(curl);
        
    } else {
        theResult = CURLE_URL_MALFORMAT;
        NSLog(@"ERROR: Invalid _urlText passed.");
    }
    
    return theResult;
}


-(NSArray *)GetValueFromJSONData:(NSData *)data sKey:(NSString *)strKey{
    
    NSError *error = nil;
    NSDictionary* resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    if(error){
        NSLog(@"dic->%@", error);
    }
    return [resultDic objectForKey:strKey];
}


-(NSArray *)GetValueFromJSONData2:(NSData *)data sKey1:(NSString *)strKey1 sKey2:(NSString *)strKey2{
    
    NSError *error = nil;
    //第一层数据
    NSDictionary* resultDic1 = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    if(error){
        NSLog(@"dic1->%@", error);
    }
    
    //第二层数据
    NSDictionary* resultDic2 = [resultDic1 objectForKey:strKey1];
    
    if(error){
        NSLog(@"dic2->%@", error);
    }
    NSArray *nsTest = [resultDic2 objectForKey:strKey2];
    return nsTest;
    //return [resultDic2 objectForKey:strKey2];
}

@end
