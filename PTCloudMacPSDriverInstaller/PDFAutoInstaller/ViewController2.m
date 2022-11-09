//
//  ViewController2.m
//  PDFAutoInstaller
//
//  Created by rits on 2018/06/06.
//  Copyright © 2018 rits. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "ViewController2.h"
#import "RIPDFInstaller.h"
#import "SettingWindow.h"

#include <sys/types.h>
#include <pwd.h>


//static NSString *STRINSTALLING = @"Printer installing...";
//static NSString *STRINSTALLSUCCESS = @"Printer install success!";
//static NSString *STRINSTALLFAIL = @"Printer install Fail!!!";
//static NSString *STRBUTTONFINISH = @"Finish";
static NSString *STRVIEWTITLE = @"PS Basic Driver";
//static NSString *STRINSTALLING = @"正在安装打印机驱动...";
//static NSString *STRINSTALLSUCCESS = @"安装成功。";
//static NSString *STRINSTALLFAIL = @"安装失败！！！";
//static NSString *STRBUTTONFINISH = @"完成";

@implementation ViewController2
{
    RIPrinterInstaller * printerInstaller;
    NSString *printerName;
    NSString *UrlProtocol;
}

@synthesize UserID = _UserID;
@synthesize DingUID = _DingUID;
@synthesize PrinterName = _PrinterName;

- (instancetype)init
{
    self = [super init];
    if (self!=nil) {
        printerInstaller = [[RIPrinterInstaller alloc] init];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self!=nil) {
        printerInstaller = [[RIPrinterInstaller alloc] init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self!=nil) {
        printerInstaller = [[RIPrinterInstaller alloc] init];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    printerName = [[NSString alloc]init];
    UrlProtocol = [[NSString alloc]init];
    //Show installing statues control, and hide userID relate controls
    [_buttonFinish setEnabled:NO];
    self.lblInstallInfor.stringValue = NSLocalizedString(@"InforInstallingDriver", nil);
    [self.installProgress startAnimation:nil];
    [self setTitle:STRVIEWTITLE];
    [_buttonFinish setTitle:NSLocalizedString(@"TitlButtonFinish", nil)];
    //printerInstaller = [[RIPrinterInstaller alloc] init];

}

-(void)installPkg{
    //save DingUID to "tmp" folder
    //[self saveDingUIDToConfigPlist:self.DingUID];
    
    //Install PKG and printer, and copy Plist form "tmp" folder to "~/Library/Preferences/" and "/Library/Preferences/"
    BOOL bRet = [printerInstaller runShellInstallPkg:self.UserID PrinterName:printerName Url:UrlProtocol];
    
    if(bRet == YES)
    {
        _lblInstallInfor.stringValue = NSLocalizedString(@"InforInstallSuccess", nil);
    }
    else
    {
        _lblInstallInfor.stringValue = NSLocalizedString(@"InforInstallFail", nil);
    }
    
    [_installProgress stopAnimation:nil];
    [_installProgress setHidden:YES];
    [_buttonFinish setEnabled:YES];
}

-(void)viewDidAppear{
    // Printer name and protocol
    printerName = self.PrinterName;
    //printerName = @"DingPrinter";
    //UrlProtocol = @"http://172.25.74.108/macPrint";
    //UrlProtocol = @"http://101.132.37.166/macPrint";
    
    //NSString *strHttp = [SettingWindow getHttpString];
    //NSString *strServerIPAddress = [SettingWindow getServerIPAddress];
    //UrlProtocol = [NSString stringWithFormat:@"%@://%@/macPrint", strHttp, strServerIPAddress];
    
    UrlProtocol = @"print2server:/";
    
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(installPkg) object:nil];
    [thread start];
}

- (IBAction)cliackButtonFinish:(id)sender {
#if SHOW_INSTALL_BTN
    [[NSApplication sharedApplication] terminate:self];
#else
    [self.view.window close];
#endif
}

//save DingUID to config file in folder "/tmp/"
//should copy the config in folder "/tmp/" to User folder "~/Library/Preferences/" and root folder "/Library/Preferences/"
- (void)saveDingUIDToConfigPlist:(NSString*)strUserId {
    NSString *prePath = [SettingWindow getWritePreferenceDirectory];
    NSLog(@"prePath = %@", prePath);
    
    uid_t current_user_id = getuid();
    struct passwd *pwentry = getpwuid(current_user_id);
    char *loginUser = pwentry->pw_name;
    //char *loginUser = getlogin();
    NSString *loginName = [[NSString alloc] initWithUTF8String:loginUser];
    NSString *plistName = [NSString stringWithFormat:@"com.rits.PdfDriverInstaller_%@.plist",loginName];
    NSString *plistPath = [prePath stringByAppendingString:plistName];
    //NSString *plistPath = [prePath stringByAppendingString:CONFIGPLIST];
    
    //NSMutableDictionary *dicSetting = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSMutableDictionary *dicSetting = [[NSMutableDictionary alloc] init];
    NSLog(@"dicSetting = %@", dicSetting);
    
    
    
    NSString * strCorpName = [SettingWindow getCorpName];
    NSString * strServerIPAddress1 = [SettingWindow getServerIPAddress1];
    NSString * strServerIPAddress2 = [SettingWindow getServerIPAddress2];
    NSString * strServerIPAddress3 = [SettingWindow getServerIPAddress3];
    NSString * strServerIPAddress4 = [SettingWindow getServerIPAddress4];
    NSString * strServerPort = [SettingWindow getServerPort];
    NSString * strUseHttps = [SettingWindow getUseHttps];
    
    NSString * strUseProxy = [SettingWindow getUseProxy];
    NSString * strProxyIPAddress1 = [SettingWindow getProxyIPAddress1];
    NSString * strProxyIPAddress2 = [SettingWindow getProxyIPAddress2];
    NSString * strProxyIPAddress3 = [SettingWindow getProxyIPAddress3];
    NSString * strProxyIPAddress4 = [SettingWindow getProxyIPAddress4];
    NSString * strProxyPort = [SettingWindow getProxyPort];
    NSString * strUserName = [SettingWindow getUserName];
    NSString * strPassword = [SettingWindow getPassword];
    
    NSString * strUseLocalServer = [SettingWindow getUseLocalServer];
    NSString * strUseHttpsForLocalServer = [SettingWindow getUseHttpsForLocalServer];
    NSString * strLocalServerIPAddress1 = [SettingWindow getLocalServerIPAddress1];
    NSString * strLocalServerIPAddress2 = [SettingWindow getLocalServerIPAddress2];
    NSString * strLocalServerIPAddress3 = [SettingWindow getLocalServerIPAddress3];
    NSString * strLocalServerIPAddress4 = [SettingWindow getLocalServerIPAddress4];
    NSString * strLocalServerPort = [SettingWindow getLocalServerPort];
    
    
    [dicSetting setObject:strCorpName forKey:@"CorpName"];
    
    [dicSetting setObject:strServerIPAddress1 forKey:@"ServerIP1"];
    [dicSetting setObject:strServerIPAddress2 forKey:@"ServerIP2"];
    [dicSetting setObject:strServerIPAddress3 forKey:@"ServerIP3"];
    [dicSetting setObject:strServerIPAddress4 forKey:@"ServerIP4"];
    [dicSetting setObject:strServerPort forKey:@"ServerPort"];
    
    [dicSetting setObject:strUseHttps forKey:@"UseHttps"];
    
    [dicSetting setObject:strUseProxy forKey:@"UseProxy"];
    [dicSetting setObject:strProxyIPAddress1 forKey:@"ProxyIP1"];
    [dicSetting setObject:strProxyIPAddress2 forKey:@"ProxyIP2"];
    [dicSetting setObject:strProxyIPAddress3 forKey:@"ProxyIP3"];
    [dicSetting setObject:strProxyIPAddress4 forKey:@"ProxyIP4"];
    [dicSetting setObject:strProxyPort forKey:@"ProxyPort"];
    [dicSetting setObject:strUserName forKey:@"UserName"];
    [dicSetting setObject:strPassword forKey:@"Password"];
    
    [dicSetting setObject:strUseLocalServer forKey:@"UseLocalServer"];
    [dicSetting setObject:strUseHttpsForLocalServer forKey:@"UseHttpsForLocalServer"];
    [dicSetting setObject:strLocalServerIPAddress1 forKey:@"LocalServerIP1"];
    [dicSetting setObject:strLocalServerIPAddress2 forKey:@"LocalServerIP2"];
    [dicSetting setObject:strLocalServerIPAddress3 forKey:@"LocalServerIP3"];
    [dicSetting setObject:strLocalServerIPAddress4 forKey:@"LocalServerIP4"];
    [dicSetting setObject:strLocalServerPort forKey:@"LocalServerPort"];
    
    [dicSetting setObject:strUserId forKey:@"DingUID"];
    
    //save the setting to /tmp/Preferences/com.rits.PdfDriverInstaller.plist
    [dicSetting writeToFile:plistPath atomically:YES];
    
    NSLog(@"dicSetting = %@", dicSetting);
    
    
    /*
    RIPrinterInstaller * printerInstaller = [[RIPrinterInstaller alloc] init];
    //Copy plist from /tmp/ to /Library/Preferences/ and ~/Library/Preferences/
    BOOL bRet = [printerInstaller runShellCopyPlist];
    
    if(bRet == YES)
    {
        NSLog(@"[saveDingUIDToConfigPlist] Succeeded to copy file com.rits.PdfDriverInstaller.plist to /Library/Preferences/ and ~/Library/Preferences/ .");
    }
    else
    {
        NSLog(@"[saveDingUIDToConfigPlist] Failed to copy file com.rits.PdfDriverInstaller.plist to /Library/Preferences/ and ~/Library/Preferences/ .");
    }
    */
}



@end
