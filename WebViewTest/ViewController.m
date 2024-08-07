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
NSString *serverName2 = @"api.na.smart-integration.ricoh.com";    //NSString *strServerPort = @"443";
NSString *serverName3 = @"www.na.smart-integration.ricoh.com";    //NSString *strServerPort = @"443";
NSString *redirecturi = @"https://www.na.smart-integration.ricoh.com/frcxport/login-success.html";
NSString *client_id = @"70wKayW6zIAzH6KIGHZq74DDosjjnAdj";

// Get Proxy setting from UI
NSString *strUseProxy = @"";
NSString *strIP = @"";
NSString *strPort = @"";
NSString *mailAddress = @"asuka.saito1@jp.ricoh.com";
NSString *password = @"certpass123uzu";
NSString *tenant_id = @"1146807009";

- (void)viewDidLoad {
    [super viewDidLoad];
    _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 400, 600)];
    _wkWebView.UIDelegate = self;
    _wkWebView.navigationDelegate = self;
    [self.view  addSubview: _wkWebView];
    NSString *url = [self MakeUrlStringForGetAuthCodeRequest];
    NSLog(@"%@", url);
//    [self setupWKWebViewConstain: _wkWebView];
 //   [self loadWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@/portal/login.html", myHost]]];
    NSURL *u = [NSURL URLWithString:url];
    
    [self loadWithURL:u];
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

- (NSString *)getSuffix {
    NSString *loginName = @"g10024931";
    
    return loginName;
}

- (NSString *)getTmpFilePath: prefix {
    return [NSString stringWithFormat:@"/tmp/%@_na_sample_%@.txt", prefix, [self getSuffix]];
}

- (NSMutableDictionary *)getJSONParameters
{
    NSMutableDictionary *dict1=[[NSMutableDictionary alloc]init];
    
    NSString *path1 = [self getTmpFilePath:@"code"];
    NSString *code = [NSString stringWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:nil];
    NSString *path2 = [self getTmpFilePath:@"code_verifier"];
    NSString *code_verifier = [NSString stringWithContentsOfFile:path2 encoding:NSUTF8StringEncoding error:nil];
    
    [dict1 setObject:@"authorization_code" forKey:@"grant_type"];
    [dict1 setObject:redirecturi forKey:@"redirect_uri"];
    [dict1 setObject:code forKey:@"code"];
    [dict1 setObject:code_verifier forKey:@"code_verifier"];
    [dict1 setObject:client_id forKey:@"client_id"];
    [dict1 setObject:@"43200" forKey:@"expires_in"];
    return dict1;
}

-(NSString *)codeChallenge
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
    
    NSString *path = [self getTmpFilePath:@"code_verifier"];
    
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

-(BOOL)getToken {
    HttpClient *client = [[HttpClient alloc]init];

    NSString *strProxyIPAddressAndPort = [NSString stringWithFormat: @"%@:%@", strIP, strPort];
    NSString *strUserNameAndPassword = [NSString stringWithFormat: @"%@:%@",mailAddress, password];
    
    NSString *path1 = [self getTmpFilePath:@"code"];
    NSString *code = [NSString stringWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:nil];
    
    NSString *path2 = [self getTmpFilePath:@"code_verifier"];
    NSString *code_verifier = [NSString stringWithContentsOfFile:path2 encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableDictionary *dict1 = [self getJSONParameters];
    
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
            
            NSString *path1 = [self getTmpFilePath:@"access_token"];
            NSError *error;
            [access_token writeToFile:path1 atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"Export failed :%@",error);
            }else{
                NSLog(@"Export success");
            }
            
            NSString *path2 = [self getTmpFilePath:@"refresh_token"];
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


- (NSMutableDictionary *)getJSONParameters2
{
    NSMutableDictionary *dict1=[[NSMutableDictionary alloc]init];
    [dict1 setObject:mailAddress forKey:@"mail"];
    [dict1 setObject:password forKey:@"password"];
    [dict1 setObject:tenant_id forKey:@"org_id"];
    return dict1;
}

-(BOOL)loginTest {
    HttpClient *client = [[HttpClient alloc]init];
    
    NSString *strProxyIPAddressAndPort = [NSString stringWithFormat: @"%@:%@", strIP, strPort];
    NSString *strUserNameAndPassword = [NSString stringWithFormat: @"%@:%@",mailAddress, password];
    
    NSString *path1 = [self getTmpFilePath:@"code"];
    NSString *code = [NSString stringWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:nil];
    
    NSString *path2 = [self getTmpFilePath:@"code_verifier"];
    NSString *code_verifier = [NSString stringWithContentsOfFile:path2 encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableDictionary *dict1 = [self getJSONParameters2];
    
    NSString *url = [NSString stringWithFormat:@"https://api.%@/frcxprint/login/mail", strServerName];
    
 //   NSData *response;
//    int res_code = [client PostJSONToken:url IsUseProxy:strUseProxy ProxyIPAndPort:strProxyIPAddressAndPort UserNameAndPasswd:strUserNameAndPassword PostJSON:dict1 Response:&response];
    NSString *response;
    int res_code = [client PostJSONPartUseUISettings:url IsUseProxy:strUseProxy ProxyIPAndPort:strProxyIPAddressAndPort UserNameAndPasswd:strUserNameAndPassword PostJSON:dict1 Response:&response];

    if(res_code == 0 && nil != response)
    {
        /*
        NSArray *access_tokenStr = [client GetValueFromJSONData:response sKey:@"access_token"];
        NSArray *refresh_token = [client GetValueFromJSONData:response sKey:@"refresh_token"];
        NSString *refresh_tokenStr = [NSString stringWithFormat:@"%@", (NSString*)refresh_token];
        
        NSString *errorStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding ];
        NSString *str = @"error";
        NSRange error = [errorStr rangeOfString:str];
        NSLog(@"%@", errorStr);
         */
    /*
        if (error.location != NSNotFound){
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
            [alert setInformativeText:NSLocalizedString(@"ErrorPleaseCheckSettings", nil)];
            [alert runModal];
            return NO;
        }else{
            NSString *access_token = [NSString stringWithFormat:@"%@", (NSString*)access_tokenStr];
            
            NSString *path1 = [self getTmpFilePath:@"access_token"];
            NSError *error;
            [access_token writeToFile:path1 atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"Export failed :%@",error);
            }else{
                NSLog(@"Export success");
            }
            
            NSString *path2 = [self getTmpFilePath:@"refresh_token"];
            [refresh_tokenStr writeToFile:path2 atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSLog(@"Export failed :%@",error);
            }else{
                NSLog(@"Export success");
            }
        }
     */
        if([response rangeOfString:@"200"].location == NSNotFound)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"ErrorTitle", nil)];
            //[alert setInformativeText:STRPLEASECHECKNETWORKSETTING];
            [alert setInformativeText:NSLocalizedString(@"ErrorPleaseCheckSettings", nil)];
            [alert runModal];
            return NO;
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

- (BOOL)getAuthorization {
    HttpClient *client = [[HttpClient alloc]init];

    NSString *scopeStr = @"offline_access aut:me:read aut:tenant:read";
    NSString *scope = [scopeStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    //NSString *strServerPort = @"443";
    // Get Proxy setting from UI
    NSString *strProxyIPAddressAndPort = [NSString stringWithFormat: @"%@:%@", strIP, strPort];
    NSString *strUserNameAndPassword = [NSString stringWithFormat: @"%@:%@",mailAddress, password];

    
    NSString *code_challenge = [self codeChallenge];
    
    NSString *path = [self getTmpFilePath:@"code_challenge"];
    NSError *error;
    [code_challenge writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Export failed :%@",error);
    }else{
        NSLog(@"Export success");
    }
    
    //NSString *url = [NSString stringWithFormat:@"%@://api.%@/v1/aut/oauth/provider/authorize", strHttp, strServerName];
    NSString *url = [NSString stringWithFormat:@"https://api.%@/v1/aut/oauth/provider/authorize?client_id=%@&redirect_uri=%@&scope=%@&response_type=code&code_challenge=%@&code_challenge_method=S256&response_mode=fragment", strServerName, client_id, redirecturi, scope, code_challenge];
    
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
            
            NSString *path = [self getTmpFilePath:@"code"];
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

- (NSString *)MakeUrlStringForGetAuthCodeRequest {
    NSString *code_challenge = [self codeChallenge];
    NSString *scopeStr = [[NSString stringWithFormat:@"%@",@"offline_access aut:me:read aut:tenant:read"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    NSString *redirect_uri = [[NSString stringWithFormat:@"%@", redirecturi] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    NSString *clientid = [[NSString stringWithFormat:@"%@", client_id] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
/*
    NSString *param = [[NSString stringWithFormat:@"?client_id=%@&redirect_uri=%@&scope=%@&response_type=code&code_challenge=%@&code_challenge_method=S256&response_mode=fragment", client_id, redirecturi, scopeStr, code_challenge] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];;
    NSString *url = [NSString stringWithFormat:@"https://api.%@/v1/aut/oauth/provider/authorize%@", strServerName, param];
 */
/*
    NSString *url = [[NSString stringWithFormat:@"https://api.%@/v1/aut/oauth/provider/authorize?client_id=%@&redirect_uri=%@&scope=%@&response_type=code&code_challenge=%@&code_challenge_method=S256&response_mode=fragment", strServerName, client_id, redirecturi, scopeStr, code_challenge] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
 */
    NSString *url = [NSString stringWithFormat:@"https://api.%@/v1/aut/oauth/provider/authorize?client_id=%@&redirect_uri=%@&scope=%@&response_type=code&code_challenge=%@&code_challenge_method=S256&response_mode=fragment", strServerName, clientid, redirect_uri, scopeStr, code_challenge];

    
    return url;
}

/*
 /// <summary>
 /// 認可コード取得要求のURL文字列を作成する
 /// </summary>
 String^ MakeUrlStringForGetAuthCodeRequest()
 {
 const String^ procName = "StructReqGetAuthCode";
 infoLog(procName + " start.");
 
 //code_verifier生成
 int length = 43;
 String^ codeVerifier = gcnew String("");
 codeVerifier = BrowserCommon::Util::RamdomText(length);
 debugLog("codeVerifier[{0}]", codeVerifier);
 
 // codeVerifierはトークン取得時に使用するため保管しておく
 browserFormInfo->codeVerifier = codeVerifier;
 
 //SHA256 ハッシュ値生成
 cli::array<unsigned char>^ aryHashValue = BrowserCommon::Util::GetHash256(codeVerifier);
 
 //Base64 Encoding
 String^ base64UrlStr = Convert::ToBase64String(aryHashValue);
 
 debugLog("base64Str[{0}]", base64UrlStr);
 base64UrlStr = base64UrlStr->TrimEnd('=');             // パディングを削除
 base64UrlStr = base64UrlStr->Replace('+', '-');        //「+」⇒「-」
 base64UrlStr = base64UrlStr->Replace('/', '_');       //「/」⇒「_」
 debugLog("base64UrlStr[{0}]", base64UrlStr);
 
 // URL Encoding
 String^ clientId = HttpUtility::UrlEncode(browserFormInfo->clientId);
 String^ redirectUri = HttpUtility::UrlEncode(browserFormInfo->redirectUri);
 
 // RequestQueryの作成
 String^ a_strRequestQuery;
 a_strRequestQuery = "?client_id=";
 a_strRequestQuery += clientId;
 a_strRequestQuery += "&scope=offline_access%20aut:me:read%20aut:tenant:read";
 a_strRequestQuery += "&redirect_uri=";
 a_strRequestQuery += redirectUri;
 a_strRequestQuery += "&response_type=code";
 a_strRequestQuery += "&code_challenge=";
 a_strRequestQuery += base64UrlStr;
 a_strRequestQuery += "&code_challenge_method=S256";
 a_strRequestQuery += "&response_mode=fragment";
 debugLog(OLESTR("### a_strRequestQuery :{0} "), a_strRequestQuery);
 
 // ###############################
 // # request AuthCode API
 // ###############################
 String^ requestUri = "https://" + this->browserFormInfo->host + BrowserCommon::Define::HTTP_PATH_GET_AUTHCODE + a_strRequestQuery;
 
 debugLog("URL[{0}]", requestUri);
 
 infoLog(procName + " success.");
 return requestUri;
 }
 

 */

- (void)webView:(WKWebView *)webView
didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"didReceiveServerRedirectionForProvisionalNavigation");
    NSLog(@"%@",webView.URL.absoluteString);
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
    /*
    BOOL ret2 = [self loginTest];
    if (ret2 != YES) {
        NSLog(@"login error");
    }

    if ([navigationAction.sourceFrame.webView.URL.absoluteString isEqualToString: myURL] && [navigationAction.request.URL.absoluteString isNotEqualTo:myURL]) {
        
        BOOL ret = [self getAuthorization];
        if (ret != YES){
            NSLog(@"Authentication Error");
        }
    }
    */
    if([navigationAction.request.URL.host isEqualToString:myHost] || [navigationAction.request.URL.host isEqualToString: serverName2] || [navigationAction.request.URL.host isEqualToString: serverName3]){
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

    if([navigationResponse.response.URL.host isEqualToString:myHost] || [navigationResponse.response.URL.host isEqualToString:serverName2] || [navigationResponse.response.URL.host isEqualToString:serverName3]){
        decisionHandler(WKNavigationResponsePolicyAllow);
    }else{
        decisionHandler(WKNavigationResponsePolicyCancel);
    }

 }

@end
