//
//  LoginWindow.m
//  PDFAutoInstaller
//
//  Created by rits on 2021/2/23.
//  Copyright © 2021 rits. All rights reserved.
//

#import "LoginWindow.h"

@interface LoginWindow ()

@end

@implementation LoginWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    
    
    //NSString *urlString = @"https://www.baidu.com";
    NSString *urlString = self.strOpenURL;
    [[self.myWebView  mainFrame ] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
    // 线程监控页面变化
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(checkUrlChange:) object:@"alloc"];
    //start the thread
    [thread start];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (void)checkUrlChange:(id)obj {
    NSLog(@"input parameter => %@", obj);
    NSLog(@"hello %@", [NSThread currentThread]);
    
    //NSString *strHttp = [self getHttpString];
    //NSString *strServerIPAddress = [self getServerIPAddress];
    //NSString *strCorpName = [self getCorpName];
    
//    NSString *urlStringOriginal = [NSString stringWithFormat:@"%@://%@/QRCodeLogin?cname=%@", self.strHttp, self.strServerIPAddress, self.strCorpName];
//
//    while(1){
//        sleep(2);
//        NSString *url = [self.myWKWebView.URL absoluteString];
//        //NSLog(@"URL: %@", url);
//        //NSComparisonResult result = [url compare:urlStringOriginal];
//        NSComparisonResult result = [url compare:urlStringOriginal];
//        if(NSOrderedSame != result){
//            NSRange rangeDingTalk = [url rangeOfString:@"oapi.dingtalk.com"];
//            if(0 != rangeDingTalk.length)
//                continue;
//
//            NSRange rangeBeforeCode = [url rangeOfString:@"?code="];
//            NSRange rangeAfterCode = [url rangeOfString:@"&state="];
//
//            if(0 == rangeBeforeCode.length || 0 == rangeAfterCode.length){
//                NSLog(@"[ERROR] invalid URL");
//                [self showHtml:@"LoginFailed_1st"];
//                return;
//            }else{
//                NSRange tmpCodeRange;
//                tmpCodeRange.location = rangeBeforeCode.location + rangeBeforeCode.length;
//                tmpCodeRange.length = rangeAfterCode.location - tmpCodeRange.location;
//
//                NSString *tmpCode = [url substringWithRange:tmpCodeRange];
//                //URL changed
//                [self getUserIDForDingPrint: tmpCode];
//            }
//            break;
//        }
//    }
    
}

//加载完成
- (void)myWebView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
    NSLog(@"~~~~~加载完成~~~~~");
}

@end
