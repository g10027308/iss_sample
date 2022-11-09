//
//  SacnQRCode.h
//  PDFAutoInstallerForDingPrint
//
//  Created by rits on 2018/11/07.
//  Copyright © 2018年 rits. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


static NSString *INITCONFIG = @"InitConfig";
//static NSString *CONFIGPLIST = @"com.rits.PdfDriverInstaller.plist";

@interface SacnQRCode : NSWindowController
{
    NSString *_UserID;
    NSString *_DingUID;
    NSTextField *_viewUserName;
    NSTextField *_viewUserID;
    NSButton *_btnScanQRCode;
    
    //NSString *_strUrl10;
    NSString *_strHttp;
    NSString *_strServerIPAddress;
    NSString *_strCorpName;
    NSString *_strUseProxy;
    NSString *_strProxyIPAddressAndPort;
    NSString *_strUserNameAndPassword;
}

//@property NSString *strUrl10;
@property NSString *strHttp;
@property NSString *strServerIPAddress;
@property NSString *strCorpName;
@property NSString *strUseProxy;
@property NSString *strProxyIPAddressAndPort;
@property NSString *strUserNameAndPassword;

@property NSTextField *viewUserName;
@property NSTextField *viewUserID;
@property NSButton *btnScanQRCode;
@property NSString *UserID;
@property NSString *DingUID;
@property NSArray *strAppID;      //第0步获得(post方式)
@property NSArray *strAppSecret;  //第0步获得(post方式)
@property NSArray *strToken;      //第0步获得(post方式)
@property NSArray *strCorpID;     //第0步获得(post方式)
@property NSArray *strCorpSecret; //第0步获得(post方式)
@property (weak) IBOutlet NSTextField *lblUserID;

@property (weak) IBOutlet NSTextField *DescptInfor;

@property (weak) IBOutlet WKWebView *myWKWebView;

@property (weak) IBOutlet NSTextField *txtUserID;


@property (weak) IBOutlet NSButton *btnScanAgain;

@property (weak) IBOutlet NSButton *btnOk;


@end
