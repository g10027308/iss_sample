//
//  LoginWindow.h
//  PDFAutoInstaller
//
//  Created by rits on 2021/2/23.
//  Copyright © 2021 rits. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginWindow : NSWindowController

@property(nonatomic, copy) NSString *strOpenURL;

@property (weak) IBOutlet WebView *myWebView;

@end

NS_ASSUME_NONNULL_END
