//
//  ViewController3.h
//  PDFAutoInstaller
//
//  Created by rits on 2021/2/23.
//  Copyright © 2021 rits. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "SacnQRCode.h"

NS_ASSUME_NONNULL_BEGIN

@protocol View3Delegate
// 协议中的方法
- (void)passValue:(NSString *)value;
@end

@interface ViewController3 : NSViewController <WKUIDelegate, WKNavigationDelegate>
{
    NSString *_PrinterName;
    NSString *_OpenLoginURL;
}

@property NSString *PrinterName;
@property NSString *OpenLoginURL;

@property (nonatomic, strong) WKWebView *myWebView;

@property (weak) id Delegate;

@end

NS_ASSUME_NONNULL_END
