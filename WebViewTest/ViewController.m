//
//  ViewController.m
//  WebViewTest
//
//  Created by g10024931 on 2024/02/06.
//  Copyright © 2024 g10024931. All rights reserved.
//

#import "ViewController.h"
#import "CHttpClient.h"

@interface ViewController () <WKUIDelegate, WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet NSView *baseView;
@property (nonatomic) WKWebView *wkWebView;

@end

@implementation ViewController

NSString *myHost = @"na.accounts.ricoh.com";
NSString *myURL = @"https://na.accounts.ricoh.com/portal/login.html";
NSString *strServerName = @"na.smart-integration.ricoh.com";    //NSString *strServerPort = @"443";
// Get Proxy setting from UI
NSString *strUseProxy = @"";
NSString *strIP = @"";
NSString *strPort = @"";
NSString *mailAddress = @"asuka.saito1@jp.ricoh.com";
NSString *password = @"certpass123uzu";

- (void)viewDidLoad {
    [super viewDidLoad];
    _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 400, 600)];
    _wkWebView.UIDelegate = self;
    _wkWebView.navigationDelegate = self;
    [self.view  addSubview: _wkWebView];
//    [self setupWKWebViewConstain: _wkWebView];
    [self loadWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@/portal/login.html", myHost]]];
}
/// autoLayoutをセット
- (void)setupWKWebViewConstain: (WKWebView *)webView {
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // ４辺のマージンを0にする
    NSLayoutConstraint *topConstraint =
    [NSLayoutConstraint constraintWithItem: webView
                                 attribute: NSLayoutAttributeTop
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.baseView
                                 attribute: NSLayoutAttributeTop
                                multiplier: 1.0
                                  constant: 0];
    
    NSLayoutConstraint *bottomConstraint =
    [NSLayoutConstraint constraintWithItem: webView
                                 attribute: NSLayoutAttributeBottom
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.baseView
                                 attribute: NSLayoutAttributeBottom
                                multiplier: 1.0
                                  constant: 0];
    
    NSLayoutConstraint *leftConstraint =
    [NSLayoutConstraint constraintWithItem: webView
                                 attribute: NSLayoutAttributeLeft
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.baseView
                                 attribute: NSLayoutAttributeLeft
                                multiplier: 1.0
                                  constant: 0];
    
    NSLayoutConstraint *rightConstraint =
    [NSLayoutConstraint constraintWithItem: webView
                                 attribute: NSLayoutAttributeRight
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.baseView
                                 attribute: NSLayoutAttributeRight
                                multiplier: 1.0
                                  constant: 0];
    
    NSArray *constraints = @[
                             topConstraint,
                             bottomConstraint,
                             leftConstraint,
                             rightConstraint
                             ];
    
    [self.baseView addConstraints:constraints];
}

- (void)loadWithURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 5];
    [_wkWebView loadRequest:request];
}

/// ページの読み込み開始時に呼ばれる
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"Start Provisional Navigation");
}

/// ページの内容受信開始時に呼ばれる
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"Did Commit");
}

/// ページの読み込み完了時に呼ばれる
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"Did Finish");
}

/// ページの読み込みエラー発生時に呼ばれる
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"Did Fail Provisional Navigation");
}


- (NSMutableDictionary *)getJSONParameters: (NSString *)loginName {
    NSMutableDictionary *dict1=[[NSMutableDictionary alloc]init];
    
    NSString *path1 = [NSString stringWithFormat:@"/tmp/code_na_sample_%@.txt",loginName];
    NSString *code = [NSString stringWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:nil];
    NSString *path2 = [NSString stringWithFormat:@"/tmp/code_verifier_na_sample_%@.txt",loginName];
    NSString *code_verifier = [NSString stringWithContentsOfFile:path2 encoding:NSUTF8StringEncoding error:nil];
    NSString *redirecturi = @"https://www.na.smart-integration.ricoh.com/frcxport/login-success.html";
    
    [dict1 setObject:@"authorization_code" forKey:@"grant_type"];
    [dict1 setObject:redirecturi forKey:@"redirect_uri"];
    [dict1 setObject:code forKey:@"code"];
    [dict1 setObject:code_verifier forKey:@"code_verifier"];
    [dict1 setObject:@"70wKayW6zIAzH6KIGHZq74DDosjjnAdj" forKey:@"client_id"];
    [dict1 setObject:@"43200" forKey:@"expires_in"];
    return dict1;
}

-(NSString *)codeChallenge: (NSString *)loginName
{
    
    static int kNumber = 43;
    NSString *sourceStr = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned int)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    
    //    NSString *loginName = [self getloginUser];
    NSString *path = [NSString stringWithFormat:@"/tmp/code_verifier_na_sample_%@.txt",loginName];
    
    //NSString *resultStr = @"dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk";
    NSString *code_verifier = resultStr;
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

-(BOOL)getToken: loginName {
    HttpClient *client = [[HttpClient alloc]init];
    
    NSString *strProxyIPAddressAndPort = [NSString stringWithFormat: @"%@:%@", strIP, strPort];
    NSString *strUserNameAndPassword = [NSString stringWithFormat: @"%@:%@",mailAddress, password];
    
    NSString *path1 = [NSString stringWithFormat:@"/tmp/code_na_sample_%@.txt",loginName];
    NSString *code = [NSString stringWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:nil];
    
    NSString *path2 = [NSString stringWithFormat:@"/tmp/code_verifier_na_sample_%@.txt",loginName];
    NSString *code_verifier = [NSString stringWithContentsOfFile:path2 encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableDictionary *dict1 = [self getJSONParameters: loginName];
    
    NSString *url = [NSString stringWithFormat:@"https://api.%@/v1/aut/oauth/provider/token", strServerName];
    
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
            
            NSString *path1 = [NSString stringWithFormat:@"/tmp/access_token_na_sample_%@.txt",loginName];
            NSError *error;
            [access_token writeToFile:path1 atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"Export failed :%@",error);
            }else{
                NSLog(@"Export success");
            }
            
            NSString *path2 = [NSString stringWithFormat:@"/tmp/refresh_token_na_sample_%@.txt",loginName];
            [refresh_tokenStr writeToFile:path2 atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"Export failed :%@",error);
            }else{
                NSLog(@"Export success");
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

- (BOOL)getAuthorization: loginName {
    HttpClient *client = [[HttpClient alloc]init];
    
    NSString *redirecturi = @"https://www.na.smart-integration.ricoh.com/frcxport/login-success.html";
    NSString *strServerName = @"na.smart-integration.ricoh.com";    //NSString *strServerPort = @"443";
    NSString *scopeStr = @"offline_access aut:me:read aut:tenant:read";
    NSString *scope = [scopeStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    //NSString *strServerPort = @"443";
    // Get Proxy setting from UI
    NSString *strProxyIPAddressAndPort = [NSString stringWithFormat: @"%@:%@", strIP, strPort];
    NSString *strUserNameAndPassword = [NSString stringWithFormat: @"%@:%@",mailAddress, password];

    
    NSString *code_challenge = [self codeChallenge: loginName];
    
    NSString *path = [NSString stringWithFormat:@"/tmp/code_challenge_na_sample_%@.txt",loginName];
    NSError *error;
    [code_challenge writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Export failed :%@",error);
    }else{
        NSLog(@"Export success");
    }
    
    //NSString *url = [NSString stringWithFormat:@"%@://api.%@/v1/aut/oauth/provider/authorize", strHttp, strServerName];
    NSString *url = [NSString stringWithFormat:@"https://api.%@/v1/aut/oauth/provider/authorize?client_id=70wKayW6zIAzH6KIGHZq74DDosjjnAdj&redirect_uri=%@&scope=%@&response_type=code&code_challenge=%@&code_challenge_method=S256&response_mode=fragment", strServerName, redirecturi, scope, code_challenge];
    
    NSString *response;
    int res_code = [client GetPartUseUISettings:url IsUseProxy:strUseProxy ProxyIPAndPort:strProxyIPAddressAndPort UserNameAndPasswd:strUserNameAndPassword Response:&response];
    
    if (res_code == 0 && nil != response)
    {
        
        NSString *str = @"error";
        NSRange errorStr = [response rangeOfString:str];
        
        //NSNumber *strReturnCode = (NSNumber*)errorStr;
        
        if (errorStr.location != NSNotFound)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
            [alert setInformativeText:NSLocalizedString(@"ErrorPleaseCheckSettings", nil)];
            [alert runModal];
            return NO;
        }
        else{
            NSRange startRange = [response rangeOfString:@"#code="];
            if (startRange.location == NSNotFound) {    //prevent from out of range exception
                NSLog(@"#code= is not found");
                return NO;
            }
            NSRange endRange = [response rangeOfString:@"\">"];
            NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
            NSString *code = [response substringWithRange:range];
            
            NSString *path = [NSString stringWithFormat:@"/tmp/code_na_sample_%@.txt",loginName];
            NSError *error;
            [code writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"Export failed :%@",error);
            }else{
                NSLog(@"Export success");
            }
            
            if(NO == [self getToken: loginName]){
                return NO;
            }
        }
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
        [alert setInformativeText:NSLocalizedString(@"ErrorPleaseCheckSettings", nil)];
        [alert runModal];
        return NO;
    }
    return YES;
}


- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"navigationAction");
    
    NSDictionary *sHeaders = navigationAction.request.allHTTPHeaderFields;

    for (id hd in sHeaders) {
        NSLog(@"%@ -> %@", hd, sHeaders[hd]);
    }

    if ([navigationAction.sourceFrame.webView.URL.absoluteString isEqualToString: myURL] && [navigationAction.request.URL.absoluteString isNotEqualTo:myURL]) {
        NSString *loginName = @"g10024931";
        BOOL ret = [self getAuthorization: loginName];
        if (ret != YES){
            NSLog(@"Authentication Error");
        }
    }
    if([navigationAction.request.URL.host isEqualToString:myHost]){
        decisionHandler(WKNavigationActionPolicyAllow);
    }else{
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"navigationResponse");
    NSDictionary *sHeaders = ((NSHTTPURLResponse *)navigationResponse.response).allHeaderFields;
    NSArray      *sCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:sHeaders forURL:navigationResponse.response.URL];
    
    for (id hd in sHeaders) {
        NSLog(@"%@ -> %@", hd, sHeaders[hd]);
    }

    for (NSHTTPCookie *sCookie in sCookies) {
        NSLog(@"%@ -> %@", sCookie.name, sCookie.value);
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:sCookie];
    }

    if([navigationResponse.response.URL.host isEqualToString:myHost]){
        decisionHandler(WKNavigationResponsePolicyAllow);
    }else{
        decisionHandler(WKNavigationResponsePolicyCancel);
    }

 }

@end
