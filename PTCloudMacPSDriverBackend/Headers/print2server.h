//
//  print2server.h
//  CUPSBackend
//
//  Created by gj on 18/7/11.
//  Copyright © 2018年 RITS. All rights reserved.
//

#ifndef _PRINT2SERVER_H_
#define _PRINT2SERVER_H_

/* User-customizable settings - if unsure leave the default values 
/  they are reasonable for most systems.			     */

/* location of the configuration file */
#define CP_CONFIG_PATH "/etc/cups"


/* --- DO NOT EDIT BELOW THIS LINE --- */

/* The following settings are for internal purposes only - all relevant 
/  options listed below can be set via cups-pdf.conf at runtime		*/

#define CPVERSION "v1.1.0"

#define CPERROR         1
#define CPSTATUS        2
#define CPDEBUG         4

//#define BUFSIZE 4096
//#define TBUFSIZE "4096"
//
//typedef char cp_string[BUFSIZE];


#define SEC_CONF  1
#define SEC_PPD   2
#define SEC_LPOPT 4

//#define PATH_USER_PLIST     "/etc/cups/com.rits.PdfDriverInstaller.plist"
//#define PATH_BACKEND_PLIST  "/var/spool/print2server/SPOOL/com.rits.PdfDriverInstaller.plist"
/* order in the enum and the struct-array has to be identical! */

typedef enum econfigOptions { ServerAddr, PrintServerAddr, UsePrintServer, ProxyAddr, ProxyUserPWD, AddrMode, AddrModeForLocal, AnonUser, Grp, Log, Spool, LogType, LowerCase, END_OF_OPTIONS } configOptions;

struct {
  char *key_name;
  int security;
  union {
    cp_string sval;
    int ival;
    mode_t modval;
  } value;
} configData[] = {
  { "ServerAddr", SEC_CONF|SEC_PPD, { "10.71.11.248" } },
  { "PrintServerAddr", SEC_CONF|SEC_PPD, { "10.71.11.248" } },
  { "UsePrintServer", SEC_CONF|SEC_PPD, {{ 0 }} },
  { "ProxyAddr", SEC_CONF|SEC_PPD, { "" } },
  { "ProxyUserPWD", SEC_CONF|SEC_PPD, { "" } },
  { "AddrMode", SEC_CONF|SEC_PPD, { "http" } },
  { "AddrModeForLocal", SEC_CONF|SEC_PPD, { "http" } },
  { "AnonUser", SEC_CONF|SEC_PPD, { "nobody" } },
  { "Grp", SEC_CONF|SEC_PPD, { "staff" } },
  { "Log", SEC_CONF|SEC_PPD, { "/var/log/cups" } },
  { "Spool", SEC_CONF|SEC_PPD, { "/var/spool/print2server/SPOOL" } },
  { "LogType", SEC_CONF|SEC_PPD, {{ 2 }} },
  { "LowerCase", SEC_CONF|SEC_PPD, {{ 1 }} },
};

#define Conf_VerifyServerAddr     configData[ServerAddr].value.sval
#define Conf_ServerAddr           configData[ServerAddr].value.sval
#define Conf_PrintServerAddr      configData[PrintServerAddr].value.sval
#define Conf_UsePrintServer       configData[UsePrintServer].value.ival
#define Conf_ProxyAddr            configData[ProxyAddr].value.sval
#define Conf_ProxyUserPWD         configData[ProxyUserPWD].value.sval
#define Conf_AddrMode             configData[AddrMode].value.sval
#define Conf_AddrModeForLocal     configData[AddrModeForLocal].value.sval
#define Conf_AnonUser             configData[AnonUser].value.sval
#define Conf_Grp                  configData[Grp].value.sval
#define Conf_Log                  configData[Log].value.sval
#define Conf_Spool                configData[Spool].value.sval
#define Conf_LogType              configData[LogType].value.ival
#define Conf_LowerCase            configData[LowerCase].value.ival

// post client
#define YJSMB_PRINT_ACCESS_TOKEN "0337cd7eaf3cae3ea9b2b5183ff560dfba628d91"
#define CSAMPMS_PRINT_ACCESS_TOKEN "NWe8MiHvsG0yC3aK95OLEVmbBUf7rtcu"
//#define RITRAC_PRINT_ACCESS_TOKEN "OGJsahyU62WZkcurCHoemPXp0jQFwSt3"
#define UPLOAD_ADDR "/Share/uploadFileForMac/"
#define TEST_ADDR "/GetCorpInfoByDriver"
#define TESTLOCAL_ADDR "/Login"
#define VERIFY_ADDR_DINGPRINT "/getUserMfpPower"
#define VERIFY_ADDR_CSAMPMS "/getUserMachinePower"

typedef enum erefVerifyDataOptions { SCAN, MONOCOPY, COLORCOPY, MONOPRINT, COLORPRINT, FAX, PRINTBWDUPLEX, SEAL, WATERIMG, WATERFONT, WATERQRCODE, BACKUPPRINT, BACKUPCOPY, BACKUPSCAN, KEYWORDSYSTEM, KEYWORDREVIEW, KEYWORDALARM, END_OF_VERIFYOPTIONS } refVerifyDataOptions;
struct {
    char *verify_keyname;
    union {
        cp_string sval;
        bool bval;
    } value;
} refData[] = {
    { "Scan", {false}},
    { "MonoCopy", {false}},
    { "ColorCopy", {false}},
    { "MonoPrint", {false}},
    { "ColorPrint", {false}},
    { "Fax", {false}},
    { "PrintBWDuplex", {false}},
    { "Seal", {false}},
    { "WaterImg", {false}},
    { "WaterFont", {false}},
    { "WaterQRCode", {false}},
    { "BackUpPrint", {false}},
    { "BackUpCopy", {false}},
    { "BackUpScan", {false}},
    { "KeyWordSystem", {false}},
    { "KeyWordReview", {false}},
    { "KeyWordAlarm", {false}},

};

//////////////////////////////////////////////////////
// PJL Options
typedef enum epjlDataOptions { JOBNAME, USERID, FITTOPAGESIZE, RENDERMODE, QTYCOPIES, DUPLEX, BINDING, END_OF_PJLOPTIONS } pjlDataOptions;

struct {
    char *pjl_keyname;
    char *post_keyname;
    union {
        cp_string sval;
        int ival;
    } value;
} pjlData[] = {
    { "JOBNAME", "file", { "" } },
    { "USERID", "userpincode", { "" } },
    { "FITTOPAGESIZE", "papersize", { "" } },
    { "RENDERMODE", "color", { "" } },
    { "QTYCOPIES", "qtycopies", { "" } },
    { "DUPLEX", "side", { "" } },
    { "BINDING", "direction", { "" } },
};


//////////////////////////////////////////////////////
// plist data
//typedef enum eplistDataOptions { LASTIP, LASTIPPORT, PASSWORD, PRINTERDESCRIPTION, PROXYIP1, PROXYIP2, PROXYIP3, PROXYIP4, PROXYPORT, SERVERNAME, SERVERPORT, UID, USEHTTPS, USEPROXY, USERNAME, END_OF_PLISTOPTIONS } plistDataOptions;
typedef enum eplistDataOptions { LASTIP, LASTIPPORT, PASSWORD, PRINTERDESCRIPTION, PROXYIP, PROXYPORT, SERVERNAME, PRINTSERVERNAME, SERVERPORT, UID, USEHTTPS, USEPROXY, USERNAME, ACCESSTOKEN, REFRESHTOKEN, REDIRECTURI, MAIL, MAILPASSWORD, CLIENTID, TENANTID, TUSERID, USERPASSWORD, CODECHALLENGE, CODEVERIFIER, END_OF_PLISTOPTIONS } plistDataOptions;

struct {
    char *keyname;
    union {
        cp_string sval;
        int ival;
    } value;
} plistData[] = {
    { "LastIP", {""}},
    { "LastIPPort", {""}},
    { "Password", {""}},
    { "PrinterDescription", {""}},
    { "ProxyIP", {""}},
    { "ProxyPort", {""}},
    { "ServerName", {""}},
    { "PrintServerName", {""}},
    { "ServerPort", {""}},
    { "UID", {""}},
    { "UseHttps", {0}},
    { "UseProxy", {0}},
    { "UserName", ""},
    { "AccessToken", {""}},
    { "RefreshToken", {""}},
    { "Redirecturi", {""}},
    { "Mail", {""}},
    { "MailPassword", {""}},
    { "ClientID", {""}},
    { "TenantID", {""}},
    { "UserID", {""}},
    { "UserPassword", {""}},
    { "CodeChallenge", {""}},
    { "CodeVerifier", {""}},
};

#define Plist_LastIP              plistData[LASTIP].value.sval  //may have tail blanks
#define Plist_LastIPPort          plistData[LASTIPPORT].value.sval  //may have tail blanks
#define Plist_PrintServerName     plistData[PRINTSERVERNAME].value.sval  //Print Server
#define Plist_ServerName          plistData[SERVERNAME].value.sval  //Authen Server
#define Plist_ServerPort          plistData[SERVERPORT].value.sval
#define Plist_UID                 plistData[UID].value.sval
#define Plist_UseProxy            plistData[USEPROXY].value.ival

#define Plist_AccessToken         plistData[ACCESSTOKEN].value.sval
#define Plist_RefreshToken        plistData[REFRESHTOKEN].value.sval
#define Plist_Redirecturi         plistData[REDIRECTURI].value.sval
#define Plist_Mail                plistData[MAIL].value.sval
#define Plist_MailPassword        plistData[MAILPASSWORD].value.sval
#define Plist_TenantID            plistData[TENANTID].value.sval
#define Plist_UserID              plistData[TUSERID].value.sval
#define Plist_UserPassword        plistData[USERPASSWORD].value.sval
#define Plist_ClientId            plistData[CLIENTID].value.sval
#define Plist_CodeChallenge       plistData[CODECHALLENGE].value.sval
#define Plist_CodeVerifier        plistData[CODEVERIFIER].value.sval



typedef enum eosplistOptions { BUILD, VERSION, END_OF_OSPLISTOPTIONS } osplistDataOptions;

struct {
    char *keyname;
    union {
        cp_string sval;
        int ival;
    } value;
} osplistData[] = {
    { "ProductBuildVersion", {""}},
    { "ProductVersion", {""}},
};

#define OS_Build           osplistData[BUILD].value.sval
#define OS_Version         osplistData[VERSION].value.sval

///////////////////////////////////////////////
// MSG Def
#define MSGIN_CONTECT_TO_DEVICE "STATE: +connecting.to.device\n"
#define MSGOUT_CONTECT_TO_DEVICE "STATE: -connecting.to.device\n"
#define MSGIN_CONTECT_CLOUDSERVER_ERROR "STATE: +com.dprint.connect-cloudserver-error\n"
#define MSGOUT_CONTECT_CLOUDSERVER_ERROR "STATE: -com.dprint.connect-cloudserver-error\n"
#define MSGIN_CONTECT_LOCALSERVER_ERROR "STATE: +com.dprint.connect-localserver-error\n"
#define MSGOUT_CONTECT_LOCALSERVER_ERROR "STATE: -com.dprint.connect-localserver-error\n"
#define MSGIN_GET_USER_POWER_ERROR "STATE: +com.dprint.get-user-power-error\n"
#define MSGOUT_GET_USER_POWER_ERROR "STATE: -com.dprint.get-user-power-error\n"
#define MSGIN_PRINTING_COLOR_ERROR "STATE: +com.dprint.printing-color-error\n"
#define MSGOUT_PRINTING_COLOR_ERROR "STATE: -com.dprint.printing-color-error\n"
#define MSGIN_PRINTING_GRAY_ERROR "STATE: +com.dprint.printing-gray-error\n"
#define MSGOUT_PRINTING_GRAY_ERROR "STATE: -com.dprint.printing-gray-error\n"
//#define MSGIN_UPLOAD_FILE_ERROR "STATE: +com.dprint.upload-file-error\n"
//#define MSGOUT_UPLOAD_FILE_ERROR "STATE: -com.dprint.upload-file-error\n"

// Error information by code
// 800
//#define MSGIN_CONTECT_OTHERS_ERROR1 "STATE: +com.dprint.upload-file1-error\n"
#define MSGIN_CONTECT_OTHERS_ERROR "STATE: +com.dprint.connect-others-error\n"
#define MSGOUT_CONTECT_OTHERS_ERROR "STATE: -com.dprint.connect-others-error\n"
// 401
#define MSGIN_CONTECT_ACCESSKEY_ERROR "STATE: +com.dprint.connect-accessKey-error\n"
#define MSGOUT_CONTECT_ACCESSKEY_ERROR "STATE: -com.dprint.connect-accessKey-error\n"
// 400
#define MSGIN_CONTECT_LACKPARAMETERS_ERROR "STATE: +com.dprint.connect-lackparam-error\n"
#define MSGOUT_CONTECT_LACKPARAMETERS_ERROR "STATE: -com.dprint.connect-lackparam-error\n"

// 810
#define MSGIN_CONTECT_DATABASE_ERROR "STATE: +com.dprint.connect-database-error\n"
#define MSGOUT_CONTECT_DATABASE_ERROR "STATE: -com.dprint.connect-database-error\n"
// 811
#define MSGIN_CONTECT_USERNOTEXIST_ERROR "STATE: +com.dprint.connect-usernoexist-error\n"
#define MSGOUT_CONTECT_USERNOTEXIST_ERROR "STATE: -com.dprint.connect-usernoexist-error\n"
// 812
#define MSGIN_CONTECT_USERFORBIDDAN_ERROR "STATE: +com.dprint.connect-useraforbiddan-error\n"
#define MSGOUT_CONTECT_USERFORBIDDAN_ERROR "STATE: -com.dprint.connect-useraforbiddan-error\n"
// 820
#define MSGIN_CONTECT_BILLNOTTURNON_ERROR "STATE: +com.dprint.connect-billfuncnostart-error\n"
#define MSGOUT_CONTECT_BILLNOTTURNON_ERROR "STATE: -com.dprint.connect-billfuncnostart-error\n"

// 825
#define MSGIN_CONTECT_FORBIDDENUSER_ERROR "STATE: +com.dprint.connect-userforbidden-error\n"
#define MSGOUT_CONTECT_FORBIDDENUSER_ERROR "STATE: -com.dprint.connect-userforbidden-error\n"

// 826
#define MSGIN_CONTECT_PASSTRIALPERIOD_ERROR "STATE: +com.dprint.connect-passtrialperiod-error\n"
#define MSGOUT_CONTECT_PASSTRIALPERIOD_ERROR "STATE: -com.dprint.connect-passtrialperiod-error\n"

// There is don't exist available IP address.
#define MSGIN_GET_AVAILABLE_IPADDRESS_ERROR "STATE: +com.dprint.connect-avableipaddr-error\n"
#define MSGOUT_GET_AVAILABLE_IPADDRESS_ERROR "STATE: -com.dprint.connect-avableipaddr-error\n"


//↓↓↓↓↓↓↓↓↓↓↓ISS向けのメッセージ
//その他のエラー
#define MSGIN_UPLOAD_FILE_ERROR "STATE: +frcxprint.err.param.upload.file.error\n"
#define MSGOUT_UPLOAD_FILE_ERROR "STATE: -frcxprint.err.param.upload.file.error\n"

//13013101
#define MSGIN_INVALID_CONTENT_TYPE "STATE: +frcxprint.err.param.invalid.rq.ct_type\n"
#define MSGOUT_INVALID_CONTENT_TYPE "STATE: -frcxprint.err.param.invalid.rq.ct_type\n"

//13013405
#define MSGIN_INVALID_ORGID "STATE: +frcxprint.err.param.invalid.uri.org_id\n"
#define MSGOUT_INVALID_ORGID "STATE: -frcxprint.err.param.invalid.uri.org_id\n"

//13013406
#define MSGIN_INVALID_USERID "STATE: +frcxprint.err.param.invalid.uri.user_id\n"
#define MSGOUT_INVALID_USERID "STATE: -frcxprint.err.param.invalid.uri.user_id\n"

//13013307
#define MSGIN_CONTENTS_NULL "STATE: +frcxprint.err.param.invalid.doc.ct.null\n"
#define MSGOUT_CONTENTS_NULL "STATE: -frcxprint.err.param.invalid.doc.ct.null\n"

//13013301
#define MSGIN_INVALID_DOCNAME "STATE: +frcxprint.err.param.invalid.doc.name\n"
#define MSGOUT_INVALID_DOCNAME "STATE: -frcxprint.err.param.invalid.doc.name\n"

//13013303
#define MSGIN_INVALID_DOCTYPE "STATE: +frcxprint.err.param.invalid.doc.type\n"
#define MSGOUT_INVALID_DOCTYPE "STATE: -frcxprint.err.param.invalid.doc.type\n"

//13013302
#define MSGIN_INVALID_DOCSIZE "STATE: +frcxprint.err.param.invalid.doc.size\n"
#define MSGOUT_INVALID_DOCSIZE "STATE: -frcxprint.err.param.invalid.doc.size\n"

//13013308
#define MSGIN_INVALID_DOCSIZE0 "STATE: +frcxprint.err.param.invalid.doc.size=0\n"
#define MSGOUT_INVALID_DOCSIZE0 "STATE: -frcxprint.err.param.invalid.doc.size=0\n"

//13013309
#define MSGIN_INVALID_DOCNAME_LENGTH "STATE: +frcxprint.err.param.invalid.doc.name.lh\n"
#define MSGOUT_INVALID_DOCNAME_LENGTH "STATE: -frcxprint.err.param.invalid.doc.name.lh\n"

//13013310
#define MSGIN_INVALID_DOCNUM_OVER "STATE: +frcxprint.err.param.doc.num.over\n"
#define MSGOUT_INVALID_DOCNUM_OVER "STATE: -frcxprint.err.param.doc.num.over\n"

//13013201
#define MSGIN_INVALID_COLOR "STATE: +frcxprint.err.param.invalid.color\n"
#define MSGOUT_INVALID_COLOR "STATE: -frcxprint.err.param.invalid.color\n"

//13013204
#define MSGIN_INVALID_DUPLEX "STATE: +frcxprint.err.param.invalid.duplex\n"
#define MSGOUT_INVALID_DUPLEX "STATE: -frcxprint.err.param.invalid.duplex\n"

//13013205
#define MSGIN_INVALID_LAYOUT "STATE: +frcxprint.err.param.invalid.layout\n"
#define MSGOUT_INVALID_LAYOUT "STATE: -frcxprint.err.param.invalid.layout\n"

//13013202
#define MSGIN_INVALID_COPIES "STATE: +frcxprint.err.param.invalid.copies\n"
#define MSGOUT_INVALID_COPIES "STATE: -frcxprint.err.param.invalid.copies\n"

//13013208
#define MSGIN_INVALID_PAPERSIZE "STATE: +frcxprint.err.param.invalid.paper_size\n"
#define MSGOUT_INVALID_PAPERSIZE "STATE: -frcxprint.err.param.invalid.paper_size\n"

//13013216
#define MSGIN_INVALID_TXT_RENDER_ENC "STATE: +frcxprint.err.param.invalid.txt\n"
#define MSGOUT_INVALID_TXT_RENDER_ENC "STATE: -frcxprint.err.param.invalid.txt\n"

//13013217
#define MSGIN_INVALID_USERCODE "STATE: +frcxprint.err.param.invalid.user_code\n"
#define MSGOUT_INVALID_USERCODE "STATE: -frcxprint.err.param.invalid.user_code\n"

//13013206
#define MSGIN_INVALID_ORIENTATION "STATE: +frcxprint.err.param.invalid.orientation\n"
#define MSGOUT_INVALID_ORIENTATION "STATE: -frcxprint.err.param.invalid.orientation\n"

//13011001
#define MSGIN_ABSENT_COOKIE "STATE: +frcxprint.err.absent_cookie_ticket\n"
#define MSGOUT_ABSENT_COOKIE "STATE: -frcxprint.err.absent_cookie_ticket\n"

//13011005
#define MSGIN_UNAUTHORIZED "STATE: +frcxprint.err.unauthorized.service\n"
#define MSGOUT_UNAUTHORIZED "STATE: -frcxprint.err.unauthorized.service\n"

//13011006
#define MSGIN_UNAUTHORIZED_SERVICE_USER "STATE: +frcxprint.err.unauthorized.service.user\n"
#define MSGOUT_UNAUTHORIZED_SERVICE_USER "STATE: -frcxprint.err.unauthorized.service.user\n"

void SignalTermHandler(int Signal);
#endif
