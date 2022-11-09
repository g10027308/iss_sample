//
//  SettingWindow.h
//  PDFAutoInstallerForDingPrint
//
//  Created by rits on 6/25/18.
//  Copyright © 2018 rits. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//config file name (".plist" included)
//static NSString *CONFIGPLIST = @"com.rits.PdfDriverInstaller.plist";
//initial config file name (".plist" not included)
static NSString *INITCONFIG = @"InitConfig";

@interface SettingWindow : NSWindowController

//Corporation Name
@property (weak) IBOutlet NSTextField *txtFldCorpName;

//Printer Server IP Address
@property (weak) IBOutlet NSTextField *txtFldServerIP1;
@property (weak) IBOutlet NSTextField *txtFldServerIP2;
@property (weak) IBOutlet NSTextField *txtFldServerIP3;
@property (weak) IBOutlet NSTextField *txtFldServerIP4;
//Server Port Number
@property (weak) IBOutlet NSTextField *txtFldServerPort;

//Use Https
@property (weak) IBOutlet NSButton *btnChkHttps;

//Use Proxy
@property (weak) IBOutlet NSButton *btnChkProxy;

//Proxy IP Address
@property (weak) IBOutlet NSTextField *txtFldProxyIP1;
@property (weak) IBOutlet NSTextField *txtFldProxyIP2;
@property (weak) IBOutlet NSTextField *txtFldProxyIP3;
@property (weak) IBOutlet NSTextField *txtFldProxyIP4;
//Proxy Port Number
@property (weak) IBOutlet NSTextField *txtFldProxyPort;
//UserName
@property (weak) IBOutlet NSTextField *txtFldUserName;
//Password
@property (weak) IBOutlet NSSecureTextField *txtFldPassword;

//Use Local Server
@property (weak) IBOutlet NSButton *btnChkLocalServer;
//Printer Local Server IP Address
@property (weak) IBOutlet NSTextField *txtFldLocalServerIP1;
@property (weak) IBOutlet NSTextField *txtFldLocalServerIP2;
@property (weak) IBOutlet NSTextField *txtFldLocalServerIP3;
@property (weak) IBOutlet NSTextField *txtFldLocalServerIP4;
//Local Server Port Number
@property (weak) IBOutlet NSTextField *txtFldLocalServerPort;
//Use Https For Local Server
@property (weak) IBOutlet NSButton *btnChkHttpsForLocalServer;


@property (weak) IBOutlet NSButton *btnOK;
@property (weak) IBOutlet NSButton *btnCancel;

+ (NSString *)getCorpName;
+ (NSString *)getServerIPAddress;
+ (NSString *)getServerIPAddress1;
+ (NSString *)getServerIPAddress2;
+ (NSString *)getServerIPAddress3;
+ (NSString *)getServerIPAddress4;
+ (NSString *)getServerPort;
+ (NSString *)getUseHttps;
+ (NSString *)getHttpString;
+ (NSString *)getUseProxy;
+ (NSString *)getProxyIPAddress;
+ (NSString *)getProxyIPAddress1;
+ (NSString *)getProxyIPAddress2;
+ (NSString *)getProxyIPAddress3;
+ (NSString *)getProxyIPAddress4;
+ (NSString *)getProxyPort;
+ (NSString *)getUserName;
+ (NSString *)getPassword;
+ (NSString *)getUseLocalServer;
+ (NSString *)getUseHttpsForLocalServer;
+ (NSString *)getLocalServerIPAddress;
+ (NSString *)getLocalServerIPAddress1;
+ (NSString *)getLocalServerIPAddress2;
+ (NSString *)getLocalServerIPAddress3;
+ (NSString *)getLocalServerIPAddress4;
+ (NSString *)getLocalServerPort;
+ (NSString *)getDingUID;

+ (NSString *)getWritePreferenceDirectory;

@end
