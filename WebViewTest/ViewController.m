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

- (NSMutableDictionary *)getJSONParameters: (NSString*)code
{
    NSMutableDictionary *dict1=[[NSMutableDictionary alloc]init];
    
    //NSString *path1 = [self getTmpFilePath:@"code"];
    //NSString *code = [NSString stringWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:nil];
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

-(BOOL)getToken: (NSString *)codeForToken {
    HttpClient *client = [[HttpClient alloc]init];

    NSString *strProxyIPAddressAndPort = [NSString stringWithFormat: @"%@:%@", strIP, strPort];
    NSString *strUserNameAndPassword = [NSString stringWithFormat: @"%@:%@",mailAddress, password];

    NSString *code = codeForToken;
    
    if (code == nil) {
        NSString *path1 = [self getTmpFilePath:@"code"];
        code = [NSString stringWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:nil];
    }
    
    NSString *path2 = [self getTmpFilePath:@"code_verifier"];
    NSString *code_verifier = [NSString stringWithContentsOfFile:path2 encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableDictionary *dict1 = [self getJSONParameters:code];
    
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
            
            if(NO == [self getToken:code]){
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

- (uint32_t)RequestGetAuthToken {
    uint32_t retval = 0;

    return retval;
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
 
 /// <summary>
 /// トークンを取得する
 /// </summary>
 DWORD RequestGetAuthToken()
 {
 const String ^procName = "RequestGetAuthToken";
 infoLog(procName + " start.");
 DWORD dwRet = ERROR_SUCCESS;
 
 // RequestQueryの作成
 String^ strRequestBody;
 strRequestBody =  "{ \"grant_type\": \"authorization_code";
 strRequestBody += "\", \"redirect_uri\": \"";
 strRequestBody += browserFormInfo->redirectUri;
 strRequestBody += "\", \"code\": \"";
 strRequestBody += browserFormInfo->authCode;
 strRequestBody += "\", \"code_verifier\": \"";
 strRequestBody += browserFormInfo->codeVerifier;
 strRequestBody += "\", \"client_id\": \"";
 strRequestBody += browserFormInfo->clientId;
 strRequestBody += "\", \"expires_in\":";
 strRequestBody += BrowserCommon::Define::TOKEN_LIFETIME;
 strRequestBody += " }";
 debugLog(OLESTR("### strRequestBody :{0} "), strRequestBody);
 
 // ###############################
 // # request token API
 // ###############################
 ServicePointManager::SecurityProtocol = (SecurityProtocolType)3072 | (SecurityProtocolType)12288;        //3072:TLS1.2 12288:TLS1.3
 WebRequest ^request = nullptr;
 Encoding^ enc_utf8 = Encoding::UTF8;
 cli::array<unsigned char, 1> ^postData = enc_utf8->GetBytes(strRequestBody);
 Stream ^reqStream;
 WebResponse ^response;
 HttpWebResponse ^httpResponse;
 HttpStatusCode status;
 String ^responseFromServer;
 String ^requestUri = "https://" + this->browserFormInfo->host + BrowserCommon::Define::HTTP_PATH_GET_TOKEN;
 Stream^ resStream;
 StreamReader^ reader;
 
 while (true) {
 request = WebRequest::Create(requestUri);
 infoLog("WebRequest::Create():url={0}", request->RequestUri->AbsoluteUri);
 
 WebRequest::DefaultWebProxy = System::Net::WebRequest::GetSystemWebProxy();
 if (String::IsNullOrEmpty(this->browserFormInfo->proxyUsername) == false) {
 WebRequest::DefaultWebProxy->Credentials = gcnew NetworkCredential(
 this->browserFormInfo->proxyUsername, this->browserFormInfo->proxyPassword);
 }
 
 HttpWebRequest^ httpWebRequest = (HttpWebRequest^)request;
 httpWebRequest->ContentType = "application/json; charset=utf-8";
 httpWebRequest->Method = "POST";
 httpWebRequest->AllowAutoRedirect = false;
 httpWebRequest->ContentLength = postData->Length;
 // WebRequestにタイムアウトを設定
 httpWebRequest->Timeout = WEBREQUEST_TIMEOUT_MILLISECOND;
 // WebRequestにUserAgentを設定
 httpWebRequest->UserAgent = "WebRequest/" + this->browserFormInfo->userAgent;
 infoLog("WebRequest::Timeout={0}, UserAgent={1}", httpWebRequest->Timeout, httpWebRequest->UserAgent);
 
 try {
 reqStream = httpWebRequest->GetRequestStream();
 reqStream->Write(postData, 0, postData->Length);
 infoLog("Request was sent.");
 response = httpWebRequest->GetResponse();
 
 // レスポンス取得
 resStream = response->GetResponseStream();
 reader = gcnew StreamReader(resStream);
 responseFromServer = reader->ReadToEnd();
 Debug::WriteLine(responseFromServer);
 httpResponse = (HttpWebResponse^)response;
 status = httpResponse->StatusCode;
 infoLog("Response was received. X-Request-Id:{0}", httpResponse->Headers->Get("X-Request-Id"));
 debugLog("Headers:{0}", httpResponse->Headers);
 debugLog("Response:{0}", responseFromServer);
 break;
 } catch (System::Net::WebException ^ex) {
 dwRet = WebErrorProcWithSetProxy(ex, procName);
 if (dwRet == ERROR_RETRY) {
 httpResponse = nullptr;
 status = HttpStatusCode::OK;
 dwRet = ERROR_SUCCESS;
 continue;
 } else {
 //プロキシ情報入力キャンセル時は処理はWebErrorProcWithSetProxy()内で実施
 return static_cast<int>(ex->Status);
 }
 } finally {
 if (reqStream != nullptr) {
 reqStream->Close();
 }
 if (resStream != nullptr) {
 resStream->Close();
 }
 if (reader != nullptr) {
 reader->Close();
 }
 if (httpWebRequest != nullptr) {
 debugLog("Call httpWebRequest->Abort().");
 httpWebRequest->Abort();    // 連続呼び出しでエラーになる場合の対策
 }
 }
 }
 
 // ステータス判定
 if ( HttpStatusCode::OK != status ) {    //200以外はエラー
 // # get error
 Regex^ regexErr = gcnew Regex("\"error\":\"(?<error>.+)\"");
 Match^ matchErr = regexErr->Match( responseFromServer );
 String ^error = matchErr->Groups["error"]->Value;
 
 Regex^ regexErrDesc = gcnew Regex("\"error_description\":\"(?<error_description>.+)\"");
 Match^ matchErrDesc = regexErrDesc->Match( responseFromServer );
 String ^error_description = matchErrDesc->Groups["error_description"]->Value;
 Debug::WriteLine( "error:" + error );
 Debug::WriteLine( "error_description:" + error_description );
 
 errLog("GetResponse()", nullptr, procName + "error[HTTP Status:{0}]\nHeader{1}\nData\n{2}:", status,
 httpResponse->Headers->ToString(), httpResponse->GetResponseStream()->ToString());
 
 //問い合わせコードが取得できない場合の処理
 if (String::IsNullOrEmpty(error)) {
 error = BrowserCommon::Define::AUTH_ERROR_SERVICE_AVAILABLE;
 }
 
 NavigateErrorSite(error, error_description);
 return ERROR_INVALID_ACCESS;
 }
 
 // ###############################
 // # get token
 // ###############################
 Regex^ regexAccesstoken = gcnew Regex("\"access_token\":\"(?<access_token>.+?)\"");
 Match^ matchAccesstoken = regexAccesstoken->Match( responseFromServer );
 String ^access_token = matchAccesstoken->Groups["access_token"]->Value;
 
 Regex^ regexRefreshtoken = gcnew Regex("\"refresh_token\":\"(?<refresh_token>.+?)\"");
 Match^ matchRefreshtoken = regexRefreshtoken->Match( responseFromServer );
 String ^refresh_token = matchRefreshtoken->Groups["refresh_token"]->Value;
 
 Debug::WriteLine( "access_token:" + access_token );
 Debug::WriteLine( "refresh_token:" + refresh_token );
 
 if (String::IsNullOrEmpty(access_token) || String::IsNullOrEmpty(refresh_token)) {
 errLog("token is null.", nullptr, procName + "error");
 NavigateErrorSite(BrowserCommon::Define::AUTH_ERROR_SERVICE_AVAILABLE);
 return ERROR_NO_DATA;
 }
 infoLog("Succeeded in getting a token.");
 browserFormInfo->accessToken = access_token;
 browserFormInfo->refreshToken = refresh_token;
 browserFormInfo->dwDlgResult = ERROR_SUCCESS;
 infoLog(procName + " success.");
 
 return dwRet;
 }

 */

- (void)webView:(WKWebView *)webView
didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"didReceiveServerRedirectionForProvisionalNavigation");
    NSLog(@"%@",webView.URL.absoluteString);
    if ([webView.URL.absoluteString isLike:[NSString stringWithFormat:@"%@*", redirecturi]]) {
        NSArray *arr = [webView.URL.absoluteString componentsSeparatedByString:@"#code="];
        NSString *code = arr[1];
        BOOL ret = [self getToken:code];
        NSLog(@"%d",ret);
    }
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
