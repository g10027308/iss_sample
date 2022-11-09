//
//  httpclient.h
//  CupsBackend
//
//  Created by gj on 18/7/17.
//
//

#ifndef httpclient_h
#define httpclient_h

#include <stdio.h>

#include <stdbool.h>
#include <curl/curl.h>
#include <openssl/ssl.h>


struct POST_PART_DATA
{
    char *key_name;
    char *value;
    int  bFile;
};

struct GET_POWER_DATA
{
    char *key_name;
    char *value;
};


long client_posttoken(const char* url, const char* post_data, char* w_outdata, int w_len, const char* proxyAddr, const char* proxyUSERPWD);

long client_getinfo(const char* url, const char* post_data, char* w_outdata, int w_len, const char* proxyAddr, const char* proxyUSERPWD);

long client_post_multipart(const char* url, const struct POST_PART_DATA* post_data, size_t post_data_count, const char* proxyAddr, const char* proxyUSERPWD, char *argv[], FILE *fStderr, char* version, char* build);

// check server connect
//bool check_connect(const char* url, const char* proxyAddr, const char* proxyUSERPWD, const char* UID, char* usercode);
bool check_connect(const char* url, const char* proxyAddr, const char* proxyUSERPWD, char* usercode);


int GetCurErrCode(void);

#endif /* httpclient_h */
