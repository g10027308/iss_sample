//
//  SacnQRCode.m
//  PDFAutoInstallerForDingPrint
//
//  Created by rits on 2018/11/07.
//  Copyright © 2018年 rits. All rights reserved.
//

#import "SacnQRCode.h"
#import "CHttpClient.h"

#include <sys/types.h>
#include <pwd.h>

@interface SacnQRCode ()

@end

static NSString *STRBUTTONOKTITLE = @"确认";
static NSString *STRBUTTONCANCELTITLE = @"重新扫描";
//static NSString *STRDESCRIPTIONINFORMATION = @"请输入用户识别号码 (最多8个字母数字 [a-z,A-Z,0-9]字符):";
static NSString *STRDESCRIPTIONINFORMATION = @"请扫描下方二维码:";
static NSString *STRUSERIDTITLE = @"";
static NSString *STRRESCANQRCODEBUTTONTITLE = @"重新扫码获取用户信息";

@implementation SacnQRCode

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    //[self setTitle:STRVIEWTITLE];
    //[_buttonOkay setEnabled:NO];
    [_btnOk setTitle:STRBUTTONOKTITLE];
    [_btnOk setEnabled:NO];
    [_btnScanAgain setTitle:STRBUTTONCANCELTITLE];
    _lblUserID.stringValue = STRUSERIDTITLE;
    _DescptInfor.stringValue = STRDESCRIPTIONINFORMATION;
    //_UserID = @"";
    //_DingUID = @"";
    
    // get QR Code Web
    [self getScanQRCode];
    
}

-(void) getScanQRCode{
    //NSString *strHttp = [self getHttpString];
    //NSString *strServerIPAddress = [self getServerIPAddress];
    //NSString *strCorpName = [self getCorpName];
    
    //0: 通过以下接口，使用企业用户名(cname)获取errcode, errcode为0表示API执行正确。(get方式)
    HttpClient *client = [[HttpClient alloc]init];
    
    NSData *response;
    NSString *url0 = [NSString stringWithFormat:@"%@://%@/QRCodeLogin?cname=%@", self.strHttp, self.strServerIPAddress, self.strCorpName];
    
    NSArray *errcode = nil;            //第0步获得(get方式)
    
    // Get Proxy setting from UI
    // Get Proxy setting from UI

    //int res_code = [client GetPart:url0 Response:&response];
    int res_code = [client GetPartUseUISettings:url0 IsUseProxy:self.strUseProxy ProxyIPAndPort:self.strProxyIPAddressAndPort UserNameAndPasswd:self.strUserNameAndPassword  Response:&response];
    
    if(res_code != 0 || nil == response){
        NSLog(@"[ERROR] res_code=%d when QRCodeLogin",res_code);
        [self showHtml:@"ConnectFailed"];
        return;
    }else{
        
        errcode = [client GetValueFromJSONData:response sKey:@"errcode"];
        NSString *strErrCode = nil;
        if(nil != errcode){
            strErrCode = (NSString *)errcode;
        }
        
        if(nil == errcode || nil == response || (nil != errcode && 0 != errcode)){
            
            [self.myWKWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url0]]];
            
            NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(checkUrlChange:) object:@"alloc"];
            //start the thread
            [thread start];
        }
    }
    
    
}


- (void)checkUrlChange:(id)obj {
    NSLog(@"input parameter => %@", obj);
    NSLog(@"hello %@", [NSThread currentThread]);
    
    //NSString *strHttp = [self getHttpString];
    //NSString *strServerIPAddress = [self getServerIPAddress];
    //NSString *strCorpName = [self getCorpName];
    
    NSString *urlStringOriginal = [NSString stringWithFormat:@"%@://%@/QRCodeLogin?cname=%@", self.strHttp, self.strServerIPAddress, self.strCorpName];
    
    
    while(1){
        sleep(2);
        NSString *url = [self.myWKWebView.URL absoluteString];
        //NSLog(@"URL: %@", url);
        //NSComparisonResult result = [url compare:urlStringOriginal];
        NSComparisonResult result = [url compare:urlStringOriginal];
        if(NSOrderedSame != result){
            NSRange rangeDingTalk = [url rangeOfString:@"oapi.dingtalk.com"];
            if(0 != rangeDingTalk.length)
                continue;
            
            NSRange rangeBeforeCode = [url rangeOfString:@"?code="];
            NSRange rangeAfterCode = [url rangeOfString:@"&state="];
            
            if(0 == rangeBeforeCode.length || 0 == rangeAfterCode.length){
                NSLog(@"[ERROR] invalid URL");
                [self showHtml:@"LoginFailed_1st"];
                return;
            }else{
                NSRange tmpCodeRange;
                tmpCodeRange.location = rangeBeforeCode.location + rangeBeforeCode.length;
                tmpCodeRange.length = rangeAfterCode.location - tmpCodeRange.location;
                
                NSString *tmpCode = [url substringWithRange:tmpCodeRange];
                //URL changed
                [self getUserIDForDingPrint: tmpCode];
            }
            break;
        }
    }
    
}



- (void)getUserIDForDingPrint:(NSString*)code {
    
    HttpClient *client = [[HttpClient alloc]init];
    NSData *response;
    
    //NSString *strHttp = [self getHttpString];
    //NSString *strServerIPAddress = [self getServerIPAddress];
    //NSString *strCorpName = [self getCorpName];
    
    NSString *url1 = [NSString stringWithFormat:@"%@://%@/getUidByCode", self.strHttp, self.strServerIPAddress];
    
    
    NSMutableDictionary *dict1=[[NSMutableDictionary alloc]init];
    [dict1 setObject:@"0337cd7eaf3cae3ea9b2b5183ff560dfba628d91" forKey:@"accesskey"];
    [dict1 setObject:self.strCorpName forKey:@"cname"];
    [dict1 setObject:code forKey:@"dcode"];
    
    
    //int res_code = [client PostJSONPart:url1 PostJSON:dict1 Response:&response];
    int res_code = [client PostJSONPartUseUISettings:url1 IsUseProxy:self.strUseProxy ProxyIPAndPort:self.strProxyIPAddressAndPort UserNameAndPasswd:self.strUserNameAndPassword PostJSON:dict1 Response:&response];
    
    
    NSArray *errcode = nil;            //第1步获得(post方式)
    NSArray *userid = nil;             //第1步获得(post方式)
    NSArray *name = nil;               //第1步获得(post方式)
    NSArray *email = nil;              //第1步获得(post方式)
    
    
    if(res_code == 0)
    {
        errcode = [client GetValueFromJSONData:response sKey:@"errcode"];
    }
    
    
    if((res_code != 0) || (nil == response) || (nil != errcode && 0L != ((NSNumber*)errcode).longValue)){
        NSLog(@"[ERROR] res_code=%d errcode=%@ when getUidByCode", res_code, errcode);
        [self showHtml:@"LoginFailed_1st"];
        
        NSString *strMsg = [NSString stringWithFormat:@"登录用户：%@；登录失败。", name];
        _lblUserID.stringValue = strMsg;
        
        return;
    }else{
        userid = [client GetValueFromJSONData2:response sKey1:@"data" sKey2:@"userid"];
        name = [client GetValueFromJSONData2:response sKey1:@"data" sKey2:@"name"];
        email = [client GetValueFromJSONData2:response sKey1:@"data" sKey2:@"email"];
        NSString *strMsg = nil;
        if((userid == nil) || (nil == name) || (nil == email))
        {
            strMsg = [NSString stringWithFormat:@"登录失败。"];
            [self showHtml:@"LoginFailed_1st"];
        }
        else
        {
            strMsg = [NSString stringWithFormat:@"已登录用户：%@；\nEmail地址：%@", name, email];
            _txtUserID.stringValue = (NSString *)userid;
            //[_buttonOkay setEnabled:YES];
            self.UserID = (NSString*)strMsg;
            self.DingUID = (NSString*)userid;
            [self showHtml:@"LoginSuccess"];
        }
        
        _lblUserID.stringValue = strMsg;
        
        [_btnOk setEnabled:YES];
        
        //change url to local html file to show "Login Succesully!"
        
    }
}




- (NSString *)getCorpName {
    NSString *strCorpName = [self getConfigValue:@"CorpName"];
    if(nil == strCorpName){
        //strCorpName = @"";
        strCorpName = [self getInitConfigValue:@"CorpName"];
    }
    
    return strCorpName;
}


-(void) showHtml:(NSString *) strHtmlFileName{
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"LoginFailed_1st" ofType:@"htm" inDirectory:@"html"];
    NSString *path = [[NSBundle mainBundle] pathForResource:strHtmlFileName ofType:@"htm" inDirectory:@"html"];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    [self.myWKWebView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
}

- (NSString *)getUseHttps {
    NSString *strUseHttps = [self getConfigValue:@"UseHttps"];
    if(nil == strUseHttps){
        strUseHttps = [self getInitConfigValue:@"UseHttps"];
    }
    
    return strUseHttps;
}

- (NSString *)getReadPreferenceDirectory {
    //PreferenceDirectory:    ~/Library/Preferences/
    NSString *prePath = NSHomeDirectory();
    prePath = [prePath stringByAppendingString:@"/Library/Preferences/"];
    
    //PreferenceDirectory:    /Library/Preferences/
    //NSString *prePath = @"/Library/Preferences/";
    
    return prePath;
}


- (NSString *)getConfigValue: (NSString *) strConfigName {
    
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


- (NSString *)getHttpString {
    NSString *flag = [self getUseHttps];
    NSString *httpString = @"https";
    if ([flag isEqualToString:@"0"]){
        httpString = @"http";
    }
    return httpString;
}


- (NSString *)getServerIPAddress {
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
            }else if([strConfigName isEqualToString:@"ServerIP1"] ||[strConfigName isEqualToString:@"ServerIP2"] ||[strConfigName isEqualToString:@"ServerIP3"] ||[strConfigName isEqualToString:@"ServerIP4"] ||[strConfigName isEqualToString:@"ProxyIP1"] ||[strConfigName isEqualToString:@"ProxyIP2"] ||[strConfigName isEqualToString:@"ProxyIP3"] ||[strConfigName isEqualToString:@"ProxyIP4"] || [strConfigName isEqualToString:@"LocalServerIP1"] ||[strConfigName isEqualToString:@"LocalServerIP2"] ||[strConfigName isEqualToString:@"LocalServerIP3"] ||[strConfigName isEqualToString:@"LocalServerIP4"]){
                strValue = @"0";
            }else{
                strValue = @"";
            }
        }
    }
    
    return strValue;
}

- (IBAction)clickOKayButton:(id)sender {
    
    if(_DingUID != nil)
    {
        _viewUserID.stringValue = _DingUID;
    }
    if(_UserID != nil)
    {
        _viewUserName.stringValue = _UserID;
        [_btnScanQRCode setTitle:STRRESCANQRCODEBUTTONTITLE];
    }
    
    [self close];
    //[self.window orderOut:nil];
    
}


- (IBAction)clickScanAgainButton:(id)sender {
    // get QR Code Web
    [self getScanQRCode];
    _lblUserID.stringValue = @"";
    _txtUserID.stringValue = @"";
    _UserID = nil;
    _DingUID = nil;
    [_btnOk setEnabled:NO];
}

@end
