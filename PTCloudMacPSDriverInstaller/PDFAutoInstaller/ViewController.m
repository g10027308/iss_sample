//
//  ViewController.m
//  PDFAutoInstaller
//
//  Created by rits on 2018/06/06.
//  Copyright © 2018 rits. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "ViewController.h"
#import "RIPDFInstaller.h"
#import "CHttpClient.h"
//#import "SettingWindow.h"
#import "EncryptPassword.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <pwd.h>

@implementation ViewController
{
    RIPrinterInstaller * printerInstaller;
    EncryptPassword * encryptPassword;
    NSString *UserName;
    NSString *UserAccount;
    NSString *DistributedIP;
    NSString *DistributedIPPort;
}

@synthesize PrinterName = _PrinterName;
@synthesize Passwd = _Passwd;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    encryptPassword = [EncryptPassword new];        //encoded password
    
    [self initWindow];
    printerInstaller = [[RIPrinterInstaller alloc] init];
}

-(void)viewDidAppear{
  
#if SHOW_INSTALL_BTN
    //self.view.window.title = STRINSTALLTITLE;
    self.view.window.title = NSLocalizedString(@"TitleUIIstall", nil);
    [_btnInstall setHidden:NO];
    [_buttonOkay setHidden:YES];
#else
    //[_txtPortName setEnabled:NO];
    [_txtPortName setEnabled:YES];
    self.view.window.title = NSLocalizedString(@"TitleUISave", nil);
    [_btnInstall setHidden:YES];
    [_buttonOkay setHidden:NO];
#endif
    
}

-(void) prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    NSViewController *send = segue.destinationController;
    if([send respondsToSelector:@selector(setPrinterName:)]){
        [send setValue:self.PrinterName forKey:@"PrinterName"];
    }
    if([send respondsToSelector:@selector(setOpenLoginURL:)]){
        [send setValue:self.sLoginURL forKey:@"OpenLoginURL"];
    }
    if([send respondsToSelector:@selector(setDelegate:)]){
        [send setValue:self forKey:@"Delegate"];
    }
}

- (void)passValue:(NSString *)value {
    // 设定编辑框内容为协议传过来的值

    // 取得Token
//    if(YES == [self getAuthorization:value]){
    if(YES == [self getToken2:value]){

        [self saveDingUIDToConfigPlist:false];
    
        //Show installing statues control, and hide userID relate controls
        //close the first scene
//        if ([self.view.identifier isEqualToString:@"firstView"]) {
//            [self.view.window close];
//        }
        
        //show the second scene
        [self performSegueWithIdentifier:@"segue1to3" sender:self];
        
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void)controlTextDidChange:(NSNotification *)obj{
    NSTextField *txtFld = [obj object];
    
    // Printer Name
    if ([txtFld.identifier isEqualToString:@"txtPortName"])
    {
        //Not allow characters: '"', ''', '\'
        int maxLen = (int)txtFld.stringValue.length;
        for(int index=maxLen-1; index>=0; index--){
            unichar aChar = [txtFld.stringValue characterAtIndex:index];
            if((aChar == '\"') || (aChar == '\'') || (aChar == '\\')){
                //txtFld.stringValue = [txtFld.stringValue substringToIndex:txtFld.stringValue.length-1];
                NSString *strValue = txtFld.stringValue;
                NSString *strRemove = [NSString stringWithFormat:@"%C", aChar];
                strValue = [strValue stringByReplacingOccurrencesOfString:strRemove withString:@""];
                txtFld.stringValue = strValue;
                maxLen = (int)txtFld.stringValue.length;
                index = maxLen;
            }
        }
        
        //The max number input characters of Printer Name is not been seted
        NSUInteger txtlen = txtFld.stringValue.length;
        if(txtlen > 126)
        {
            txtFld.stringValue = [txtFld.stringValue substringToIndex:126];
        }
    }
    
    if ([txtFld.identifier isEqualToString:@"txtFldTenantID"]) {
        int maxLen = (int)txtFld.stringValue.length;
        for (int index=maxLen-1; index>=0; index--) {
            unichar aChar = [txtFld.stringValue characterAtIndex:index];
            
            NSString *strValue = txtFld.stringValue;
            NSString *strRemove = [NSString stringWithFormat:@"%C", aChar];
            strValue = [strValue stringByReplacingOccurrencesOfString:strRemove withString:@""];
            txtFld.stringValue = strValue;
            maxLen = (int)txtFld.stringValue.length;
            index = maxLen;
        }
        NSUInteger txtLen = txtFld.stringValue.length;
        if(txtLen > 128){
            txtFld.stringValue = [txtFld.stringValue substringToIndex:128];
        }
    }

    if ([txtFld.identifier isEqualToString:@"txtFldMail"]) {
        int maxLen = (int)txtFld.stringValue.length;
        for (int index=maxLen-1; index>=0; index--) {
            unichar aChar = [txtFld.stringValue characterAtIndex:index];
            
            NSString *strValue = txtFld.stringValue;
            NSString *strRemove = [NSString stringWithFormat:@"%C", aChar];
            strValue = [strValue stringByReplacingOccurrencesOfString:strRemove withString:@""];
            txtFld.stringValue = strValue;
            maxLen = (int)txtFld.stringValue.length;
            index = maxLen;
        }
        NSUInteger txtLen = txtFld.stringValue.length;
        if(txtLen > 128){
            txtFld.stringValue = [txtFld.stringValue substringToIndex:128];
        }
    }
    
    if ([txtFld.identifier isEqualToString:@"txtFldMailPassword"]) {
        int maxLen = (int)txtFld.stringValue.length;
        for (int index=maxLen-1; index>=0; index--) {
            unichar aChar = [txtFld.stringValue characterAtIndex:index];
            NSString *strValue = txtFld.stringValue;
            NSString *strRemove = [NSString stringWithFormat:@"%C", aChar];
            strValue = [strValue stringByReplacingOccurrencesOfString:strRemove withString:@""];
            txtFld.stringValue = strValue;
            maxLen = (int)txtFld.stringValue.length;
            index = maxLen;
        }
        NSUInteger txtLen = txtFld.stringValue.length;
        if(txtLen > 128){
            txtFld.stringValue = [txtFld.stringValue substringToIndex:128];
        }
    }
    
    
    //Port: 0~65535
    if ([txtFld.identifier isEqualToString:@"txtFldServerPort"] || [txtFld.identifier isEqualToString:@"txtFldProxyPort"] || [txtFld.identifier isEqualToString:@"txtFldLocalServerPort"]){
        
        //only allow characters: 0-9 (Arab numbers)
        int maxLen = (int)txtFld.stringValue.length;
        for(int index=maxLen-1; index>=0; index--){
            unichar aChar = [txtFld.stringValue characterAtIndex:index];
            if(!(aChar >= '0' && aChar <= '9')){
                //txtFld.stringValue = [txtFld.stringValue substringToIndex:txtFld.stringValue.length-1];
                NSString *strValue = txtFld.stringValue;
                NSString *strRemove = [NSString stringWithFormat:@"%C", aChar];
                strValue = [strValue stringByReplacingOccurrencesOfString:strRemove withString:@""];
                txtFld.stringValue = strValue;
                maxLen = (int)txtFld.stringValue.length;
                index = maxLen;

            }
        }
        
        NSUInteger txtLen = txtFld.stringValue.length;
        //only allow up to 5 characters (valid value: 0 ~ 65535)
        if(txtLen > 5){
            txtFld.stringValue = [txtFld.stringValue substringToIndex:5];
        }
        
        //if the number is bigger than 65535, change it to 65535
        int intValue = txtFld.intValue;
        if(intValue > 65535){
            //txtFld.stringValue = @"65535";
            txtFld.stringValue = NSLocalizedString(@"65535", nil);
        }
    }
}

-(NSString *) getloginUser{
    uid_t current_user_id = getuid();
    struct passwd *pwentry = getpwuid(current_user_id);
    char *loginUser = pwentry->pw_name;
    NSString *loginName = [[NSString alloc] initWithUTF8String:loginUser];
    return loginName;
}

//save DingUID to config file in folder "/tmp/"
//should copy the config in folder "/tmp/" to User folder "~/Library/Preferences/" and root folder "/Library/Preferences/"
- (void)saveDingUIDToConfigPlist:(BOOL)blCopy2Prefrence {
    NSString *prePath = [self getWritePreferenceDirectory];
    NSLog(@"prePath = %@", prePath);
    
    //ユーザーごとのPlistファイルのディレクトリ
    NSString *loginName = [self getloginUser];
    NSString *plistName = [NSString stringWithFormat:@"com.rits.PdfDriverInstaller_%@.plist",loginName];
    NSString *plistPath = [prePath stringByAppendingString:plistName];
    
    //NSMutableDictionary *dicSetting = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSMutableDictionary *dicSetting = [[NSMutableDictionary alloc] init];
    NSLog(@"dicSetting = %@", dicSetting);
    
    // Printer/Port Name
    NSString * strPortName = self.txtPortName.stringValue;
    
    // Print Server
    NSString * strServerName = [self getInitConfigValue:@"ServerName"];
    NSString * strPrintServerName = [self getInitConfigValue:@"PrintServerName"];
    NSString * strUseHttps = [NSString stringWithFormat:@"1"];
    NSString * strServerPort = @"";
    
    // Proxy Server
    NSString * strUseProxy = [NSString stringWithFormat:@"%@", self.btnChkProxy.stringValue];
    NSString * strProxyIPAddress = self.txtFldProxyIP.stringValue;
    NSString * strProxyPort = self.txtFldProxyPort.stringValue;
    NSString * strUserName = self.txtFldUserName.stringValue;
    NSString * strPassword = self.txtFldPassword.stringValue;

    // User
    NSString * strTenantID = self.txtFldTenantID.stringValue;

    
    NSString *path1 = [NSString stringWithFormat:@"/tmp/refresh_token_na_portal_%@.txt",loginName];
    NSString *refreshToken = [NSString stringWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:nil];
    
    NSString *path2 = [NSString stringWithFormat:@"/tmp/access_token_na_portal_%@.txt",loginName];
    NSString *accessToken = [NSString stringWithContentsOfFile:path2 encoding:NSUTF8StringEncoding error:nil];
    
    NSString * redirecturi = [self getInitConfigValue:@"Redirecturi"];
    NSString * clientid = [self getInitConfigValue:@"ClientID"];

    //use portal site
    NSString * authMethod = [self getInitConfigValue:@"AuthMethod"];

    // Printer/Port Name
    [dicSetting setObject:strPortName forKey:@"PrinterDescription"];
    
    // Authen Server
    [dicSetting setObject:strServerName forKey:@"ServerName"];
    [dicSetting setObject:strUseHttps forKey:@"UseHttps"];
    [dicSetting setObject:strServerPort forKey:@"ServerPort"];
    
    NSString *userid = [self getloginUser];
    
    // Proxy Server
    [dicSetting setObject:strUseProxy forKey:@"UseProxy"];
    [dicSetting setObject:strProxyIPAddress forKey:@"ProxyIP"];
    [dicSetting setObject:strProxyPort forKey:@"ProxyPort"];
    [dicSetting setObject:strUserName forKey:@"UserName"];
    [dicSetting setObject:strPassword forKey:@"Password"];
    [dicSetting setObject:[encryptPassword getEncryptPassword:strPassword userid:userid] forKey:@"Password"];     //encoded password

    // Print User
    [dicSetting setObject:strTenantID forKey:@"TenantID"];

    //Token
    [dicSetting setObject:refreshToken forKey:@"RefreshToken"];
    [dicSetting setObject:accessToken forKey:@"AccessToken"];
    
    [dicSetting setObject:redirecturi forKey:@"Redirecturi"];
    [dicSetting setObject:clientid forKey:@"ClientID"];
    
    //Print Server
    [dicSetting setObject:strPrintServerName forKey:@"PrintServerName"];
    
    //use portal site
    [dicSetting setObject:authMethod forKey:@"AuthMetod"];

    //save the setting to /tmp/Preferences/com.rits.PdfDriverInstaller.plist
    [dicSetting writeToFile:plistPath atomically:YES];
    
    NSLog(@"dicSetting = %@", dicSetting);
    
    if(blCopy2Prefrence)
    {
        //RIPrinterInstaller * printerInstaller = [[RIPrinterInstaller alloc] init];
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
    }
}


- (IBAction)clickOKButton:(id)sender {
    
    self.PrinterName = self.txtPortName.stringValue;
    
    if(![self checkUISettingIsNotEmpty])
    {
        return;
    }
    
    if(![self checkProxyIPFormat])
    {
        return;
    }

    if([self isServerIPAddressAccesible])
    {
        NSString *loginName = [self getloginUser];
        NSString *cookiesName = [NSString stringWithFormat:@"/private/tmp/cookies_na_portal_%@.txt",loginName];
        const char *cookies = [cookiesName UTF8String];
        // 清楚保存Cookie
        FILE *fp = fopen(cookies, "wb");
        fclose(fp);
        
        //show the second scene
        [self performSegueWithIdentifier:@"segue1to2" sender:self];
        
        //save DingUID to "tmp" folder
        //[self saveDingUIDToConfigPlist:true];
        //[[NSApplication sharedApplication] terminate:self];
    }
    
}


- (IBAction)clickFinishButton:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}


-(BOOL)IsSettingChanged
{
    BOOL bRet = false;
    
    NSString * strPortName = self.txtPortName.stringValue;
    if(![strPortName isEqualToString:[self getPortName]])
    {
        return true;
    }
    
    // Proxy Server
    NSString * strUseProxy = [NSString stringWithFormat:@"%@", self.btnChkProxy.stringValue];
    if(![strUseProxy isEqualToString:[self getUseProxy]])
    {
        return true;
    }

    NSString * strProxyIPAddress = self.txtFldProxyIP.stringValue;
    if(![strProxyIPAddress isEqualToString:[self getProxyIPAddress]])
    {
        return true;
    }

    NSString * strProxyPort = self.txtFldProxyPort.stringValue;
    if(![strProxyPort isEqualToString:[self getProxyPort]])
    {
        return true;
    }

    NSString * strUserName = self.txtFldUserName.stringValue;
    if(![strUserName isEqualToString:[self getUserName]])
    {
        return true;
    }

    NSString * strPassword = self.txtFldPassword.stringValue;
    if(![strPassword isEqualToString:[self getPassword]])
    {
        return true;
    }

    NSString *strTenantID = self.txtFldTenantID.stringValue;
    if(![strTenantID isEqualToString:[self getTenantID]])
    {
        return true;
    }
    /*
    // Print User Mail
    NSString *strMail = self.txtFldMail.stringValue;
    if(![strMail isEqualToString:[self getMail]])
    {
        return true;
    }

    NSString * strMailPassword = self.txtFldMailPassword.stringValue;
    if(![strMailPassword isEqualToString:[self getMailPassword]])
    {
        return true;
    }
    */
    return bRet;
}

- (IBAction)clickCancelButton:(id)sender {

#if SHOW_INSTALL_BTN
    [[NSApplication sharedApplication] terminate:self];
#else
    if([self IsSettingChanged])
    {
        [self showSaveAlert];
    }
    else
    {
        [[NSApplication sharedApplication] terminate:self];
    }
#endif
    
}


- (void)showSaveAlert
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert setMessageText:NSLocalizedString(@"SaveAlertTitle", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"SaveAlertButtonSave", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"SaveAlertButtonUnSave", nil)];
    [alert setInformativeText:NSLocalizedString(@"SaveAlertMsg", nil)];
    while(1)
    {
        NSInteger buttonReturnValue = [alert runModal];
        if(buttonReturnValue == NSAlertFirstButtonReturn)
        {
            if(![self checkUISettingIsNotEmpty])
            {
                return;
            }
            
            if(![self checkProxyIPFormat])
            {
                return;
            }
            
            if([self isServerIPAddressAccesible])
            {
                [self saveDingUIDToConfigPlist:true];
                [[NSApplication sharedApplication] terminate:self];
            }
            break;
        }
        else if(buttonReturnValue == NSAlertSecondButtonReturn)
        {
            [[NSApplication sharedApplication] terminate:self];
            break;
        }
    }
}

- (BOOL)judgePlistExist   //judge plist Exist or not
{
    BOOL result = NO;
    NSString *prePath = NSHomeDirectory();
    prePath = [prePath stringByAppendingString:@"/Library/Preferences/"];
    
    NSString *loginName = [self getloginUser];
    NSString *plistName = [NSString stringWithFormat:@"com.rits.PdfDriverInstaller_%@.plist",loginName];
    NSString *plistPath = [prePath stringByAppendingString:plistName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:plistPath]) {
        NSString *strValue = [self getConfigValue:@"TenantID"];
        if (strValue != nil){
            result = YES;
        } else{
            result = NO;
        }
    } else{
        result = NO;
    }
    return result;
}

- (void)initWindow{
    //NSLocale *nsLocal = [NSLocale currentLocale];
    //NSArray *aLanguage = [NSLocale preferredLanguages];
    //NSString *localLang = [aLanguage objectAtIndex:0];
    //NSString *code = [nsLocal languageCode];
    
    //init UI items' title
    _lblPrinterDesc.stringValue = NSLocalizedString(@"TitlePrinterDescriptionName", nil);
     
    [_lblProxySettings setTitle: NSLocalizedString(@"TitleProxyGroup", nil)];
    [_btnChkProxy setTitle: NSLocalizedString(@"TitleProxyUseProxy", nil)];
    _lblProxyIP.stringValue = NSLocalizedString(@"TitleProxyIPAddress", nil);
    _lblProxyPort.stringValue = NSLocalizedString(@"TitleProxyPort", nil);
    _lblUserName.stringValue = NSLocalizedString(@"TitleProxyUser", nil);
    _lblPasswd.stringValue = NSLocalizedString(@"TitleProxyPasswd", nil);
    
    [_lblAuthenticationGroup setTitle:NSLocalizedString(@"TitleAuthenGroup", nil)];
    _lblTenantID.stringValue = NSLocalizedString(@"TitleTenantID", nil);
    
    [_buttonCancel setTitle: NSLocalizedString(@"TitleCancleButton", nil)];
    [_btnInstall setTitle: NSLocalizedString(@"TitleInstallButton", nil)];
    [_buttonOkay setTitle: NSLocalizedString(@"TitleSaveButton", nil)];
    

    
    self.txtPortName.stringValue = [self getPortName];
    
    NSString *strUseProxy = [self getUseProxy];;
    if(NSOrderedSame == [strUseProxy compare:@"0"]){
        self.btnChkProxy.state = NO;
    }else{
        self.btnChkProxy.state = YES;
    }
    [self grayProxyUI];

    self.txtFldProxyIP.stringValue = [self getProxyIPAddress];
    self.txtFldProxyPort.stringValue = [self getProxyPort];
    self.txtFldUserName.stringValue = [self getUserName];
    self.txtFldPassword.stringValue = [self getPassword];
    
    self.txtFldTenantID.stringValue = [self getTenantID];

    //printerInstaller = [[RIPrinterInstaller alloc] init];
}

- (NSString *)getPortName {
#if SHOW_INSTALL_BTN
    NSString *strPortName = nil;
#else
    NSString *strPortName = [self getConfigValue:@"PrinterDescription"];
#endif
    if(nil == strPortName){
        if (YES == [self judgePlistExist]){
            strPortName = [self getConfigValue:@"PrinterDescription"];
        } else{
            strPortName = [self getInitConfigValue:@"PrinterDescription"];
        }
    }
    return strPortName;
}

- (NSString *)getTenantID {
#if SHOW_INSTALL_BTN
    NSString *strTenantID = nil;
#else
    NSString *strTenantID = [self getConfigValue:@"TenantID"];
#endif
    if(nil == strTenantID){
        if (YES == [self judgePlistExist]){
            strTenantID = [self getConfigValue:@"TenantID"];
        } else{
            strTenantID = [self getInitConfigValue:@"TenantID"];
        }
    }
    return strTenantID;
}

- (NSString *)getMail {
#if SHOW_INSTALL_BTN
    NSString *strMail = nil;
#else
    NSString *strMail = [self getConfigValue:@"Mail"];
#endif
    if(nil == strMail){
        if (YES == [self judgePlistExist]){
            strMail = [self getConfigValue:@"Mail"];
        } else{
            strMail = [self getInitConfigValue:@"Mail"];
        }
    }
    return strMail;
}

- (NSString *)getMailPassword {
    NSString *strMailPassword = nil;
#if SHOW_INSTALL_BTN
    NSData *mailPass = nil;
#else
    NSData *mailPass = [self getConfigData:@"MailPassword"];
#endif
    
    NSString *userid = [self getloginUser];
    
    if(nil == mailPass){
        if (YES == [self judgePlistExist]){
            mailPass = [self getConfigData:@"MailPassword"];
        } else {
            mailPass = nil;
        }
    }
    if (mailPass != nil) {
        if ([mailPass isKindOfClass:[NSString class]]) {
            strMailPassword = [self getConfigValue:@"MailPassword"];    //clear text (older version)
        } else {
            strMailPassword = [encryptPassword getDecryptPassword:mailPass userid:userid];
        }
    } else {
        strMailPassword = [self getInitConfigValue:@"MailPassword"];
    }
    
    return strMailPassword;
}

- (NSString *)getServerName {
#if SHOW_INSTALL_BTN
    NSString *strServerName = nil;
#else
    NSString *strServerName = [self getConfigValue:@"ServerName"];
#endif
    if(nil == strServerName){
        strServerName = [self getInitConfigValue:@"ServerName"];
    }
    
    return strServerName;
}


- (NSString *)getLastIP {
#if SHOW_INSTALL_BTN
    NSString *strLastIP = nil;
#else
    NSString *strLastIP = [self getConfigValue:@"LastIP"];
#endif
    if(nil == strLastIP){
        strLastIP = [self getInitConfigValue:@"LastIP"];
    }
    
    return strLastIP;
}

- (NSString *)getLastIPPort {
#if SHOW_INSTALL_BTN
    NSString *strLastIPPort = nil;
#else
    NSString *strLastIPPort = [self getConfigValue:@"LastIPPort"];
#endif
    if(nil == strLastIPPort){
        strLastIPPort = [self getInitConfigValue:@"LastIPPort"];
    }
    
    return strLastIPPort;
}

- (NSString *)getCorpName {
#if SHOW_INSTALL_BTN
    NSString *strCorpName = nil;
#else
    NSString *strCorpName = [self getConfigValue:@"CorpName"];
#endif
    if(nil == strCorpName){
        //strCorpName = @"";
        strCorpName = [self getInitConfigValue:@"CorpName"];
    }
    
    return strCorpName;
}

- (NSString *)getServerIPAddress1 {
#if SHOW_INSTALL_BTN
    NSString *strServerIPAddress1 = nil;
#else
    NSString *strServerIPAddress1 = [self getConfigValue:@"ServerIP1"];
#endif
    if(nil == strServerIPAddress1){
        strServerIPAddress1 = [self getInitConfigValue:@"ServerIP1"];
    }
    return strServerIPAddress1;
}

- (NSString *)getServerIPAddress2 {
#if SHOW_INSTALL_BTN
    NSString *strServerIPAddress2 = nil;
#else
    NSString *strServerIPAddress2 = [self getConfigValue:@"ServerIP2"];
#endif
    if(nil == strServerIPAddress2){
        strServerIPAddress2 = [self getInitConfigValue:@"ServerIP2"];
    }
    return strServerIPAddress2;
}

- (NSString *)getServerIPAddress3 {
#if SHOW_INSTALL_BTN
    NSString *strServerIPAddress3 = nil;
#else
    NSString *strServerIPAddress3 = [self getConfigValue:@"ServerIP3"];
#endif
    if(nil == strServerIPAddress3){
        strServerIPAddress3 = [self getInitConfigValue:@"ServerIP3"];
    }
    return strServerIPAddress3;
}

- (NSString *)getServerIPAddress4 {
#if SHOW_INSTALL_BTN
    NSString *strServerIPAddress4 = nil;
#else
    NSString *strServerIPAddress4 = [self getConfigValue:@"ServerIP4"];
#endif
    if(nil == strServerIPAddress4){
        strServerIPAddress4 = [self getInitConfigValue:@"ServerIP4"];
    }
    return strServerIPAddress4;
}

- (NSString *)getServerPort {
#if SHOW_INSTALL_BTN
    NSString *strPort = nil;
#else
    NSString *strPort = [self getConfigValue:@"ServerPort"];
#endif
    if(nil == strPort){
        strPort = [self getInitConfigValue:@"ServerPort"];
    }
    
    return strPort;
}

- (NSString *)getServerIPAddress {
    NSString *strServerIP = @"0.0.0.0:80";
    
#if SHOW_INSTALL_BTN
    NSString *strServerIP1 = nil;
    NSString *strServerIP2 = nil;
    NSString *strServerIP3 = nil;
    NSString *strServerIP4 = nil;
#else
    NSString *strServerIP1 = [self getConfigValue:@"ServerIP1"];
    NSString *strServerIP2 = [self getConfigValue:@"ServerIP2"];
    NSString *strServerIP3 = [self getConfigValue:@"ServerIP3"];
    NSString *strServerIP4 = [self getConfigValue:@"ServerIP4"];
#endif
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

- (NSString *)getInitServerIPAddress {
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

- (NSString *)getProxyIPAddress {
#if SHOW_INSTALL_BTN
    NSString *strProxyIPAddress = nil;
#else
    NSString *strProxyIPAddress = [self getConfigValue:@"ProxyIP"];
#endif
    if(nil == strProxyIPAddress){
        if (YES == [self judgePlistExist]){
            strProxyIPAddress = [self getConfigValue:@"ProxyIP"];
        } else{
            strProxyIPAddress = [self getInitConfigValue:@"ProxyIP"];
        }
    }
    return strProxyIPAddress;
}

- (NSString *)getInitProxyIPAddress {
    NSString *strProxyIP = @"0.0.0.0";
    
    strProxyIP = [self getInitConfigValue:@"ProxyIP"];
    
    return strProxyIP;
}

- (NSString *)getProxyPort {
#if SHOW_INSTALL_BTN
    NSString *strPort = nil;
#else
    NSString *strPort = [self getConfigValue:@"ProxyPort"];
#endif
    if(nil == strPort){
        if (YES == [self judgePlistExist]){
            strPort = [self getConfigValue:@"ProxyPort"];
        } else{
            strPort = [self getInitConfigValue:@"ProxyPort"];
        }
    }
    return strPort;
}


- (NSString *)getUserName {
#if SHOW_INSTALL_BTN
    NSString *strUserName = nil;
#else
    NSString *strUserName = [self getConfigValue:@"UserName"];
#endif
    if(nil == strUserName){
        if (YES == [self judgePlistExist]){
            strUserName = [self getConfigValue:@"UserName"];
        } else{
            strUserName = [self getInitConfigValue:@"UserName"];
        }
    }
    return strUserName;
}


- (NSString *)getPassword {
    NSString *strPassword = nil;
#if SHOW_INSTALL_BTN
    NSData *Pass = nil;
#else
    NSData *Pass = [self getConfigData:@"Password"];
#endif
    
    NSString *userid = [self getloginUser];
    
    if(nil == Pass){
        if (YES == [self judgePlistExist]){
            Pass = [self getConfigData:@"Password"];
        } else {
            Pass = nil;
        }
    }
    if (Pass != nil) {
        if ([Pass isKindOfClass:[NSString class]]) {
            strPassword = [self getConfigValue:@"Password"];    //clear text (older version)
        } else {
            strPassword = [encryptPassword getDecryptPassword:Pass userid:userid];
        }
    } else {
        strPassword = [self getInitConfigValue:@"Password"];
    }
    
    return strPassword;
}

- (NSString *)getUseHttps {
#if SHOW_INSTALL_BTN
    NSString *strUseHttps = nil;
#else
    NSString *strUseHttps = [self getConfigValue:@"UseHttps"];
#endif
    if(nil == strUseHttps){
        strUseHttps = [self getInitConfigValue:@"UseHttps"];
    }
    
    return strUseHttps;
}

- (NSString *)getHttpString {
    NSString *flag = [self getUseHttps];

    NSString *httpString = @"https";
    if ([flag isEqualToString:@"0"]){
        httpString = @"http";
    }
    return httpString;
}

- (NSString *)getUseHttpsForLocalServer {
#if SHOW_INSTALL_BTN
    NSString *strUseHttpsForLocalServer = nil;
#else
    NSString *strUseHttpsForLocalServer = [self getConfigValue:@"UseHttpsForLocalServer"];
#endif
    if(nil == strUseHttpsForLocalServer){
        strUseHttpsForLocalServer = [self getInitConfigValue:@"UseHttpsForLocalServer"];
    }
    
    return strUseHttpsForLocalServer;
}

- (NSString *)getUseProxy {
#if SHOW_INSTALL_BTN
    NSString *strUseProxy = nil;
#else
    NSString *strUseProxy = [self getConfigValue:@"UseProxy"];
#endif
    if(nil == strUseProxy){
        if (YES == [self judgePlistExist]){
            strUseProxy = [self getConfigValue:@"UseProxy"];
        } else{
            strUseProxy = [self getInitConfigValue:@"UseProxy"];
        }
    }
    return strUseProxy;
}


- (NSString *)getLocalServerIPAddress1 {
#if SHOW_INSTALL_BTN
    NSString *strLocalServerIPAddress1 = nil;
#else
    NSString *strLocalServerIPAddress1 = [self getConfigValue:@"LocalServerIP1"];
#endif
    if(nil == strLocalServerIPAddress1){
        strLocalServerIPAddress1 = [self getInitConfigValue:@"LocalServerIP1"];
    }
    return strLocalServerIPAddress1;
}

- (NSString *)getLocalServerIPAddress2 {
#if SHOW_INSTALL_BTN
    NSString *strLocalServerIPAddress2 = nil;
#else
    NSString *strLocalServerIPAddress2 = [self getConfigValue:@"LocalServerIP2"];
#endif
    if(nil == strLocalServerIPAddress2){
        strLocalServerIPAddress2 = [self getInitConfigValue:@"LocalServerIP2"];
    }
    return strLocalServerIPAddress2;
}

- (NSString *)getLocalServerIPAddress3 {
#if SHOW_INSTALL_BTN
    NSString *strLocalServerIPAddress3 = nil;
#else
    NSString *strLocalServerIPAddress3 = [self getConfigValue:@"LocalServerIP3"];
#endif
    if(nil == strLocalServerIPAddress3){
        strLocalServerIPAddress3 = [self getInitConfigValue:@"LocalServerIP3"];
    }
    return strLocalServerIPAddress3;
}

- (NSString *)getLocalServerIPAddress4 {
#if SHOW_INSTALL_BTN
    NSString *strLocalServerIPAddress4 = nil;
#else
    NSString *strLocalServerIPAddress4 = [self getConfigValue:@"LocalServerIP4"];
#endif
    if(nil == strLocalServerIPAddress4){
        strLocalServerIPAddress4 = [self getInitConfigValue:@"LocalServerIP4"];
    }
    return strLocalServerIPAddress4;
}

- (NSString *)getLocalServerPort {
#if SHOW_INSTALL_BTN
    NSString *strPort = nil;
#else
    NSString *strPort = [self getConfigValue:@"LocalServerPort"];
#endif
    if(nil == strPort){
        strPort = [self getInitConfigValue:@"LocalServerPort"];
    }
    
    return strPort;
}

- (NSString *)getLocalServerIPAddress {
    //NSString *strLocalServerIP = @"0.0.0.0:80";
    NSString *strLocalServerIP = @"0.0.0.0";
    
#if SHOW_INSTALL_BTN
    NSString *strLocalServerIP1 = nil;
    NSString *strLocalServerIP2 = nil;
    NSString *strLocalServerIP3 = nil;
    NSString *strLocalServerIP4 = nil;
#else
    NSString *strLocalServerIP1 = [self getConfigValue:@"LocalServerIP1"];
    NSString *strLocalServerIP2 = [self getConfigValue:@"LocalServerIP2"];
    NSString *strLocalServerIP3 = [self getConfigValue:@"LocalServerIP3"];
    NSString *strLocalServerIP4 = [self getConfigValue:@"LocalServerIP4"];
#endif
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

- (NSString *)getInitLocalServerIPAddress {
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

- (NSString *)getUseLocalServer {
#if SHOW_INSTALL_BTN
    NSString *strUseLocalServer = nil;
#else
    NSString *strUseLocalServer = [self getConfigValue:@"UseLocalServer"];
#endif
    if(nil == strUseLocalServer){
        strUseLocalServer = [self getInitConfigValue:@"UseLocalServer"];
    }
    
    return strUseLocalServer;
}


- (NSString *)getDingUserName
{
#if SHOW_INSTALL_BTN
    NSString *str = nil;
#else
    NSString *str = [self getConfigValue:@"DingUserName"];
#endif
    if(nil == str)
    {
        str = [self getInitConfigValue:@"DingUserName"];
    }
    return str;
}


- (NSString *)getAuthMethod {
#if SHOW_INSTALL_BTN
    NSString *strAuthMethod = nil;
#else
    NSString *strAuthMethod = [self getConfigValue:@"AuthMethod"];
#endif
    if(nil == strAuthMethod){
        strAuthMethod = [self getInitConfigValue:@"AuthMethod"];
    }
    
    return strAuthMethod;
}



- (NSString *)getReadPreferenceDirectory {
    //PreferenceDirectory:    ~/Library/Preferences/
    NSString *prePath = NSHomeDirectory();
    prePath = [prePath stringByAppendingString:@"/Library/Preferences/"];
    
    //PreferenceDirectory:    /Library/Preferences/
    //NSString *prePath = @"/Library/Preferences/";
    
    return prePath;
}

- (NSString *)getWritePreferenceDirectory {
    //PreferenceDirectory:    ~/Library/Preferences/
    //NSString *prePath = NSHomeDirectory();
    //prePath = [prePath stringByAppendingString:@"/Library/Preferences/"];
    
    //PreferenceDirectory:    /Library/Preferences/
    //NSString *prePath = @"/Library/Preferences/";
    
    //PreferenceDirectory:    /tmp/
    NSString *prePath = @"/tmp/";
    
    return prePath;
}


- (NSString *)getConfigValue: (NSString *) strConfigName {
    
    NSString *prePath = [self getReadPreferenceDirectory];
    NSString *loginName = [self getloginUser];
    NSString *plistName = [NSString stringWithFormat:@"com.rits.PdfDriverInstaller_%@.plist",loginName];
    NSString *plistPath = [prePath stringByAppendingString:plistName];
    NSMutableDictionary *dicSetting = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSString *strValue = nil;
    if(nil != dicSetting){
        strValue = [dicSetting objectForKey:strConfigName];
    }
    
    return strValue;
}

- (NSData *)getConfigData: (NSString *) strConfigName {
    
    NSString *prePath = [self getReadPreferenceDirectory];
    
    NSString *loginName = [self getloginUser];
    NSString *plistName = [NSString stringWithFormat:@"com.rits.PdfDriverInstaller_%@.plist",loginName];
    NSString *plistPath = [prePath stringByAppendingString:plistName];
    //NSLog(@"[SettingWindow.getProxyIPAddress] prePath = %@", prePath);
    //NSString *plistPath = [prePath stringByAppendingString:CONFIGPLIST];
    NSMutableDictionary *dicSetting = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSData *val = nil;
    if(nil != dicSetting){
        val = [dicSetting objectForKey:strConfigName];
    }
    
    return val;
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


// Get the INTERNAL ip address
- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            //int iFam = temp_addr->ifa_addr->sa_family;
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                NSString *strIfaName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                if([strIfaName containsString:@"en"] ) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    break;
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

- (NSString *)MakeUrlStringForGetAuthCodeRequest {
    NSString *strServerName = [self getInitConfigValue:@"ServerName"];
    NSString *redirecturi = [self getInitConfigValue:@"Redirecturi"];
    NSString *clientid = [self getInitConfigValue:@"ClientID"];

    NSString *code_challenge = [self codeChallenge];
    NSString *scopeStr = [[NSString stringWithFormat:@"%@",@"offline_access aut:me:read aut:tenant:read"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    
    NSString *url = [NSString stringWithFormat:@"https://api.%@/v1/aut/oauth/provider/authorize?client_id=%@&redirect_uri=%@&scope=%@&response_type=code&code_challenge=%@&code_challenge_method=S256&response_mode=fragment", strServerName, clientid, redirecturi, scopeStr, code_challenge];
    
    return url;
}

-(BOOL)isServerIPAddressAccesible
{
    /*
    HttpClient *client = [[HttpClient alloc]init];
    
    // Get
    NSString *strTenantID = self.txtFldTenantID.stringValue;
    
    NSString *successUrl = [self getInitConfigValue:@"successUrl"];
    NSString *failureUrl = [self getInitConfigValue:@"failureUrl"];
    NSString *strServerName = [self getInitConfigValue:@"ServerName"];
    //NSString *strServerPort = @"443";
    NSString *strHttp = @"https";
    // Get Proxy setting from UI
    NSString *strUseProxy = [NSString stringWithFormat:@"%@", self.btnChkProxy.stringValue];
    NSString *strProxyIPAddressAndPort = [NSString stringWithFormat:@"%@:%@", self.txtFldProxyIP.stringValue, self.txtFldProxyPort.stringValue];
    NSString *strUserNameAndPassword = [NSString stringWithFormat:@"%@:%@", self.txtFldUserName.stringValue, self.txtFldPassword.stringValue];
    
    // JSON header data
    NSMutableDictionary *dict1=[[NSMutableDictionary alloc]init];
    [dict1 setObject:strTenantID forKey:@"tenantId"];
    [dict1 setObject:@"office365v2" forKey:@"opId"];
    [dict1 setObject:successUrl forKey:@"successUrl"];
    [dict1 setObject:failureUrl forKey:@"failureUrl"];

    NSString *url = [NSString stringWithFormat:@"%@://api.%@/v1/aut/oidc/rp/request", strHttp, strServerName];
    
    NSData *response;
    //NSString *response;
    int res_code = [client PostJSONPartUseUISettings:url IsUseProxy:strUseProxy ProxyIPAndPort:strProxyIPAddressAndPort UserNameAndPasswd:strUserNameAndPassword PostJSON:dict1 Response:&response];
    
    if(res_code == 0 && nil != response)
    {
        //NSString *responseStr = [[NSString alloc]initWithData:response  encoding:NSUTF8StringEncoding];
        NSString *strReturnURL = (NSString*)[client GetValueFromJSONData:response sKey:@"authorizationUrl"];
        
        if (strReturnURL == NULL)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
            [alert setInformativeText:NSLocalizedString(@"ErrorPleaseCheckSettings", nil)];
            [alert runModal];
            return NO;
        }else{
            self.sLoginURL = strReturnURL;
        }
    }
    else if((res_code == 6) || (res_code == 7) || (res_code == 28))
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
        //[alert setInformativeText:STRPLEASECHECKNETWORKSETTING];
        [alert setInformativeText:NSLocalizedString(@"ErrorPleaseNetworkSettings", nil)];
        [alert runModal];
        return NO;
    }else{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
        //[alert setInformativeText:STRPLEASECHECKNETWORKSETTING];
        [alert setInformativeText:NSLocalizedString(@"ErrorPleaseCheckSettings", nil)];
        [alert runModal];
        return NO;
    }
    
//    if(NO == [self getCookie]){
//        return NO;
//    }
  */
    self.sLoginURL = [self MakeUrlStringForGetAuthCodeRequest];

    return YES;
}

-(BOOL)getCookie
{    
    HttpClient *client = [[HttpClient alloc]init];
    
    // Get
    NSString * strMail = @"jiang.bin.abel@cn.ricoh.com";
    NSString * strMailPassword = @"Gj123456";
    NSString *strServerName = [self getInitConfigValue:@"ServerName"];
    //NSString *strServerPort = @"443";
    NSString *strHttp = @"https";
    // Get Proxy setting from UI
    NSString *strUseProxy = [NSString stringWithFormat:@"%@", self.btnChkProxy.stringValue];
    NSString *strProxyIPAddressAndPort = [NSString stringWithFormat:@"%@:%@", self.txtFldProxyIP.stringValue, self.txtFldProxyPort.stringValue];
    NSString *strUserNameAndPassword = [NSString stringWithFormat:@"%@:%@", self.txtFldUserName.stringValue, self.txtFldPassword.stringValue];
    
    //NSString *postData = [NSString stringWithFormat:@"type=%@&loginMailAddress=%@&password=%@",  @"loginMailAddress", strMail, strMailPassword];
    
    //NSMutableDictionary *dict1=[[NSMutableDictionary alloc]init];
    //[dict1 setObject:@"loginMailAddress" forKey:@"type"];
    //[dict1 setObject:@"Wang.Supeng@cn.ricoh.com" forKey:@"loginMailAddress"];
    //[dict1 setObject:@"wsp19920319!" forKey:@"password"];
    NSMutableDictionary *dict1=[[NSMutableDictionary alloc]init];
    [dict1 setObject:@"loginMailAddress" forKey:@"type"];
    [dict1 setObject:strMail forKey:@"loginMailAddress"];
    [dict1 setObject:strMailPassword forKey:@"password"];
    //[dict1 setObject:@"true" forKey:@"withMyinfo"];
    
    NSString *url = [NSString stringWithFormat:@"%@://api.%@/v1/aut/login/user", strHttp, strServerName];
    
    NSData *response;
    //NSString *response;
    //int res_code = [client PostJSONPartUseUISettings:url IsUseProxy:strUseProxy ProxyIPAndPort:strProxyIPAddressAndPort UserNameAndPasswd:strUserNameAndPassword PostJSON:dict1 Response:&response];
    [client PostJSONPartUseUISettings:url IsUseProxy:strUseProxy ProxyIPAndPort:strProxyIPAddressAndPort UserNameAndPasswd:strUserNameAndPassword PostJSON:dict1 Response:&response];

    return YES;
}


- (BOOL)getAuthorization: (NSString *) strAPISid
{
    HttpClient *client = [[HttpClient alloc]init];
    
    NSString *strServerName = [self getInitConfigValue:@"ServerName"];
    //NSString *strServerPort = @"443";
    NSString *strHttp = @"https";
    // Get Proxy setting from UI
    NSString *strUseProxy = [NSString stringWithFormat:@"%@", self.btnChkProxy.stringValue];
    NSString *strProxyIPAddressAndPort = [NSString stringWithFormat:@"%@:%@", self.txtFldProxyIP.stringValue, self.txtFldProxyPort.stringValue];
    NSString *strUserNameAndPassword = [NSString stringWithFormat:@"%@:%@", self.txtFldUserName.stringValue, self.txtFldPassword.stringValue];
    NSString *redirecturi = [self getInitConfigValue:@"Redirecturi"];
    
    NSString *scopeStr = @"offline_access aut:me:read aut:tenant:read";
    NSString *scope = [scopeStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSString *code_challenge = [self codeChallenge];
    NSString *url = [NSString stringWithFormat:@"%@://api.%@/v1/aut/oauth/provider/authorize?client_id=70wKayW6zIAzH6KIGHZq74DDosjjnAdj&redirect_uri=%@&scope=%@&response_type=code&code_challenge=%@&code_challenge_method=S256&response_mode=fragment", strHttp, strServerName, redirecturi, scope, code_challenge];
    
    NSString *response;
    int res_code = [client GetPartUseUISettings:url IsUseProxy:strUseProxy ProxyIPAndPort:strProxyIPAddressAndPort UserNameAndPasswd:strUserNameAndPassword Response:&response APISid:strAPISid];
    
    if (res_code == 0 && nil != response)
    {
        NSRange errorStr = [response rangeOfString:@"error"];
        NSRange codeRange = [response rangeOfString:@"#code="];

        if (errorStr.location != NSNotFound)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
            [alert setInformativeText:NSLocalizedString(@"ErrorPleaseCheckSettings", nil)];
            [alert runModal];
            return NO;
        }
        else if (codeRange.location != NSNotFound) {
            NSRange startRange = [response rangeOfString:@"#code="];
            NSRange endRange = [response rangeOfString:@"\">"];
            NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
            NSString *code = [response substringWithRange:range];
            
            NSString *loginName = [self getloginUser];
            NSString *path = [NSString stringWithFormat:@"/tmp/code_na_portal_%@.txt",loginName];
            NSError *error;
            [code writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"Export failed :%@",error);
            }else{
                NSLog(@"Export success");
            }
            
            if(NO == [self getToken]){
                return NO;
            }
        }else{
            return NO;
        }
    }
    else if((res_code == 6) || (res_code == 7) || (res_code == 28))
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
        //[alert setInformativeText:STRPLEASECHECKNETWORKSETTING];
        [alert setInformativeText:NSLocalizedString(@"ErrorPleaseNetworkSettings", nil)];
        [alert runModal];
        return NO;
    }else{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
        //[alert setInformativeText:STRPLEASECHECKNETWORKSETTING];
        [alert setInformativeText:NSLocalizedString(@"ErrorPleaseCheckSettings", nil)];
        [alert runModal];
        return NO;
    }
    return YES;
}

//Generate random string
//Convert SHA256 encrypt
//Convert Base64UrlEncode
-(NSString *)codeChallenge
{
    static int kNumber = 43;
    NSString *sourceStr = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((uint)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    
    //NSString *resultStr = @"dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk";
    NSString *code_verifier = resultStr;
    NSString *loginName = [self getloginUser];
    NSString *path = [NSString stringWithFormat:@"/tmp/code_verifier_na_portal_%@.txt",loginName];
    NSError *error;
    [code_verifier writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Export failed :%@",error);
    }else{
        NSLog(@"Export success");
    }
    
    NSData *shaInData =[code_verifier dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *encodeData = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(shaInData.bytes, (unsigned int)shaInData.length, encodeData.mutableBytes);
    
    
    //NSData *encodeData =[ret dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [encodeData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    base64String = [base64String stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    
    return base64String;
    
}

-(BOOL)getToken{
    HttpClient *client = [[HttpClient alloc]init];
    
    NSString *strServerName = [self getInitConfigValue:@"ServerName"];
    //NSString *strServerPort = @"443";
    NSString *strHttp = @"https";
    // Get Proxy setting from UI
    NSString *strUseProxy = [NSString stringWithFormat:@"%@", self.btnChkProxy.stringValue];
    NSString *strProxyIPAddressAndPort = [NSString stringWithFormat:@"%@:%@", self.txtFldProxyIP.stringValue, self.txtFldProxyPort.stringValue];
    NSString *strUserNameAndPassword = [NSString stringWithFormat:@"%@:%@", self.txtFldUserName.stringValue, self.txtFldPassword.stringValue];
    NSString *redirecturi = [self getInitConfigValue:@"Redirecturi"];
    
    NSString *loginName = [self getloginUser];
    NSString *path1 = [NSString stringWithFormat:@"/tmp/code_na_portal_%@.txt",loginName];
    NSString *code = [NSString stringWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:nil];
    
    NSString *path2 = [NSString stringWithFormat:@"/tmp/code_verifier_na_portal_%@.txt",loginName];
    NSString *code_verifier = [NSString stringWithContentsOfFile:path2 encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableDictionary *dict1=[[NSMutableDictionary alloc]init];
    [dict1 setObject:@"authorization_code" forKey:@"grant_type"];
    [dict1 setObject:redirecturi forKey:@"redirect_uri"];
    [dict1 setObject:code forKey:@"code"];
    [dict1 setObject:code_verifier forKey:@"code_verifier"];
    [dict1 setObject:@"70wKayW6zIAzH6KIGHZq74DDosjjnAdj" forKey:@"client_id"];
    [dict1 setObject:@"43200" forKey:@"expires_in"];
    
    NSString *url = [NSString stringWithFormat:@"%@://api.%@/v1/aut/oauth/provider/token", strHttp, strServerName];
    
    NSData *response;
    int res_code = [client PostJSONToken:url IsUseProxy:strUseProxy ProxyIPAndPort:strProxyIPAddressAndPort UserNameAndPasswd:strUserNameAndPassword PostJSON:dict1 Response:&response];
    
    if(res_code == 0 && nil != response)
    {
        NSArray *access_tokenStr = [client GetValueFromJSONData:response sKey:@"access_token"];
//        NSArray *token_type = [client GetValueFromJSONData:response sKey:@"token_type"];
//        NSArray *expires_in = [client GetValueFromJSONData:response sKey:@"expires_in"];
        NSArray *refresh_token = [client GetValueFromJSONData:response sKey:@"refresh_token"];
        NSString *refresh_tokenStr = [NSString stringWithFormat:@"%@", (NSString*)refresh_token];
        NSString *errorStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding ];
        NSString *str = @"error";
        NSRange error = [errorStr rangeOfString:str];
        
        if (error.location != NSNotFound){
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
            [alert setInformativeText:NSLocalizedString(@"ErrorPleaseCheckSettings", nil)];
            [alert runModal];
            return NO;
        }else{
            NSString *access_token = [NSString stringWithFormat:@"%@", (NSString*)access_tokenStr];
            NSString *path1 = [NSString stringWithFormat:@"/tmp/access_token_na_portal_%@.txt",loginName];
            NSError *error;
            [access_token writeToFile:path1 atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"Export failed :%@",error);
            }else{
                NSLog(@"Export success");
            }
            
            NSString *path2 = [NSString stringWithFormat:@"/tmp/refresh_token_na_portal_%@.txt",loginName];
            [refresh_tokenStr writeToFile:path2 atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"Export failed :%@",error);
            }else{
                NSLog(@"Export success");
            }
        }
        
    }
    else if((res_code == 6) || (res_code == 7) || (res_code == 28))
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
        //[alert setInformativeText:STRPLEASECHECKNETWORKSETTING];
        [alert setInformativeText:NSLocalizedString(@"ErrorPleaseNetworkSettings", nil)];
        [alert runModal];
        return NO;
    }else{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
        //[alert setInformativeText:STRPLEASECHECKNETWORKSETTING];
        [alert setInformativeText:NSLocalizedString(@"ErrorPleaseCheckSettings", nil)];
        [alert runModal];
        return NO;
    }
    
    return YES;
}

-(BOOL)getToken2: (NSString *)codeForToken {
    HttpClient *client = [[HttpClient alloc]init];

    NSString *strServerName = [self getInitConfigValue:@"ServerName"];
    //NSString *strServerPort = @"443";
    NSString *strHttp = @"https";
    // Get Proxy setting from UI
    NSString *strUseProxy = [NSString stringWithFormat:@"%@", self.btnChkProxy.stringValue];
    NSString *strProxyIPAddressAndPort = [NSString stringWithFormat:@"%@:%@", self.txtFldProxyIP.stringValue, self.txtFldProxyPort.stringValue];
    NSString *strUserNameAndPassword = [NSString stringWithFormat:@"%@:%@", self.txtFldUserName.stringValue, self.txtFldPassword.stringValue];

    NSString *loginName = [self getloginUser];
    NSString *redirecturi = [self getInitConfigValue:@"Redirecturi"];
    
    NSString *path1 = [NSString stringWithFormat:@"/tmp/code_na_portal_%@.txt",loginName];
    NSString *code = [NSString stringWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:nil];
    
    NSString *path2 = [NSString stringWithFormat:@"/tmp/code_verifier_na_portal_%@.txt",loginName];
    NSString *code_verifier = [NSString stringWithContentsOfFile:path2 encoding:NSUTF8StringEncoding error:nil];

    if (codeForToken != nil && codeForToken.length > 0) {
        code = codeForToken;
    }

    
    NSMutableDictionary *dict1=[[NSMutableDictionary alloc]init];
    [dict1 setObject:@"authorization_code" forKey:@"grant_type"];
    [dict1 setObject:redirecturi forKey:@"redirect_uri"];
    [dict1 setObject:code forKey:@"code"];
    [dict1 setObject:code_verifier forKey:@"code_verifier"];
    [dict1 setObject:@"70wKayW6zIAzH6KIGHZq74DDosjjnAdj" forKey:@"client_id"];
    [dict1 setObject:@"43200" forKey:@"expires_in"];
    
    NSString *url = [NSString stringWithFormat:@"%@://api.%@/v1/aut/oauth/provider/token", strHttp, strServerName];
    
    NSData *response;
    int res_code = [client PostJSONToken:url IsUseProxy:strUseProxy ProxyIPAndPort:strProxyIPAddressAndPort UserNameAndPasswd:strUserNameAndPassword PostJSON:dict1 Response:&response];
    
    
    if(res_code == 0 && nil != response)
    {
        NSArray *access_tokenStr = [client GetValueFromJSONData:response sKey:@"access_token"];
        NSArray *refresh_token = [client GetValueFromJSONData:response sKey:@"refresh_token"];
        NSString *refresh_tokenStr = [NSString stringWithFormat:@"%@", (NSString*)refresh_token];
        
        NSString *errorStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding ];
        NSString *str = @"error";
        NSRange error = [errorStr rangeOfString:str];
        
        if (error.location != NSNotFound){
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
            [alert setInformativeText:NSLocalizedString(@"ErrorPleaseCheckSettings", nil)];
            [alert runModal];
            return NO;
        }else{
            NSString *access_token = [NSString stringWithFormat:@"%@", (NSString*)access_tokenStr];
            NSString *path1 = [NSString stringWithFormat:@"/tmp/access_token_na_portal_%@.txt",loginName];

            NSError *error;
            [access_token writeToFile:path1 atomically:YES encoding:NSUTF8StringEncoding error:&error];
            [access_token writeToFile:path1 atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"Export failed :%@",error);
            }else{
                NSLog(@"Export success");
            }

            NSString *path2 = [NSString stringWithFormat:@"/tmp/refresh_token_na_portal_%@.txt",loginName];
            [refresh_tokenStr writeToFile:path2 atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"Export failed :%@",error);
            }else{
                if (error) {
                    NSLog(@"Export failed :%@",error);
                }else{
                    NSLog(@"Export success");
                }
            }
        }
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
        //[alert setInformativeText:STRPLEASECHECKNETWORKSETTING];
        [alert setInformativeText:NSLocalizedString(@"ErrorPleaseCheckSettings", nil)];
        [alert runModal];
        return NO;
    }
    
    return YES;
}

-(BOOL)checkProxyIPFormat{
    if(YES == self.btnChkProxy.state){
        const char *proxyString = [self.txtFldProxyIP.stringValue UTF8String];
        NSCharacterSet *nameCharacters1 = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."]invertedSet];//find character except "0123456789."
        NSCharacterSet *nameCharacters2 = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789.:/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]invertedSet];//find character except "0123456789.:/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        NSRange proxyRange1 = [self.txtFldProxyIP.stringValue rangeOfCharacterFromSet: nameCharacters1];
        NSRange proxyRange2 = [self.txtFldProxyIP.stringValue rangeOfCharacterFromSet: nameCharacters2];
        
        int ip[5];
        int num = sscanf(proxyString, "%d.%d.%d.%d.%d", &ip[0],&ip[1],&ip[2],&ip[3],&ip[4]);
        
        if ((proxyRange2.location != NSNotFound) || ((proxyRange1.location == NSNotFound) && (num != 4)) ||
            ((proxyRange1.location == NSNotFound) && (num == 4) && ((ip[0]>255) || (ip[1]>255) || (ip[2]>255) || (ip[3]>255)))) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:NSLocalizedString(@"Continue", nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
            [alert setInformativeText:NSLocalizedString(@"WarnningProxyIP", nil)];
            NSInteger buttonreturnval = [alert runModal];
            if (buttonreturnval == NSAlertSecondButtonReturn) {
                [self.txtFldProxyIP becomeFirstResponder];
                return NO;
            }
        }
    }
    return YES;
}

-(BOOL)checkUISettingIsNotEmpty
{
    if(YES == self.btnChkProxy.state && YES == [self.txtFldProxyIP.stringValue isEqualToString:@""]){
        NSLog(@"[ERROR] Proxy Address should not be blank when \"Use Proxy\" is selected.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert setMessageText:NSLocalizedString(@"WarnningTitleProxyIP", nil)];
        [alert setInformativeText:NSLocalizedString(@"WarnningInforProxyIP", nil)];
        [alert runModal];
        [self.txtFldProxyIP becomeFirstResponder];
        return NO;
    }
    
    if(YES == self.btnChkProxy.state && YES == [self.txtFldProxyPort.stringValue isEqualToString:@""]){
        NSLog(@"[ERROR] Proxy port should not be blank when \"Use Proxy\" is selected.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert setMessageText:NSLocalizedString(@"WarnningTitleProxyPort", nil)];
        [alert setInformativeText:NSLocalizedString(@"WarnningInforProxyPort", nil)];
        [alert runModal];
        [self.txtFldProxyPort becomeFirstResponder];
        return NO;
    }
    
    if(YES == self.btnChkProxy.state && YES == [self.txtFldUserName.stringValue isEqualToString:@""]){
        NSLog(@"[ERROR] Proxy Address should not be blank when \"Use Proxy\" is selected.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert setMessageText:NSLocalizedString(@"WarnningTitleProxyUserName", nil)];
        [alert setInformativeText:NSLocalizedString(@"WarnningInforProxyUserName", nil)];
        [alert runModal];
        [self.txtFldUserName becomeFirstResponder];
        return NO;
    }
    
    if(YES == self.btnChkProxy.state && YES == [self.txtFldPassword.stringValue isEqualToString:@""]){
        NSLog(@"[ERROR] Proxy Address should not be blank when \"Use Proxy\" is selected.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert setMessageText:NSLocalizedString(@"WarnningTitleProxyPassword", nil)];
        [alert setInformativeText:NSLocalizedString(@"WarnningInforProxyPassword", nil)];
        [alert runModal];
        [self.txtFldPassword becomeFirstResponder];
        return NO;
    }
    
    if (YES == [self.txtFldTenantID.stringValue isEqualToString:@""]) {
        NSLog(@"[ERROR] TenantID should not be blank.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert setMessageText:NSLocalizedString(@"WarnningTitleTenantID", nil)];
        [alert setInformativeText:NSLocalizedString(@"WarnningInforTenantID", nil)];
        [alert runModal];
        [self.txtFldTenantID becomeFirstResponder];
        return NO;
    }

    return YES;

}

- (IBAction)clickBtnInstall:(id)sender {
    self.PrinterName = self.txtPortName.stringValue;
    //self.sLoginURL = @"https://www.baidu.com";
    //save DingUID to "tmp" folder
    
    if(![self checkUISettingIsNotEmpty])
    {
        return;
    }
    
    if(![self checkProxyIPFormat])
    {
        return;
    }

    if(![self isServerIPAddressAccesible])
    {
        return;
    }
    
//    //Show installing statues control, and hide userID relate controls
//    //close the first scene
//    if ([self.view.identifier isEqualToString:@"firstView"]) {
//        [self.view.window close];
//    }
    
    NSString *loginName = [self getloginUser];
    NSString *cookiesName = [NSString stringWithFormat:@"/private/tmp/cookies_na_portal_%@.txt",loginName];
    const char *cookies = [cookiesName UTF8String];
    // 清楚保存Cookie
    FILE *fp = fopen(cookies, "wb");
    fclose(fp);

    //show the second scene
    [self performSegueWithIdentifier:@"segue1to2" sender:self];
}

-(BOOL)grayProxyUI
{
    if(self.btnChkProxy.state == YES)
    {
        [self.txtFldProxyIP setEnabled:YES];
        [self.txtFldProxyPort setEnabled:YES];
        [self.txtFldUserName setEnabled:YES];
        [self.txtFldPassword setEnabled:YES];
        
        
        
//        [self.lblProxyIP setTextColor:[NSColor blackColor]];
//        [self.lblProxyPort setTextColor:[NSColor blackColor]];
//        [self.lblUserName setTextColor:[NSColor blackColor]];
//        [self.lblPasswd setTextColor:[NSColor blackColor]];
//        [self.lblProxyPortRange setTextColor:[NSColor blackColor]];
        
    }
    else
    {
        [self.txtFldProxyIP setEnabled:NO];
        [self.txtFldProxyPort setEnabled:NO];
        [self.txtFldUserName setEnabled:NO];
        [self.txtFldPassword setEnabled:NO];
        
//        [self.lblProxyIP setTextColor:[NSColor lightGrayColor]];
//        [self.lblProxyPort setTextColor:[NSColor lightGrayColor]];
//        [self.lblUserName setTextColor:[NSColor lightGrayColor]];
//        [self.lblPasswd setTextColor:[NSColor lightGrayColor]];
//        [self.lblProxyPortRange setTextColor:[NSColor lightGrayColor]];
    }
    
    return YES;
}

- (IBAction)clickChkboxUserProxyServer:(id)sender {
    [self grayProxyUI];
}

@end
