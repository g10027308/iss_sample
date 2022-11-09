//
//  SettingWindow.m
//  PDFAutoInstallerForDingPrint
//
//  Created by rits on 6/25/18.
//  Copyright © 2018 rits. All rights reserved.
//

#import "SettingWindow.h"
#import "RIPDFInstaller.h"
#import "CHttpClient.h"

#include <sys/types.h>
#include <pwd.h>


@interface SettingWindow ()

@end

@implementation SettingWindow
{
    RIPrinterInstaller * printerInstaller;
}

/*
- (instancetype)init
{
    self = [super init];
    if (self!=nil) {
        printerInstaller = [[RIPrinterInstaller alloc] init];
    }
    return self;
}
 */

- (void)windowDidLoad {
    [super windowDidLoad];
    //[self.window setReleasedWhenClosed:YES];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

    self.txtFldCorpName.stringValue = [SettingWindow getCorpName];
    self.txtFldServerIP1.stringValue = [SettingWindow getServerIPAddress1];
    self.txtFldServerIP2.stringValue = [SettingWindow getServerIPAddress2];
    self.txtFldServerIP3.stringValue = [SettingWindow getServerIPAddress3];
    self.txtFldServerIP4.stringValue = [SettingWindow getServerIPAddress4];
    self.txtFldServerPort.stringValue = [SettingWindow getServerPort];
    
    //hidden cancle button
    [self.btnCancel setHidden:YES];
    
    NSString *strUseHttps = [SettingWindow getUseHttps];
    if(NSOrderedSame == [strUseHttps compare:@"0"]){
        self.btnChkHttps.state = NO;
    }else{
        self.btnChkHttps.state = YES;
    }
    
    NSString *strUseProxy = [SettingWindow getUseProxy];;
    if(NSOrderedSame == [strUseProxy compare:@"0"]){
        self.btnChkProxy.state = NO;
    }else{
        self.btnChkProxy.state = YES;
    } 
    
    self.txtFldProxyIP1.stringValue = [SettingWindow getProxyIPAddress1];
    self.txtFldProxyIP2.stringValue = [SettingWindow getProxyIPAddress2];
    self.txtFldProxyIP3.stringValue = [SettingWindow getProxyIPAddress3];
    self.txtFldProxyIP4.stringValue = [SettingWindow getProxyIPAddress4];
    self.txtFldProxyPort.stringValue = [SettingWindow getProxyPort];
    self.txtFldUserName.stringValue = [SettingWindow getUserName];
    self.txtFldPassword.stringValue = [SettingWindow getPassword];
    
    NSString *strUseLocalServer = [SettingWindow getUseLocalServer];
    if(NSOrderedSame == [strUseLocalServer compare:@"0"]){
        self.btnChkLocalServer.state = NO;
    }else{
        self.btnChkLocalServer.state = YES;
    }
    
    NSString *strUseHttpsForLocalServer = [SettingWindow getUseHttpsForLocalServer];
    if(NSOrderedSame == [strUseHttpsForLocalServer compare:@"0"]){
        self.btnChkHttpsForLocalServer.state = NO;
        self.txtFldLocalServerPort.enabled = YES;
    }else{
        self.btnChkHttpsForLocalServer.state = YES;
        self.txtFldLocalServerPort.enabled = NO;
    }
    self.txtFldLocalServerIP1.stringValue = [SettingWindow getLocalServerIPAddress1];
    self.txtFldLocalServerIP2.stringValue = [SettingWindow getLocalServerIPAddress2];
    self.txtFldLocalServerIP3.stringValue = [SettingWindow getLocalServerIPAddress3];
    self.txtFldLocalServerIP4.stringValue = [SettingWindow getLocalServerIPAddress4];
    self.txtFldLocalServerPort.stringValue = [SettingWindow getLocalServerPort];
    
    printerInstaller = [[RIPrinterInstaller alloc] init];
}


- (void)controlTextDidChange:(NSNotification *)obj{
    NSTextField *txtFld = [obj object];
    //IP address: 0~255
    if ([txtFld.identifier hasPrefix:@"txtFldServerIP"] || [txtFld.identifier hasPrefix:@"txtFldLocalServerIP"] || [txtFld.identifier hasPrefix:@"txtFldProxyIP"]){
        NSUInteger txtLen = txtFld.stringValue.length;
        //only allow up to 3 characters (valid value: 0 ~ 255)
        if(txtLen > 3){
            txtFld.stringValue = [txtFld.stringValue substringToIndex:3];
        }
        
        //only allow characters: 0-9 (Arab numbers)
        int maxLen = (int)txtFld.stringValue.length;
        for(int index=maxLen-1; index>=0; index--){
            unichar aChar = [txtFld.stringValue characterAtIndex:index];
            if(!(aChar >= '0' && aChar <= '9')){
                txtFld.stringValue = [txtFld.stringValue substringToIndex:txtFld.stringValue.length-1];
            }
        }
        
        //if the number is bigger than 255, change it to 255
        int intValue = txtFld.intValue;
        if(intValue > 255){
            //txtFld.stringValue = @"255";
            txtFld.stringValue = NSLocalizedString(@"255", nil);
        }
    }
    //Port: 0~65535
    else if ([txtFld.identifier isEqualToString:@"txtFldServerPort"] || [txtFld.identifier isEqualToString:@"txtFldProxyPort"] || [txtFld.identifier isEqualToString:@"txtFldLocalServerPort"]){
        NSUInteger txtLen = txtFld.stringValue.length;
        //only allow up to 5 characters (valid value: 0 ~ 65535)
        if(txtLen > 5){
            txtFld.stringValue = [txtFld.stringValue substringToIndex:5];
        }
        
        //only allow characters: 0-9 (Arab numbers)
        int maxLen = (int)txtFld.stringValue.length;
        for(int index=maxLen-1; index>=0; index--){
            unichar aChar = [txtFld.stringValue characterAtIndex:index];
            if(!(aChar >= '0' && aChar <= '9')){
                txtFld.stringValue = [txtFld.stringValue substringToIndex:txtFld.stringValue.length-1];
            }
        }
        
        //if the number is bigger than 65535, change it to 65535
        int intValue = txtFld.intValue;
        if(intValue > 65535){
            //txtFld.stringValue = @"65535";
            txtFld.stringValue = NSLocalizedString(@"65535", nil);
        }
    }

}



-(BOOL)windowShouldClose:(NSWindow *)sender {
    //[self.window setReleasedWhenClosed:YES];
    return YES;
}


- (IBAction)clickCancelButton:(id)sender {
    [self close];
    
}


- (IBAction)clickOKButton:(id)sender {
    
    if(YES == [self.txtFldServerPort.stringValue isEqualToString:@""]){
        NSLog(@"[ERROR] Server port should not be blank.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
//        [alert setMessageText:@"云服务器端口错误"];
//        [alert setInformativeText:@"云服务器端口不可设置为空。"];
        [alert runModal];
        return;
    }
    
    if(YES == self.btnChkProxy.state && YES == [self.txtFldProxyPort.stringValue isEqualToString:@""]){
        NSLog(@"[ERROR] Proxy port should not be blank when \"Use Proxy\" is selected.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
//        [alert setMessageText:@"代理端口错误"];
//        [alert setInformativeText:@"当\"使用代理\"被勾选时，代理端口不可设置为空。"];
        [alert runModal];
        return;
    }
    
    if(YES == self.btnChkLocalServer.state && YES == [self.txtFldLocalServerPort.stringValue isEqualToString:@""]){
        NSLog(@"[ERROR] Local server port should not be blank when \"Use Local Server\" is selected.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
//        [alert setMessageText:@"本地服务器端口错误"];
//        [alert setInformativeText:@"当\"启用本地服务器\"被勾选时，本地服务器端口不可设置为空。"];
        [alert runModal];
        return;
    }
    
    if(YES == self.btnChkHttpsForLocalServer.state && NO == [self.txtFldLocalServerPort.stringValue isEqualToString:@"443"]){
        NSLog(@"[ERROR] Local server port should be 443 when \"Use Https\" is selected.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
//        [alert setMessageText:@"本地服务器端口错误"];
//        [alert setInformativeText:@"当\"使用HTTPS\"被勾选时，本地服务器端口需要设置为\"443\"。"];
        [alert runModal];
        return;
    }
    
    NSString *prePath = [SettingWindow getWritePreferenceDirectory];
    NSLog(@"prePath = %@", prePath);
    
    NSString *loginName = [self getloginUser];
    NSString *plistName = [NSString stringWithFormat:@"com.rits.PdfDriverInstaller_%@.plist",loginName];
    NSString *plistPath = [prePath stringByAppendingString:plistName];
    //NSString *plistPath = [prePath stringByAppendingString:CONFIGPLIST];
    
    //NSMutableDictionary *dicSetting = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSMutableDictionary *dicSetting = [[NSMutableDictionary alloc] init];
    NSLog(@"dicSetting = %@", dicSetting);
    
    [dicSetting setObject:self.txtFldCorpName.stringValue forKey:@"CorpName"];
    
    [dicSetting setObject:self.txtFldServerIP1.stringValue forKey:@"ServerIP1"];
    [dicSetting setObject:self.txtFldServerIP2.stringValue forKey:@"ServerIP2"];
    [dicSetting setObject:self.txtFldServerIP3.stringValue forKey:@"ServerIP3"];
    [dicSetting setObject:self.txtFldServerIP4.stringValue forKey:@"ServerIP4"];
    [dicSetting setObject:self.txtFldServerPort.stringValue forKey:@"ServerPort"];
    
    [dicSetting setObject:self.btnChkHttps.stringValue forKey:@"UseHttps"];
    
    [dicSetting setObject:self.btnChkProxy.stringValue forKey:@"UseProxy"];
    [dicSetting setObject:self.txtFldProxyIP1.stringValue forKey:@"ProxyIP1"];
    [dicSetting setObject:self.txtFldProxyIP2.stringValue forKey:@"ProxyIP2"];
    [dicSetting setObject:self.txtFldProxyIP3.stringValue forKey:@"ProxyIP3"];
    [dicSetting setObject:self.txtFldProxyIP4.stringValue forKey:@"ProxyIP4"];
    [dicSetting setObject:self.txtFldProxyPort.stringValue forKey:@"ProxyPort"];
    [dicSetting setObject:self.txtFldUserName.stringValue forKey:@"UserName"];
    [dicSetting setObject:self.txtFldPassword.stringValue forKey:@"Password"];
    
    [dicSetting setObject:self.btnChkLocalServer.stringValue forKey:@"UseLocalServer"];
    [dicSetting setObject:self.btnChkHttpsForLocalServer.stringValue forKey:@"UseHttpsForLocalServer"];
    [dicSetting setObject:self.txtFldLocalServerIP1.stringValue forKey:@"LocalServerIP1"];
    [dicSetting setObject:self.txtFldLocalServerIP2.stringValue forKey:@"LocalServerIP2"];
    [dicSetting setObject:self.txtFldLocalServerIP3.stringValue forKey:@"LocalServerIP3"];
    [dicSetting setObject:self.txtFldLocalServerIP4.stringValue forKey:@"LocalServerIP4"];
    [dicSetting setObject:self.txtFldLocalServerPort.stringValue forKey:@"LocalServerPort"];
    
    NSString * strDingUID = [SettingWindow getDingUID];
    [dicSetting setObject:strDingUID forKey:@"DingUID"];
    
    //save the setting to /tmp/Preferences/com.rits.PdfDriverInstaller.plist
    [dicSetting writeToFile:plistPath atomically:YES];

    NSLog(@"dicSetting = %@", dicSetting);
    
    //Copy plist from /tmp/ to /Library/Preferences/ and ~/Library/Preferences/
    BOOL bRet = [printerInstaller runShellCopyPlist];
    
    if(bRet == YES)
    {
        NSLog(@"Succeeded to copy file com.rits.PdfDriverInstaller.plist to /Library/Preferences/ and ~/Library/Preferences/ .");
    }
    else
    {
        NSLog(@"Failed to copy file com.rits.PdfDriverInstaller.plist to /Library/Preferences/ and ~/Library/Preferences/ .");
    }
    
    
    [self close];
    
}

-(NSString *) getloginUser{
    uid_t current_user_id = getuid();
    struct passwd *pwentry = getpwuid(current_user_id);
    char *loginUser = pwentry->pw_name;
    NSString *loginName = [[NSString alloc] initWithUTF8String:loginUser];
    return loginName;
}

+ (NSString *)getCorpName {
    NSString *strCorpName = [self getConfigValue:@"CorpName"];
    if(nil == strCorpName){
        //strCorpName = @"";
        strCorpName = [self getInitConfigValue:@"CorpName"];
    }
    
    return strCorpName;
}

+ (NSString *)getServerIPAddress1 {
    NSString *strServerIPAddress1 = [self getConfigValue:@"ServerIP1"];
    if(nil == strServerIPAddress1){
        strServerIPAddress1 = [self getInitConfigValue:@"ServerIP1"];
    }
    return strServerIPAddress1;
}

+ (NSString *)getServerIPAddress2 {
    NSString *strServerIPAddress2 = [self getConfigValue:@"ServerIP2"];
    if(nil == strServerIPAddress2){
        strServerIPAddress2 = [self getInitConfigValue:@"ServerIP2"];
    }
    return strServerIPAddress2;
}

+ (NSString *)getServerIPAddress3 {
    NSString *strServerIPAddress3 = [self getConfigValue:@"ServerIP3"];
    if(nil == strServerIPAddress3){
        strServerIPAddress3 = [self getInitConfigValue:@"ServerIP3"];
    }
    return strServerIPAddress3;
}

+ (NSString *)getServerIPAddress4 {
    NSString *strServerIPAddress4 = [self getConfigValue:@"ServerIP4"];
    if(nil == strServerIPAddress4){
        strServerIPAddress4 = [self getInitConfigValue:@"ServerIP4"];
    }
    return strServerIPAddress4;
}

+ (NSString *)getServerPort {
    NSString *strPort = [self getConfigValue:@"ServerPort"];
    if(nil == strPort){
        strPort = [self getInitConfigValue:@"ServerPort"];
    }
    
    return strPort;
}

+ (NSString *)getServerIPAddress {
    NSString *strServerIP = @"0.0.0.0:80";
    
    NSString *strServerIP1 = [self getConfigValue:@"ServerIP1"];
    NSString *strServerIP2 = [self getConfigValue:@"ServerIP2"];
    NSString *strServerIP3 = [self getConfigValue:@"ServerIP3"];
    NSString *strServerIP4 = [self getConfigValue:@"ServerIP4"];
    //NSString *strServerPort = [self getConfigValue:@"ServerPort"];
    
    //if(nil == strServerIP1 || nil == strServerIP2 || nil == strServerIP3 || nil == strServerIP4 || nil == strServerPort){
    if(nil == strServerIP1 || nil == strServerIP2 || nil == strServerIP3 || nil == strServerIP4){

        strServerIP = [self getInitServerIPAddress];
    }else{
        //strServerIP = [NSString stringWithFormat:@"%@.%@.%@.%@:%@", strServerIP1, strServerIP2, strServerIP3, strServerIP4, strServerPort];
        strServerIP = [NSString stringWithFormat:@"%@.%@.%@.%@", strServerIP1, strServerIP2, strServerIP3, strServerIP4];
    }

    return strServerIP;
}

+ (NSString *)getInitServerIPAddress {
    NSString *strServerIP = @"0.0.0.0:80";
    
    NSString *strServerIP1 = [self getInitConfigValue:@"ServerIP1"];
    NSString *strServerIP2 = [self getInitConfigValue:@"ServerIP2"];
    NSString *strServerIP3 = [self getInitConfigValue:@"ServerIP3"];
    NSString *strServerIP4 = [self getInitConfigValue:@"ServerIP4"];
    //NSString *strServerPort = [self getInitConfigValue:@"ServerPort"];
    
    //strServerIP = [NSString stringWithFormat:@"%@.%@.%@.%@:%@", strServerIP1, strServerIP2, strServerIP3, strServerIP4, strServerPort];
    strServerIP = [NSString stringWithFormat:@"%@.%@.%@.%@", strServerIP1, strServerIP2, strServerIP3, strServerIP4];
    
    return strServerIP;
}


+ (NSString *)getProxyIPAddress1 {
    NSString *strProxyIPAddress1 = [self getConfigValue:@"ProxyIP1"];
    if(nil == strProxyIPAddress1){
        strProxyIPAddress1 = [self getInitConfigValue:@"ProxyIP1"];
    }
    return strProxyIPAddress1;
}

+ (NSString *)getProxyIPAddress2 {
    NSString *strProxyIPAddress2 = [self getConfigValue:@"ProxyIP2"];
    if(nil == strProxyIPAddress2){
        strProxyIPAddress2 = [self getInitConfigValue:@"ProxyIP2"];
    }
    return strProxyIPAddress2;
}

+ (NSString *)getProxyIPAddress3 {
    NSString *strProxyIPAddress3 = [self getConfigValue:@"ProxyIP3"];
    if(nil == strProxyIPAddress3){
        strProxyIPAddress3 = [self getInitConfigValue:@"ProxyIP3"];
    }
    return strProxyIPAddress3;
}

+ (NSString *)getProxyIPAddress4 {
    NSString *strProxyIPAddress4 = [self getConfigValue:@"ProxyIP4"];
    if(nil == strProxyIPAddress4){
        strProxyIPAddress4 = [self getInitConfigValue:@"ProxyIP4"];
    }
    return strProxyIPAddress4;
}

+ (NSString *)getProxyIPAddress {
    NSString *strProxyIP = @"0.0.0.0";
    
    NSString *strProxyIP1 = [self getConfigValue:@"ProxyIP1"];
    NSString *strProxyIP2 = [self getConfigValue:@"ProxyIP2"];
    NSString *strProxyIP3 = [self getConfigValue:@"ProxyIP3"];
    NSString *strProxyIP4 = [self getConfigValue:@"ProxyIP4"];
    //NSString *strProxyPort = [self getConfigValue:@"ProxyPort"];
    
    //if(nil == strProxyIP1 || nil == strProxyIP2 || nil == strProxyIP3 || nil == strProxyIP4 || nil == strProxyPort){
    if(nil == strProxyIP1 || nil == strProxyIP2 || nil == strProxyIP3 || nil == strProxyIP4){
        strProxyIP = [self getInitProxyIPAddress];
    }else{
        //strProxyIP = [NSString stringWithFormat:@"%@.%@.%@.%@:%@", strProxyIP1, strProxyIP2, strProxyIP3, strProxyIP4, strProxyPort];
        strProxyIP = [NSString stringWithFormat:@"%@.%@.%@.%@", strProxyIP1, strProxyIP2, strProxyIP3, strProxyIP4];
    }
    
    return strProxyIP;
}

+ (NSString *)getInitProxyIPAddress {
    NSString *strProxyIP = @"0.0.0.0";
    
    NSString *strProxyIP1 = [self getInitConfigValue:@"ProxyIP1"];
    NSString *strProxyIP2 = [self getInitConfigValue:@"ProxyIP2"];
    NSString *strProxyIP3 = [self getInitConfigValue:@"ProxyIP3"];
    NSString *strProxyIP4 = [self getInitConfigValue:@"ProxyIP4"];
    //NSString *strProxyPort = [self getInitConfigValue:@"ProxyPort"];
    
    //strProxyIP = [NSString stringWithFormat:@"%@.%@.%@.%@:%@", strProxyIP1, strProxyIP2, strProxyIP3, strProxyIP4, strProxyPort];
    strProxyIP = [NSString stringWithFormat:@"%@.%@.%@.%@", strProxyIP1, strProxyIP2, strProxyIP3, strProxyIP4];
    
    return strProxyIP;
}


+ (NSString *)getProxyPort {
    NSString *strPort = [self getConfigValue:@"ProxyPort"];
    if(nil == strPort){
        strPort = [self getInitConfigValue:@"ProxyPort"];
    }
    
    return strPort;
}


+ (NSString *)getUserName {
    NSString *strUserName = [self getConfigValue:@"UserName"];
    if(nil == strUserName){
        strUserName = [self getInitConfigValue:@"UserName"];
    }
    
    return strUserName;
}


+ (NSString *)getPassword {
    NSString *strPassword = [self getConfigValue:@"Password"];
    if(nil == strPassword){
        strPassword = [self getInitConfigValue:@"Password"];
    }
    
    return strPassword;
}

+ (NSString *)getUseHttps {
    NSString *strUseHttps = [self getConfigValue:@"UseHttps"];
    if(nil == strUseHttps){
        strUseHttps = [self getInitConfigValue:@"UseHttps"];
    }
    
    return strUseHttps;
}

+ (NSString *)getHttpString {
    NSString *flag = [self getUseHttps];
    NSString *httpString = @"https";
    if ([flag isEqualToString:@"0"]){
        httpString = @"http";
    }
    return httpString;
}

+ (NSString *)getUseHttpsForLocalServer {
    NSString *strUseHttpsForLocalServer = [self getConfigValue:@"UseHttpsForLocalServer"];
    if(nil == strUseHttpsForLocalServer){
        strUseHttpsForLocalServer = [self getInitConfigValue:@"UseHttpsForLocalServer"];
    }
    
    return strUseHttpsForLocalServer;
}

+ (NSString *)getUseProxy {
    NSString *strUseProxy = [self getConfigValue:@"UseProxy"];
    if(nil == strUseProxy){
        strUseProxy = [self getInitConfigValue:@"UseProxy"];
    }
    
    return strUseProxy;
}


+ (NSString *)getLocalServerIPAddress1 {
    NSString *strLocalServerIPAddress1 = [self getConfigValue:@"LocalServerIP1"];
    if(nil == strLocalServerIPAddress1){
        strLocalServerIPAddress1 = [self getInitConfigValue:@"LocalServerIP1"];
    }
    return strLocalServerIPAddress1;
}

+ (NSString *)getLocalServerIPAddress2 {
    NSString *strLocalServerIPAddress2 = [self getConfigValue:@"LocalServerIP2"];
    if(nil == strLocalServerIPAddress2){
        strLocalServerIPAddress2 = [self getInitConfigValue:@"LocalServerIP2"];
    }
    return strLocalServerIPAddress2;
}

+ (NSString *)getLocalServerIPAddress3 {
    NSString *strLocalServerIPAddress3 = [self getConfigValue:@"LocalServerIP3"];
    if(nil == strLocalServerIPAddress3){
        strLocalServerIPAddress3 = [self getInitConfigValue:@"LocalServerIP3"];
    }
    return strLocalServerIPAddress3;
}

+ (NSString *)getLocalServerIPAddress4 {
    NSString *strLocalServerIPAddress4 = [self getConfigValue:@"LocalServerIP4"];
    if(nil == strLocalServerIPAddress4){
        strLocalServerIPAddress4 = [self getInitConfigValue:@"LocalServerIP4"];
    }
    return strLocalServerIPAddress4;
}

+ (NSString *)getLocalServerPort {
    NSString *strPort = [self getConfigValue:@"LocalServerPort"];
    if(nil == strPort){
        strPort = [self getInitConfigValue:@"LocalServerPort"];
    }
    
    return strPort;
}

+ (NSString *)getLocalServerIPAddress {
    //NSString *strLocalServerIP = @"0.0.0.0:80";
    NSString *strLocalServerIP = @"0.0.0.0";
    
    NSString *strLocalServerIP1 = [self getConfigValue:@"LocalServerIP1"];
    NSString *strLocalServerIP2 = [self getConfigValue:@"LocalServerIP2"];
    NSString *strLocalServerIP3 = [self getConfigValue:@"LocalServerIP3"];
    NSString *strLocalServerIP4 = [self getConfigValue:@"LocalServerIP4"];
    //NSString *strLocalServerPort = [self getConfigValue:@"LocalServerPort"];
    
    //if(nil == strLocalServerIP1 || nil == strLocalServerIP2 || nil == strLocalServerIP3 || nil == strLocalServerIP4 || nil == strLocalServerPort){
    if(nil == strLocalServerIP1 || nil == strLocalServerIP2 || nil == strLocalServerIP3 || nil == strLocalServerIP4){
        strLocalServerIP = [self getInitLocalServerIPAddress];
    }else{
        //strLocalServerIP = [NSString stringWithFormat:@"%@.%@.%@.%@:%@", strLocalServerIP1, strLocalServerIP2, strLocalServerIP3, strLocalServerIP4, strLocalServerPort];
        strLocalServerIP = [NSString stringWithFormat:@"%@.%@.%@.%@", strLocalServerIP1, strLocalServerIP2, strLocalServerIP3, strLocalServerIP4];
    }
    
    return strLocalServerIP;
}

+ (NSString *)getInitLocalServerIPAddress {
    //NSString *strLocalServerIP = @"0.0.0.0:80";
    NSString *strLocalServerIP = @"0.0.0.0";
    
    NSString *strLocalServerIP1 = [self getInitConfigValue:@"LocalServerIP1"];
    NSString *strLocalServerIP2 = [self getInitConfigValue:@"LocalServerIP2"];
    NSString *strLocalServerIP3 = [self getInitConfigValue:@"LocalServerIP3"];
    NSString *strLocalServerIP4 = [self getInitConfigValue:@"LocalServerIP4"];
    //NSString *strLocalServerPort = [self getInitConfigValue:@"LocalServerPort"];
    
    //strLocalServerIP = [NSString stringWithFormat:@"%@.%@.%@.%@:%@", strLocalServerIP1, strLocalServerIP2, strLocalServerIP3, strLocalServerIP4, strLocalServerPort];
    strLocalServerIP = [NSString stringWithFormat:@"%@.%@.%@.%@", strLocalServerIP1, strLocalServerIP2, strLocalServerIP3, strLocalServerIP4];
    
    return strLocalServerIP;
}

+ (NSString *)getUseLocalServer {
    NSString *strUseLocalServer = [self getConfigValue:@"UseLocalServer"];
    if(nil == strUseLocalServer){
        strUseLocalServer = [self getInitConfigValue:@"UseLocalServer"];
    }
    
    return strUseLocalServer;
}



+ (NSString *)getReadPreferenceDirectory {
    //PreferenceDirectory:    ~/Library/Preferences/
    NSString *prePath = NSHomeDirectory();
    prePath = [prePath stringByAppendingString:@"/Library/Preferences/"];
    
    //PreferenceDirectory:    /Library/Preferences/
    //NSString *prePath = @"/Library/Preferences/";
    
    return prePath;
}

+ (NSString *)getWritePreferenceDirectory {
    //PreferenceDirectory:    ~/Library/Preferences/
    //NSString *prePath = NSHomeDirectory();
    //prePath = [prePath stringByAppendingString:@"/Library/Preferences/"];
    
    //PreferenceDirectory:    /Library/Preferences/
    //NSString *prePath = @"/Library/Preferences/";
    
    //PreferenceDirectory:    /tmp/
    NSString *prePath = @"/tmp/";
    
    return prePath;
}


+ (NSString *)getConfigValue: (NSString *) strConfigName {
    
    NSString *prePath = [self getReadPreferenceDirectory];
    uid_t current_user_id = getuid();
    struct passwd *pwentry = getpwuid(current_user_id);
    char *loginUser = pwentry->pw_name;
    //char *loginUser = getlogin();
    NSString *loginName = [[NSString alloc] initWithUTF8String:loginUser];
    NSString *plistName = [NSString stringWithFormat:@"com.rits.PdfDriverInstaller_%@.plist",loginName];
    NSString *plistPath = [prePath stringByAppendingString:plistName];
    //NSLog(@"[SettingWindow.getProxyIPAddress] prePath = %@", prePath);
    //NSString *plistPath = [prePath stringByAppendingString:CONFIGPLIST];
    NSMutableDictionary *dicSetting = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSString *strValue = nil;
    if(nil != dicSetting){
        strValue = [dicSetting objectForKey:strConfigName];
    }

    return strValue;
}



//Default values when not found in InitConfig.plist
//CorpName                ""
//
//ServerIPAddress         "0.0.0.0"
//ServerPort              "80"
//
//UseProxy                "0"
//ProxyIPAddress          "0.0.0.0"
//ProxyPort               "8080"
//UserName                ""
//Password                ""
//UseHttps                "1"
//
//UseLocalServer          "0"
//UseHttpsForLocalServer  "0"
//LocalServerIPAddress    "0.0.0.0"
//LocalServerPort         "80"
//
//DingUID                 ""
+ (NSString *)getInitConfigValue: (NSString *) strConfigName {
    
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
            }else if([strConfigName isEqualToString:@"ServerIP1"] ||[strConfigName isEqualToString:@"ServerIP2"] ||[strConfigName isEqualToString:@"ServerIP3"] ||[strConfigName isEqualToString:@"ServerIP4"] ||[strConfigName isEqualToString:@"ProxyIP1"] ||[strConfigName isEqualToString:@"ProxyIP2"] ||[strConfigName isEqualToString:@"ProxyIP3"] ||[strConfigName isEqualToString:@"ProxyIP4"] || [strConfigName isEqualToString:@"LocalServerIP1"] ||[strConfigName isEqualToString:@"LocalServerIP2"] ||[strConfigName isEqualToString:@"LocalServerIP3"] ||[strConfigName isEqualToString:@"LocalServerIP4"]){
                strValue = @"0";
            }else{
                strValue = @"";
            }
        }
    }
    
    return strValue;
}


+ (NSString *)getDingUID {
    NSString *str = [self getConfigValue:@"DingUID"];
    if(nil == str){
        str = [self getInitConfigValue:@"DingUID"];
    }
    
    return str;
}


- (IBAction)testLocalServerConnection:(id)sender {
    
    
    //NSString *strHttp = [SettingWindow getHttpString];
    //NSString *strServerIPAddress = [SettingWindow getServerIPAddress];
    //NSString *strCorpName = [SettingWindow getCorpName];
    
    
    NSString *strHttp = @"http";
    NSString *strServerIPAddress = @"0.0.0.0";
    NSString *strServerPort = @"80";
    NSString *strServerIPAddressAndPort = @"0.0.0.0:80";
    
    if(YES == self.btnChkLocalServer.state && YES == [self.txtFldLocalServerPort.stringValue isEqualToString:@""]){
        NSLog(@"[ERROR] Local server port should not be blank when \"Use Local Server\" is selected.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
//        [alert setMessageText:@"本地服务器端口错误"];
//        [alert setInformativeText:@"当\"启用本地服务器\"被勾选时，本地服务器端口不可设置为空。"];
        [alert runModal];
        return;
    }
    
    if(0 == self.btnChkHttpsForLocalServer.state){
        strHttp = @"http";
    }else if(1 == self.btnChkHttpsForLocalServer.state){
        strHttp = @"https";
    }
    
    strServerIPAddress = [NSString stringWithFormat:@"%@.%@.%@.%@", self.txtFldLocalServerIP1.stringValue, self.txtFldLocalServerIP2.stringValue, self.txtFldLocalServerIP3.stringValue, self.txtFldLocalServerIP4.stringValue];
    
    strServerPort = self.txtFldLocalServerPort.stringValue;
    
    
    if([strServerPort isEqualToString:@""]){
        strServerIPAddressAndPort = strServerIPAddress;
    }else{
        strServerIPAddressAndPort = [NSString stringWithFormat:@"%@:%@", strServerIPAddress, strServerPort];
    }

    
    
    //0: 通过以下RITS接口，使用企业用户名(corp_name)获取APP ID和APP Secret。(post方式)
    HttpClient *client = [[HttpClient alloc]init];
    NSData *response;
    //NSString *url0 = @"http://101.132.37.166/GetCorpInfoByDriver?corp_name=RICOH";
    //NSString *url0 = [NSString stringWithFormat:@"http://%@/GetCorpInfoByDriver?corp_name=%@", strServerIPAddress, strCorpName];
    NSString *url0 = [NSString stringWithFormat:@"%@://%@/Login", strHttp, strServerIPAddressAndPort];
    
    int res_code = [client GetPartResponseCode:url0 Response:&response];

    if(res_code != 200 || nil == response){
        NSLog(@"[ERROR] res_code=%d when testing local server connection",res_code);
        NSLog(@"[FAIL] Connected to local server unsuccessfully.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert setMessageText:@"连接失败"];
        [alert setInformativeText:@"本地服务器连接失败!\n请检查\"IP地址\",\"端口\"及\"使用HTTPS\"的设置。"];
        [alert runModal];
    }else{
        NSLog(@"[SUCCEED] Connected to local server successfully.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert setMessageText:@"连接成功"];
        [alert setInformativeText:@"本地服务器连接成功!"];
        [alert runModal];
    }
}


-(IBAction) clickUseLocalServerChkBox:(id) sender{
    BOOL checked = ((NSButton *)sender).state;
    if(YES == checked){
        self.txtFldLocalServerPort.enabled = NO;
        //self.txtFldLocalServerPort.stringValue = @"443";
        self.txtFldLocalServerPort.stringValue = NSLocalizedString(@"443", nil);
    }else{
        self.txtFldLocalServerPort.enabled = YES;
        self.txtFldLocalServerPort.stringValue = @"";
    }
}


- (IBAction)testServerConnection:(id)sender {
    
    
    NSString *strHttp = @"http";
    NSString *strServerIPAddress = @"0.0.0.0";
    NSString *strServerPort = @"80";
    NSString *strServerIPAddressAndPort = @"0.0.0.0:80";
    NSString *strCorpName = @"";
    
    if(YES == [self.txtFldServerPort.stringValue isEqualToString:@""]){
        NSLog(@"[ERROR] Server port should not be blank.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
//        [alert setMessageText:@"云服务器端口错误"];
//        [alert setInformativeText:@"云服务器端口不可设置为空。"];
        [alert runModal];
        return;
    }

    
    strServerIPAddress = [NSString stringWithFormat:@"%@.%@.%@.%@", self.txtFldServerIP1.stringValue, self.txtFldServerIP2.stringValue, self.txtFldServerIP3.stringValue, self.txtFldServerIP4.stringValue];
    
    strServerPort = self.txtFldServerPort.stringValue;
    
    strCorpName = self.txtFldCorpName.stringValue;
    
    if([strServerPort isEqualToString:@""]){
        strServerIPAddressAndPort = strServerIPAddress;
    }else{
        strServerIPAddressAndPort = [NSString stringWithFormat:@"%@:%@", strServerIPAddress, strServerPort];
    }
    
    
    //0: 通过以下RITS接口，使用企业用户名(corp_name)获取APP ID和APP Secret。(post方式)
    HttpClient *client = [[HttpClient alloc]init];
    NSData *response;
    //NSString *url0 = @"http://101.132.37.166/GetCorpInfoByDriver?corp_name=RICOH";
    //NSString *url0 = [NSString stringWithFormat:@"http://%@/GetCorpInfoByDriver?corp_name=%@", strServerIPAddress, strCorpName];
    NSString *url0 = [NSString stringWithFormat:@"%@://%@/GetCorpInfoByDriver?corp_name=%@", strHttp, strServerIPAddressAndPort, strCorpName];
    NSString *postData0 = [NSString stringWithFormat:@"corp_name=%@", strCorpName];
    
    
    NSString *strAppID = nil;
    NSString *strAppSecret = nil;
    NSString *strToken = nil;
    NSString *strCorpID = nil;
    NSString *strCorpSecret = nil;
    
    // Get Proxy setting from UI
    NSString *strUseProxy = [NSString stringWithFormat:@"%@", self.btnChkProxy.stringValue];
    NSString *strProxyIPAddressAndPort = [NSString stringWithFormat:@"%@.%@.%@.%@:%@", self.txtFldProxyIP1.stringValue, self.txtFldProxyIP2.stringValue, self.txtFldProxyIP3.stringValue, self.txtFldProxyIP4.stringValue, self.txtFldProxyPort.stringValue];
    NSString *strUserNameAndPassword = [NSString stringWithFormat:@"%@:%@", self.txtFldUserName.stringValue, self.txtFldPassword.stringValue];
    
    //int res_code = [client PostPart:url0 PostData:postData0 Response:&response isJson:NO];
    int res_code = [client PostPartWithUISetting:url0 IsUseProxy:strUseProxy ProxyIPAndPort:strProxyIPAddressAndPort UserNameAndPasswd:strUserNameAndPassword PostData:postData0 Response:&response isJson:NO];
    if(res_code == 0)
    {
        strAppID = (NSString*)[client GetValueFromJSONData:response sKey:@"app_id"];
        strAppSecret = (NSString*)[client GetValueFromJSONData:response sKey:@"app_secret"];
        strToken = (NSString*)[client GetValueFromJSONData:response sKey:@"token"];
        strCorpID = (NSString*)[client GetValueFromJSONData:response sKey:@"corp_id"];
        strCorpSecret = (NSString*)[client GetValueFromJSONData:response sKey:@"corp_secret"];
    }
    
    if(res_code != 0 || nil == response || nil == strAppID || nil == strAppSecret || nil == strToken || nil == strCorpID || nil == strCorpSecret){
        //NSLog(@"[ERROR] res_code=%d when getting app_id, app_secret, token, corp_id, and corp_secret", res_code);
        NSLog(@"[ERROR] res_code=%d when testing server connection",res_code);
        NSLog(@"[FAIL] Connected to server unsuccessfully.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert setMessageText:@"连接失败"];
        [alert setInformativeText:@"云服务器连接失败!\n请检查\"IP地址\",\"端口\"及\"企业名\"的设置。"];
        [alert runModal];
    }else{
        NSLog(@"[SUCCEED] Connected to server successfully.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert setMessageText:@"连接成功"];
        [alert setInformativeText:@"云服务器连接成功!"];
        [alert runModal];
    }
    
}


@end
