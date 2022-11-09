//
//  ViewController.h
//  PDFAutoInstaller
//
//  Created by rits on 2018/06/06.
//  Copyright © 2018 rits. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "SacnQRCode.h"
#import "showHelpHowToGetUID.h"
//#import "SettingWindow.h"

@interface ViewController : NSViewController
{
    NSString *_PrinterName;
    NSString *_Passwd;
    NSString *_UserName;
    NSString *_UserAccount;
    NSString *_DistributedIP;
    NSString *_DistributedIPPort;
    NSBundle *UIBundle;
}
@property (strong) showHelpHowToGetUID *showHelpWindow;
//@property (strong) SettingWindow *settingWindow;
@property NSString *PrinterName;
@property NSString *Passwd;
@property NSArray *strAppID;      //第0步获得(post方式)
@property NSArray *strAppSecret;  //第0步获得(post方式)
@property NSArray *strToken;      //第0步获得(post方式)
@property NSArray *strCorpID;     //第0步获得(post方式)
@property NSArray *strCorpSecret; //第0步获得(post方式)

// UI Items' Title
@property (weak) IBOutlet NSTextField *lblPrinterDesc;
/**
@property (weak) IBOutlet NSBox *lblServerSettingGroup;
@property (weak) IBOutlet NSButton *btnChkHttps;//Use Https
@property (weak) IBOutlet NSTextField *lblServerPort;
**/
@property (weak) IBOutlet NSBox *lblProxySettings;
@property (weak) IBOutlet NSButton *btnChkProxy;// Use Proxy
@property (weak) IBOutlet NSTextField *lblProxyIP;
@property (weak) IBOutlet NSTextField *lblProxyPort;
@property (weak) IBOutlet NSTextField *lblUserName;
@property (weak) IBOutlet NSTextField *lblPasswd;

@property (weak) IBOutlet NSBox *lblAuthenticationGroup;
@property (weak) IBOutlet NSTextField *lblMail;
@property (weak) IBOutlet NSTextField *lblMailPasswd;

@property (weak) IBOutlet NSButton *btnTestConnect;


@property (weak) IBOutlet NSButton *buttonOkay;
@property (weak) IBOutlet NSButton *buttonCancel;

//@property (weak) IBOutlet WebView *myWebView;
@property (weak) IBOutlet NSButton *btnInstall;
@property (weak) IBOutlet NSTextField *txtPortName;


//Proxy IP Address
@property (weak) IBOutlet NSTextField *txtFldProxyIP;
//Proxy Port Number
@property (weak) IBOutlet NSTextField *txtFldProxyPort;
@property (weak) IBOutlet NSTextField *lblProxyPortRange;

//UserName
@property (weak) IBOutlet NSTextField *txtFldUserName;
//Password
@property (weak) IBOutlet NSSecureTextField *txtFldPassword;

//Authentication
@property (weak) IBOutlet NSTextField *txtFldMail;
@property (weak) IBOutlet NSSecureTextField *txtFldMailPassword;


- (void)initWindow;
- (NSString *)getCorpName;
- (NSString *)getServerIPAddress;
- (NSString *)getServerIPAddress1;
- (NSString *)getServerIPAddress2;
- (NSString *)getServerIPAddress3;
- (NSString *)getServerIPAddress4;
- (NSString *)getServerPort;
- (NSString *)getUseHttps;
- (NSString *)getHttpString;
- (NSString *)getUseProxy;
- (NSString *)getProxyIPAddress;
- (NSString *)getProxyPort;
- (NSString *)getUserName;
- (NSString *)getPassword;
- (NSString *)getUseLocalServer;
- (NSString *)getUseHttpsForLocalServer;
- (NSString *)getLocalServerIPAddress;
- (NSString *)getLocalServerIPAddress1;
- (NSString *)getLocalServerIPAddress2;
- (NSString *)getLocalServerIPAddress3;
- (NSString *)getLocalServerIPAddress4;
- (NSString *)getLocalServerPort;

- (NSString *)getloginUser;

- (NSString *)getWritePreferenceDirectory;














@end

