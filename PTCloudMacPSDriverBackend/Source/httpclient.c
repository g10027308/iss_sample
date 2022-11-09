//
//  httpclient.c
//  CupsBackend
//
//  Created by gj on 18/7/17.
//
//

#include "httpclient.h"
#include "log.h"
#include <sys/types.h>

int err_code = 0;

// CURL callback
size_t write_data(char *ptr, size_t size, size_t nmemb, void *userdata) {
    const size_t sizeInBytes = size*nmemb;
    memcpy(userdata, ptr, sizeInBytes);
    return sizeInBytes;
}

// Get Error Code
int getErrorCode(const char* buffer, char* key)
{
    int code = 0;
    cp_string value;
    cp_string strkey;
    memset(value, 0, BUFSIZE);
    memset(strkey, 0, BUFSIZE);
    
    snprintf(strkey, BUFSIZE, "%s:%s", key, "%[^,]");  //url
    char* npos = strstr(buffer, key);
    if(npos != NULL){
        // get error code
        value[0]='\0';
        //if (sscanf(npos, "\"code\":\"%4095[^,]",value)) {
        if (sscanf(npos, strkey, value)) {
            
            if (!strlen(value)){
                return code;
            }
        sscanf(value, "%*[^0-9]%i", &code);
          //  code = atoi(value);
        }
    }
    return code;
}

char getErrorMsg(const char* buffer, char* key, char* refData)
{
    bool ref = false;
    cp_string value;
    cp_string strkey;
    memset(value, 0, BUFSIZE);
    memset(strkey, 0, BUFSIZE);
    
    snprintf(strkey, BUFSIZE, "%s:%s", key, "%[^,]");  //url
    char* npos = strstr(buffer, key);
    if(npos != NULL){
        // get error code
        value[0]='\0';
        //if (sscanf(npos, "\"code\":\"%4095[^,]",value)) {
        if (sscanf(npos, strkey, value)) {
            
            if (!strlen(value)){
                return ref;
            }
            
            if(refData != NULL){
                strcpy(refData, value);
                ref = true;
            }
        }
    }
    return ref;
}

//get data to print server
long client_getinfo(const char* url, const char* post_data, char* w_outdata, int w_len, const char* proxyAddr, const char* proxyUSERPWD)
{
    cp_string outdata;
    memset(outdata, 0, sizeof(outdata));
    
    long response_code = 0;
    if (url == NULL || url[0] == '\0')
    {
        log_event(CPERROR, "invalid parameter");
        return response_code;
    }
    
    CURL* curl = curl_easy_init();
    if (curl == NULL)
    {
        log_event(CPERROR, "failed to init curl_easy_init");
        return response_code;
    }
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
    
    //set_proxy(curl);
    if (proxyAddr != NULL && strlen(proxyAddr)){
        curl_easy_setopt(curl, CURLOPT_PROXY, proxyAddr);
    }
    
    if(proxyUSERPWD != NULL && strlen(proxyUSERPWD)){
        curl_easy_setopt(curl, CURLOPT_PROXYUSERPWD, proxyUSERPWD);
    }
    
    
    // Set some CURL options
    curl_easy_setopt(curl,CURLOPT_HEADER, 1L);
    curl_easy_setopt(curl,CURLOPT_HTTPGET, 1L); //设置问非0表示本次操作为get
    curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1L);
    //curl_easy_setopt(curl, CURLOPT_TIMEOUT, 1);
    //curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 3);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10);
    curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 10);
    
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &outdata); // write_data的第四个参数值
    
    // Set URL
    curl_easy_setopt(curl, CURLOPT_URL, url);
    
    cp_string _header;
    snprintf(_header, BUFSIZE, "%s%s", "Authorization: Bearer ", post_data);
    
    struct curl_slist *headers = NULL;
    headers = curl_slist_append(headers, _header);
    //headers = curl_slist_append(headers, "Authorization: Bearer 82izj5jyg2eozoWXdASXyQlRCSf1by9nELFKJE7JcCWgRt87rig6QZbwoL3bGOtf");
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    
    CURLcode result = curl_easy_perform(curl);
    if (result == CURLE_OK)
    {
        memcpy(w_outdata, outdata, w_len);
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
        
        log_event(CPDEBUG, "client_post result: %s, err_code: %d", outdata, response_code);
        log_event(CPSTATUS, "client_post successfully!" );
    }
    else
    {
        log_event(CPERROR, "failed to curl_easy_perform, url = %s, result = %d", url, result);
    }
    curl_easy_cleanup(curl);
    return response_code;
}

long client_posttoken(const char* url, const char* post_data, char* w_outdata, int w_len, const char* proxyAddr, const char* proxyUSERPWD)
{
    cp_string outdata;
    memset(outdata, 0, sizeof(outdata));
    
    long response_code = 0;
    if (url == NULL || url[0] == '\0')
    {
        log_event(CPERROR, "invalid parameter");
        return response_code;
    }
    
    CURL* curl = curl_easy_init();
    if (curl == NULL)
    {
        log_event(CPERROR, "failed to init curl_easy_init");
        return response_code;
    }
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
    
    //set_proxy(curl);
    if (proxyAddr != NULL && strlen(proxyAddr)){
        curl_easy_setopt(curl, CURLOPT_PROXY, proxyAddr);
    }
    
    if(proxyUSERPWD != NULL && strlen(proxyUSERPWD)){
        curl_easy_setopt(curl, CURLOPT_PROXYUSERPWD, proxyUSERPWD);
    }
    
    curl_easy_setopt(curl, CURLOPT_URL, url);
    if (post_data != NULL && post_data[0] != '\0')
    {
        curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)strlen(post_data));
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, post_data);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &outdata); // write_data的第四个参数值
    }
    
    // time
    curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1L);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10);
    curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 10);
    
    // Disable "Expect: 100-continue"
    struct curl_slist *headers = NULL;
    headers=curl_slist_append(headers, "Content-Type:application/json");
    headers=curl_slist_append(headers, "charset=UTF-8");
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    
    CURLcode result = curl_easy_perform(curl);
    if (result == CURLE_OK)
    {
        memcpy(w_outdata, outdata, w_len);
        //result = curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
        
        log_event(CPDEBUG, "client_post result: %s, err_code: %d", outdata, err_code);
        log_event(CPSTATUS, "client_post successfully!" );
    }
    else
    {
        log_event(CPERROR, "failed to curl_easy_perform, url = %s, result = %d", url, result);
    }
    curl_easy_cleanup(curl);
    curl_slist_free_all(headers);
    return response_code;
}


long client_post_multipart(const char* url, const struct POST_PART_DATA* post_data, size_t post_data_count, const char* proxyAddr, const char* proxyUSERPWD, char *argv[], FILE *fStderr, char* version, char* build)
{
    char refdata[BUFSIZE];
    cp_string outdata;
    memset(outdata, 0, sizeof(outdata));
    long response_code = 0;
    if (url == NULL || url[0] == '\0')
    {
        log_event(CPERROR, "invalid parameter");
        return response_code;
    }
    CURL* curl = curl_easy_init();
    if (curl == NULL)
    {
        log_event(CPERROR,"failed to init curl_easy_init");
        return response_code;
    }
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
    //curl_easy_setopt(curl, CURLOPT_CAINFO, "/private/etc/cups/cacert.pem"); // set root CA certs
    
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &outdata);
    
    if (proxyAddr != NULL && strlen(proxyAddr)){
        curl_easy_setopt(curl, CURLOPT_PROXY, proxyAddr);
    }
    
    if(proxyUSERPWD != NULL && strlen(proxyUSERPWD)){
        curl_easy_setopt(curl, CURLOPT_PROXYUSERPWD, proxyUSERPWD);
    }
    //curl_easy_setopt(curl, CURLOPT_PROXY, "127.0.0.1:8080");
    //curl_easy_setopt(curl, CURLOPT_PROXYUSERPWD, [@"USER:PW" UTF8String]);
    
    // set url
    curl_easy_setopt(curl, CURLOPT_URL, url);
    
    struct curl_httppost* post = NULL;
    struct curl_httppost* last = NULL;
    for (size_t i = 0; i < post_data_count; ++i)
    {
        if (!post_data[i].bFile)
        {
            curl_formadd(&post, &last, CURLFORM_COPYNAME, post_data[i].key_name, CURLFORM_COPYCONTENTS, post_data[i].value, CURLFORM_END);
            
            log_event(CPDEBUG,"post_data: key = %s, value = %s", post_data[i].key_name, post_data[i].value);
        }
        else
        {
            curl_formadd(&post, &last, CURLFORM_COPYNAME, "filename", CURLFORM_COPYCONTENTS, post_data[i].key_name, CURLFORM_END);
            curl_formadd(&post, &last, CURLFORM_COPYNAME, "doc_file", CURLFORM_FILE, post_data[i].value, CURLFORM_CONTENTTYPE, "multipart/form-data", CURLFORM_END);
            
            log_event(CPDEBUG,"post_data: filename = %s, filePath = %s", post_data[i].key_name, post_data[i].value);
        }
    }
    curl_easy_setopt(curl, CURLOPT_HTTPPOST, post);
    
    //ユーザーごとのaccess_tokenファイルのディレクトリ
    cp_string access_token_path;
    char *user;
    size_t size;
    size=strlen(argv[2])+1;
    user=calloc(size, sizeof(char));
    snprintf(user, size, "%s", argv[2]);
    //char loginUser = getlogin();
    strcpy(access_token_path, "/var/log/cups/access_token_na_o365_");
    strcat(access_token_path, user);
    strcat(access_token_path, ".txt");
    
    char access_token[1000] = {0};
    FILE *fp = fopen(access_token_path, "r");
    if (NULL == fp){
        printf("fail to open access_token_na_o365.txt\n");
        exit(1);
    }
    
    while(!feof(fp))
    {
        memset(access_token, 0, sizeof(access_token));
        fgets(access_token, sizeof(access_token) - 1, fp); // 包含了换行符
        printf("%s", access_token);
    }
    fclose(fp);
    
    cp_string _header, useragent;
    snprintf(_header, BUFSIZE, "%s%s", "Authorization: Bearer ", access_token);
    //snprintf(_header, BUFSIZE, "%s%s", "Authorization: Basic ", access_token);
    snprintf(useragent, BUFSIZE, "User-Agent: RICOH FRCX Port for Mac 1.4.0.0/(Version %s (Build %s))", version, build); //1.3.0.0はアプリのバージョンであり、毎回変更されます
    
    // Disable "Expect: 100-continue"
    struct curl_slist *headers = NULL;
    //headers = curl_slist_append(headers, "Expect:");
    headers = curl_slist_append(headers, "Accept: application/json");
    headers = curl_slist_append(headers, useragent);
    headers = curl_slist_append(headers, _header);
    
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    
    CURLcode result = curl_easy_perform(curl);
    if (result == CURLE_OK)
    {
        //result = curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
        
        err_code = getErrorCode(outdata, "\"inquiry_code\""); //Get error code
        if(err_code == 0){
            memset(refdata, 0, BUFSIZE);
            getErrorMsg(outdata, "\"errors\"", refdata);
            err_code = (char)refdata;
        }
        
        log_event(CPDEBUG, "client_post_multipart result: %s, err_code: %d", outdata, err_code);
        log_event(CPSTATUS, "client_post_multipart successfully");
    }
    else
    {
        log_event(CPERROR,"failed to curl_easy_perform, url = %s, result = %d", url, result);
    }
    curl_easy_cleanup(curl);
    //curl_formfree(post);
    curl_slist_free_all(headers);
    return response_code;
}



//bool check_connect(const char* url, const char* proxyAddr, const char* proxyUSERPWD, const char* UID, char* usercode)
bool check_connect(const char* url, const char* proxyAddr, const char* proxyUSERPWD, char* usercode)
{
    bool bRef = false;
    
    char* access_token = usercode;
    
    cp_string post_data;
    memset(post_data, 0, BUFSIZE);
    //snprintf(post_data, BUFSIZE, "accesskey=%s", access_token);  //post_data
    snprintf(post_data, BUFSIZE, "%s", access_token);

    log_event(CPDEBUG,"check_connect post_data = %s", post_data);

    char outdata[BUFSIZE] = { 0 };
    //long response_code = client_post(url, post_data, outdata, BUFSIZE, proxyAddr, proxyUSERPWD);
    long response_code = client_getinfo(url, post_data, outdata, BUFSIZE, proxyAddr, proxyUSERPWD);
    if (response_code != 200 || (GetCurErrCode() != 200 && GetCurErrCode() != 0))
    {
        // network error
        log_event(CPDEBUG,"failed to check_connect, url = %s, response code = %d", url, response_code);
        bRef = false;
    }
    else
    {
        log_event(CPDEBUG,"success to check_connect, url = %s, response code = %d", url, response_code);
        bRef = true;
    }
    return bRef;
}

int GetCurErrCode(){
    return err_code;
}
