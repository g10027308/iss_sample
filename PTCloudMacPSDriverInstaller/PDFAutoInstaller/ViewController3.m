//
//  ViewController3.m
//  PDFAutoInstaller
//
//  Created by rits on 2021/2/23.
//  Copyright © 2021 rits. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "ViewController3.h"
#import "RIPDFInstaller.h"
#import "CHttpClient.h"
//#import "SettingWindow.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <pwd.h>

static NSString *STRVIEWTITLE = @"PS Basic Driver";
BOOL bRunThread = TRUE;

@interface ViewController3 ()

@end

@implementation ViewController3

@synthesize PrinterName = _PrinterName;
@synthesize OpenLoginURL = _OpenLoginURL;



- (WKWebView *)myWebView
{
    if (_myWebView == nil)
    {
        WKWebViewConfiguration*configuration=[[WKWebViewConfiguration alloc]init];
//        // 设置偏好设置
//        configuration.preferences = [[WKPreferences alloc] init];
//        configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        // 默认认为YES
//        configuration.preferences.javaScriptEnabled = YES;
//        configuration.userContentController = [[WKUserContentController alloc] init];
        // web内容处理池
        //configuration.processPool = [[WKProcessPool alloc]init];

        _myWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        //_myWebView.frame = self.view.bounds;
        
        _myWebView.UIDelegate = self;
        _myWebView.navigationDelegate = self;
        //_myWebView.allowsBackForwardNavigationGestures = YES;
        
    }
    return _myWebView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self setTitle:self.PrinterName];
    [self.view addSubview:self.myWebView];
    
    [self clearCookies];
    
    // OpenURL
    NSString *urlString = self.OpenLoginURL;
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
}

-(NSString *) getloginUser{
    uid_t current_user_id = getuid();
    struct passwd *pwentry = getpwuid(current_user_id);
    char *loginUser = pwentry->pw_name;
    NSString *loginName = [[NSString alloc] initWithUTF8String:loginUser];
    return loginName;
}

- (void)webView:(WKWebView *)webView
didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"didReceiveServerRedirectionForProvisionalNavigation");
    NSLog(@"%@",webView.URL.absoluteString);
    if ([webView.URL.absoluteString isLike:[NSString stringWithFormat:@"%@*", [self getInitConfigValue:@"redirecturi"]]]) {
        NSArray *arr = [webView.URL.absoluteString componentsSeparatedByString:@"#code="];
        NSString *code = arr[1];
        NSLog(@"%@",code);
        if ([self.view.identifier isEqualToString:@"secondView"]) {
            [self.view.window close];
        }
        [self.Delegate passValue:code];
    }
}

/// ページの読み込み完了時に呼ばれる
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"Did Finish");
}
/*
// 页面加载完成之后调用 4
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSString *failureUrl = [self getInitConfigValue:@"failureUrl"];
    NSString *currentURL = [self.myWebView.URL absoluteString];
    NSLog(@"didFinishNavigation:%@", currentURL);
    
    //取出cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //js函数
    NSString *JSFuncString =
    @"function setCookie(name,value,expires)\
    {\
    var oDate=new Date();\
    oDate.setDate(oDate.getDate()+expires);\
    document.cookie=name+'='+value+';expires='+oDate+';path=/'\
    }\
    function getCookie(name)\
    {\
    var arr = document.cookie.match(new RegExp('(^| )'+name+'=({FNXX==XXFN}*)(;|$)'));\
    if(arr != null) return unescape(arr[2]); return null;\
    }\
    function delCookie(name)\
    {\
    var exp = new Date();\
    exp.setTime(exp.getTime() - 1);\
    var cval=getCookie(name);\
    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
    }";
    //拼凑js字符串
    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        [JSCookieString appendString:excuteJSString];
    }
    //执行js
    [self.myWebView evaluateJavaScript:JSCookieString completionHandler:^(id obj, NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];
    
    // 监视APISID获取
   
    WKHTTPCookieStore *cookieStore = self.myWebView.configuration.websiteDataStore.httpCookieStore;
    [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
        //NSLog(@"All cookies %@",cookies);
        bool bFinded = false;
        NSString *CookiesString;
        for (NSHTTPCookie *cookie in cookies)
        {
            if ([cookie.name isEqualToString:@"APISID"]) {
                bFinded = true;
                CookiesString = [NSString stringWithFormat:@"#HttpOnly_%@\tTRUE\t/\tTRUE\t0\t%@\t%@\r\n", cookie.domain, cookie.name, cookie.value];
            }
        }
        
        // 找到后保存Cookiet并回调主界面继续处理
        if(bFinded == true){
            NSString *loginName = [self getloginUser];
            NSString *cookiesName = [NSString stringWithFormat:@"/private/tmp/cookies_na_portal_%@.txt",loginName];
            const char *cookies = [cookiesName UTF8String];
            // 保存Cookie
            FILE *fp = fopen(cookies, "wb");
            //FILE *fp = fopen("/private/tmp/cookies_na_portal.txt", "wb");
            
            fwrite([CookiesString UTF8String],strlen([CookiesString UTF8String]), sizeof(char),fp);

            fclose(fp);
            
            // 找到并关掉自己
            if ([self.view.identifier isEqualToString:@"secondView"]) {
                [self.view.window close];
            }
            // 回调继续安装处理
            [self.Delegate passValue:cookiesName];
            //[self.Delegate passValue:@"/private/tmp/cookies_na_portal.txt"];
            
        }
    }];
    
    if([currentURL containsString:failureUrl]){
        if ([self.getPreferredLanguage containsString:@"ja"]){
            NSLog(@"[ERROR] invalid URL");
            [self showHtml:@"LoginFailed_2nd"];
            return;
        }
        else {
            NSLog(@"[ERROR] invalid URL");
            [self showHtml:@"LoginFailed_1st"];
            return;
        }
    }
    
//    if([currentURL containsString:failureUrl]){
//        if ([self.getPreferredLanguage containsString:@"en"]){
//            NSLog(@"[ERROR] invalid URL");
//            [self showHtml:@"LoginFailed_1st"];
//            return;
//        }
//        else {
//            NSLog(@"[ERROR] invalid URL");
//            [self showHtml:@"LoginFailed_2nd"];
//            return;
//        }
//    }
}
*/
-(NSString*)getPreferredLanguage {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    NSLog(@"Preferred Language:%@", preferredLang);
    return preferredLang;
}


-(void) showHtml:(NSString *) strHtmlFileName{
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"LoginFailed_1st" ofType:@"htm" inDirectory:@"html"];
    NSString *path = [[NSBundle mainBundle] pathForResource:strHtmlFileName ofType:@"htm" inDirectory:@"html"];
    if(path == nil || [path isEqualToString:@""])
    {
        return;
    }
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    [self.myWebView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败");
}


- (void)clearCookies{
    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                         for (WKWebsiteDataRecord *record  in records)
                         {
                             //                             if ( [record.displayName containsString:@"baidu"]) //取消备注，可以针对某域名清除，否则是全清
                             //                             {
                             [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                       forDataRecords:@[record]
                                                                    completionHandler:^{
                                                                        NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                    }];
                             //                             }
                         }
                     }];
    
}

-(void) prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    NSViewController *send = segue.destinationController;
    if([send respondsToSelector:@selector(setPrinterName:)]){
        //[send setValue:self.PrinterName forKey:@"printerName"];
    }
    if([send respondsToSelector:@selector(setDingUID:)]){
        //[send setValue:self.DingUID forKey:@"dingUID"];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}


//
- (NSString *)getInitConfigValue: (NSString *) strConfigName {
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:INITCONFIG ofType:@"plist"];
    NSMutableDictionary *dicSetting = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSString *strValue = @"";
    if(nil != dicSetting){
        strValue = [dicSetting objectForKey:strConfigName];
        if(nil == strValue){
            if([strConfigName isEqualToString:@"ProxyPort"]){
                strValue = @"8080";
            }else if([strConfigName isEqualToString:@"ServerPort"] || [strConfigName isEqualToString:@"LocalServerPort"]){
                strValue = @"80";
            }else if([strConfigName isEqualToString:@"UseHttps"]){
                strValue = @"1";
            }else if([strConfigName isEqualToString:@"UseHttpsForLocalServer"]){
                strValue = @"0";
            }else if([strConfigName isEqualToString:@"UseProxy"] || [strConfigName isEqualToString:@"UseLocalServer"]){
                strValue = @"0";
            }else if([strConfigName isEqualToString:@"ProxyIP"]){
                strValue = @"0";
            }else{
                strValue = @"";
            }
        }
    }
    
    return strValue;
}

// 嵌套对象转为纯字符串
-(NSString*)changeDicArrayToString:(NSArray<NSDictionary*>*)array{
    
    NSMutableArray*mutiArray=@[].mutableCopy;
    for (NSDictionary*dic in array) {
        NSMutableDictionary*mutiDic=[NSMutableDictionary dictionaryWithDictionary:dic];
        mutiDic[@"name"]=[mutiDic[@"name"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [mutiArray addObject:mutiDic];
    }
    
    NSData*data=[NSJSONSerialization dataWithJSONObject:mutiArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString*jsonStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonStr];
    NSRange range = {0,jsonStr.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

@end
