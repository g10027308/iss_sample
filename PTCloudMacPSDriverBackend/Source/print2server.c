//
//  main.c
//  CUPSFilter
//
//  Created by gj on 18/7/11.
//  Copyright © 2018年 RITS. All rights reserved.
//

#include <time.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <fcntl.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <stddef.h>
#include <pwd.h>
#include <grp.h>
#include <stdarg.h>
#include <dirent.h>

#include <signal.h>
#include <sys/select.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>

#include <cups/cups.h>
#include <cups/ppd.h>
#include <cups/backend.h>
#include <cups/sidechannel.h>


#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <net/if.h>
#include <unistd.h>
#include <arpa/inet.h>


#include "log.h"
#include "httpclient.h"
#include "print2server.h"


#include <openssl/sha.h>


static int job_canceled = 0;    //Job cancelled?
static int last_job_id = 0;     //Last Job ID

char destIpAddress[16] = {0};  //the ip address of the server which print data will send to
char destIpPort[6] = {0};
char lastIpAddress[16] = {0};  //last ip address (may have tail blanks)
char lastIpPort[6] = {0};  //last ip port (may have tail blanks)
char cUserCode[32] = {0}; // user code return from API /citicUserLogin

extern char *GetSerialNumber(void);
extern void SetUserID(char *);
extern char *GetUserID(void);
extern unsigned char *getmypass(char *, char *, int *);
extern char *decrypt(unsigned char *, char *, char *, int);

static int create_dir(char *dirname, int nolog) {
    struct stat fstatus;
    char buffer[BUFSIZE],*delim;
    size_t i;
    
    while ((i=strlen(dirname))>1 && dirname[i-1]=='/')
        dirname[i-1]='\0';
    if (stat(dirname, &fstatus) || !S_ISDIR(fstatus.st_mode)) {
        strncpy(buffer,dirname,BUFSIZE);
        delim=strrchr(buffer,'/');
        if (delim!=buffer)
            delim[0]='\0';
        else
            delim[1]='\0';
        if (create_dir(buffer,nolog)!=0)
            return 1;
        (void) stat(buffer, &fstatus);
        if (mkdir(dirname,fstatus.st_mode)!=0) {
            if (!nolog)
                log_event(CPERROR, "failed to create directory: %s", dirname);
            return 1;
        }
        else
            if (!nolog)
                log_event(CPSTATUS, "directory created: %s", dirname);
        if (chown(dirname,fstatus.st_uid,fstatus.st_gid)!=0)
            if (!nolog)
                log_event(CPDEBUG, "failed to set owner on directory: %s (non fatal)", dirname);
    }
    return 0;
}

static int _assign_value(int security, char *key, char *value) {
    int tmp;
    int option;
    
    for (option=0; option<END_OF_OPTIONS; option++) {
        if (!strcasecmp(key, configData[option].key_name))
            break;
    }
    
    if (option == END_OF_OPTIONS) {
        return 0;
    }
    
    if (!(security & configData[option].security)) {
        log_event(CPERROR, "Unsafe option not allowed: %s", key);
        return 0;
    }
    
    switch(option) {
        case ServerAddr:
            strncpy(Conf_ServerAddr, value, BUFSIZE);
            break;
        case PrintServerAddr:
            strncpy(Conf_PrintServerAddr, value, BUFSIZE);
            break;
        case UsePrintServer:
            tmp=atoi(value);
            Conf_UsePrintServer=(tmp)?1:0;
            break;
        case ProxyAddr:
            strncpy(Conf_ProxyAddr, value, BUFSIZE);
            break;
        case ProxyUserPWD:
            strncpy(Conf_ProxyUserPWD, value, BUFSIZE);
            break;
        case AddrMode:
            strncpy(Conf_AddrMode, value, BUFSIZE);
            break;
        case AddrModeForLocal:
            strncpy(Conf_AddrModeForLocal, value, BUFSIZE);
            break;
        case AnonUser:
            strncpy(Conf_AnonUser, value, BUFSIZE);
            break;
        case Grp:
            strncpy(Conf_Grp, value, BUFSIZE);
            break;
        case Log:
            strncpy(Conf_Log, value, BUFSIZE);
            break;
        case Spool:
            strncpy(Conf_Spool, value, BUFSIZE);
            break;
        case LogType:
            tmp=atoi(value);
            Conf_LogType=(tmp>7)?7:((tmp<0)?0:tmp);
            break;
        case LowerCase:
            tmp=atoi(value);
            Conf_LowerCase=(tmp)?1:0;
            break;
        default:
            log_event(CPERROR, "Program error: option not treated: %s = %s\n", key, value);
            return 0;
    }
    return 1;
}

static void read_config_file(char *filename) {
    FILE *fp=NULL;
    struct stat fstatus;
    cp_string buffer, key, value;
    
    if ((strlen(filename) > 1) && (!stat(filename, &fstatus)) &&
        (S_ISREG(fstatus.st_mode) || S_ISLNK(fstatus.st_mode))) {
        fp=fopen(filename,"r");
    }
    if (fp==NULL) {
        log_event(CPERROR, "Cannot open config: %s", filename);
        return;
    }
    
    while (fgets(buffer, BUFSIZE, fp) != NULL) {
        key[0]='\0';
        value[0]='\0';
        if (sscanf(buffer,"%s %[^\n]",key,value)) {
            if (!strlen(key) || !strncmp(key,"#",1))
                continue;
            _assign_value(SEC_CONF, key, value);
        }
    }
    
    (void) fclose(fp);
    return;
}
/*
static int _assign_plistdata2(char *key, unsigned char *value, int size) {
    unsigned char *p;
    int i, option;
    
    for (option = 0; option < END_OF_PLISTOPTIONS; option++) {
        if (!strcasecmp(key, plistData[option].keyname))
            break;
    }
    
    if (option == END_OF_PLISTOPTIONS) {
        return 0;
    }
    
    memset(plistData[option].value.pval, 0x00, BUFSIZE);
    memcpy(plistData[option].value.pval, value, size);
    log_event(CPSTATUS, "Password[%s]%d: %s ,size: %d\n", key, option, plistData[option].value.pval, size);
    
    return 1;
}
*/

static int _assign_plistdata(char *key, char *value, int isBE) {
    int tmp;
    int option;
    
    for (option=0; option<END_OF_PLISTOPTIONS; option++) {
        if (!strcasecmp(key, plistData[option].keyname))
            break;
    }
    
    if (option == END_OF_PLISTOPTIONS) {
        return 0;
    }

    if(isBE)
    {
    //Set Backend Setting
    switch(option) {
        case LASTIP:
            strncpy(plistData[LASTIP].value.sval, value, BUFSIZE);
            break;
        case LASTIPPORT:
            strncpy(plistData[LASTIPPORT].value.sval, value, BUFSIZE);
            break;
        default:
            //log_event(CPERROR, "Program error: option not treated: %s = %s\n", key, value);
            return 0;
    }
    }
    else
    {
        //Set User Setting
    switch(option) {
        case PASSWORD:
        case MAILPASSWORD:
        case USERPASSWORD:
        case USERNAME:
        case ACCESSTOKEN:
        case REFRESHTOKEN:
        case CLIENTID:
        case CODECHALLENGE:
        case TENANTID:
        case TUSERID:
            strncpy(plistData[option].value.sval, value, BUFSIZE);
            /*
            memset(plistData[option].value.pval, 0x00, BUFSIZE);
            unsigned char *p;
            int i = 0;
            for (i = 0, p = (unsigned char *)value; i < BUFSIZE; i++, p++) {
                if (!*p) {
                    break;
                }
                plistData[option].value.pval[i] = *p;
            }
             */
            log_event(CPSTATUS, "EncryptedPassword[%d]: %s ,size: %d\n", option, plistData[option].value.sval, strlen(plistData[option].value.sval));
            break;
        case PRINTERDESCRIPTION:
            strncpy(plistData[PRINTERDESCRIPTION].value.sval, value, BUFSIZE);
            break;
        case PROXYIP:
            strncpy(plistData[PROXYIP].value.sval, value, BUFSIZE);
            break;
        case PROXYPORT:
            strncpy(plistData[PROXYPORT].value.sval, value, BUFSIZE);
            break;
        case PRINTSERVERNAME:
            strncpy(plistData[PRINTSERVERNAME].value.sval, value, BUFSIZE);
            break;
        case SERVERNAME:
            strncpy(plistData[SERVERNAME].value.sval, value, BUFSIZE);
            break;
        case SERVERPORT:
            strncpy(plistData[SERVERPORT].value.sval, value, BUFSIZE);
            break;
        case UID:
            strncpy(plistData[UID].value.sval, value, BUFSIZE);
            break;
        case USEHTTPS:
            tmp=atoi(value);
            plistData[USEHTTPS].value.ival = ((tmp!=0)?1:0);
            break;
        case USEPROXY:
            tmp=atoi(value);
            plistData[USEPROXY].value.ival = ((tmp!=0)?1:0);
            break;
//        case USERNAME:
//            strncpy(plistData[USERNAME].value.sval, value, BUFSIZE);
//            break;
//        case ACCESSTOKEN:
//            strncpy(plistData[ACCESSTOKEN].value.sval, value, BUFSIZE);
//            break;
//        case REFRESHTOKEN:
//            strncpy(plistData[REFRESHTOKEN].value.sval, value, BUFSIZE);
//            break;
        case REDIRECTURI:
            strncpy(plistData[REDIRECTURI].value.sval, value, BUFSIZE);
            break;
        case MAIL:
            strncpy(plistData[MAIL].value.sval, value, BUFSIZE);
            break;
//        case CLIENTID:
//            strncpy(plistData[CLIENTID].value.sval, value, BUFSIZE);
//            break;
//        case CODECHALLENGE:
//            strncpy(plistData[CODECHALLENGE].value.sval, value, BUFSIZE);
//            break;
        case CODEVERIFIER:
            strncpy(plistData[CODEVERIFIER].value.sval, value, BUFSIZE);
            break;
//        case TENANTID:
//            strncpy(plistData[TENANTID].value.sval, value, BUFSIZE);
//            break;
//        case TUSERID:
//            strncpy(plistData[TUSERID].value.sval, value, BUFSIZE);
//            break;
        default:
            //log_event(CPERROR, "Program error: option not treated: %s = %s\n", key, value);
            return 0;
    }

    }
    return 1;
}

static void read_plist_file(char *filename, int isBE) {
    
    FILE *fp=NULL;
    struct stat fstatus;
    cp_string buffer, key, value, tmp;
    
    if ((strlen(filename) > 1) && (!stat(filename, &fstatus)) &&
        (S_ISREG(fstatus.st_mode) || S_ISLNK(fstatus.st_mode))) {
        fp=fopen(filename,"r");
    }
    if (fp==NULL) {
        log_event(CPERROR, "Cannot open plist: %s", filename);
        return;
    }
    
    bool bFindKey = false;
    while (fgets(buffer, BUFSIZE, fp) != NULL) {
        
        tmp[0]='\0';
        if (sscanf(buffer,"%*[^<]<key>%[^<]key>",tmp)) {
            if (strlen(tmp)){
                key[0]='\0';
                strcpy(key, tmp);
                bFindKey = true;
            }
        }
        
        if (sscanf(buffer,"%*[^<]<%[^>]",tmp)) {
            
            if (strlen(tmp) && !strncmp(tmp,"string",6) && bFindKey == true){
                value[0]='\0';
                if (sscanf(buffer,"%*[^<]<string>%[^<]string>",value)) {
                    _assign_plistdata(key, value, isBE);
                    bFindKey = false; // clear flag
                }
            } else if (bFindKey == true) {  //test string以外（NSData型）
                if (
                    strlen(tmp) && !strncmp(tmp,"data",strlen("data"))
                    /*
                    !strcmp(key, plistData[PASSWORD].keyname) || !strcmp(key, plistData[MAILPASSWORD].keyname) || !strcmp(key, plistData[USERPASSWORD].keyname)
                     || !strcmp(key, plistData[USERNAME].keyname) || !strcmp(key, plistData[TENANTID].keyname) || !strcmp(key, plistData[TUSERID].keyname) || !strcmp(key, plistData[CLIENTID].keyname) || !strcmp(key, plistData[CODECHALLENGE].keyname) || !strcmp(key, plistData[ACCESSTOKEN].keyname) || !strcmp(key, plistData[REFRESHTOKEN].keyname)
                    */
                    )
                {  //encoded password
                    int size = 0;
                    log_event(CPSTATUS, "PASSDWORDATA:%s, %s¥n", filename, key);
                    
                    unsigned char *p = getmypass(filename, key, &size);
                    //_assign_plistdata2(key, p, size);
                    char *sid = GetSerialNumber();
                    char *uid = GetUserID();
                    
                    char *pw = decrypt(p, sid, uid, size);
                    log_event(CPSTATUS, "keystr:%s, ivstr:%s, size:%d", sid, uid, size);
                    log_event(CPSTATUS, "PASSWORDDATA[%s]:decode:%s", key, pw);
                    _assign_plistdata(key, pw, isBE);
                    free(p);
                    bFindKey = false; // clear flag
                }
                
            }
        }
    }
    
    if (!isBE) {    //以下、/var/spool/print2server/SPOOL配下のプロパティリストは参照しないので処理をスキップ
    //Update Config (ServerIP)
    if (strlen(plistData[PRINTSERVERNAME].value.sval))
    {
        cp_string SerIP;
        snprintf(SerIP, BUFSIZE, "%s:%s"
                 , plistData[PRINTSERVERNAME].value.sval,  plistData[SERVERPORT].value.sval);
        strncpy(Conf_ServerAddr, SerIP, BUFSIZE);
    }
    
    
    //Update Config (proxy)
    if(plistData[USEPROXY].value.ival){
      
        if (strlen(plistData[USERNAME].value.sval))
        {
            cp_string ProxyIP;
            snprintf(ProxyIP, BUFSIZE, "%s:%s"
                     , plistData[PROXYIP].value.sval, plistData[PROXYPORT].value.sval);
            strncpy(Conf_ProxyAddr, ProxyIP, BUFSIZE);
        }
        
        if (strlen(plistData[USERNAME].value.sval))
        {
            cp_string ProxUserPW;
  /*
            cp_string decrypt_pass;
            char *sid = GetSerialNumber();
            char *uid = GetUserID();
            int size = 0;
            char *p = decrypt_pass;
            
            for (; size<sizeof(pwd_string); size++) {       //???
                if (!plistData[PASSWORD].value.pval[size])
                    break;
            }
            
            strncpy(p, decrypt(plistData[PASSWORD].value.pval, sid, uid, size), size);
            log_event(CPSTATUS, "PROXY_PASSWORD:decrypt:%s, sid:%s, ivstr:%s, size:%d", p, sid, uid, size);
            
            //            snprintf(ProxUserPW, BUFSIZE, "%s:%s"
            //                    , plistData[USERNAME].value.sval, plistData[PASSWORD].value.pval);
            snprintf(ProxUserPW, BUFSIZE, "%s:%s"
                     , plistData[USERNAME].value.sval, p);
  */
            snprintf(ProxUserPW, BUFSIZE, "%s:%s"
                                , plistData[USERNAME].value.sval, plistData[PASSWORD].value.sval);
            strncpy(Conf_ProxyUserPWD, ProxUserPW, BUFSIZE);
            log_event(CPSTATUS, "Conf_ProxyUserPWD:%s", Conf_ProxyUserPWD);
        }
        
        // cloud addr mode
        if (strlen(plistData[USEHTTPS].value.sval)){
            strcpy(Conf_AddrMode, "https");
        }
        else{
            strcpy(Conf_AddrMode, "http");
        }
        
    }
    }
    
    
    (void) fclose(fp);
    return;
}

static void read_config_options(const char *lpoptions) {
    int i;
    int num_options;
    cups_option_t *options;
    cups_option_t *option;
    
    num_options = cupsParseOptions(lpoptions, 0, &options);
    
    for (i = 0, option = options; i < num_options; i ++, option ++) {
        
        /* replace all _ by " " in value */
        int j;
        for (j=0; option->value[j]!= '\0'; j++) {
            if (option->value[j] == '_') {
                option->value[j] = ' ';
            }
        }
        _assign_value(SEC_LPOPT, option->name, option->value);
    }
    return;
}

static void dump_configuration() {
    if (Conf_LogType & CPDEBUG) {
        log_event(CPDEBUG, "*** Final Configuration ***");
        log_event(CPDEBUG, "ServerAddr         = \"%s\"", Conf_ServerAddr);
        log_event(CPDEBUG, "PrintServerAddr          = \"%s\"", Conf_PrintServerAddr);
        log_event(CPDEBUG, "UsePrintServer           = %d", Conf_UsePrintServer);
        log_event(CPDEBUG, "ProxyAddr          = \"%s\"", Conf_ProxyAddr);
        log_event(CPDEBUG, "ProxyUserPWD       = \"%s\"", Conf_ProxyUserPWD);
        log_event(CPDEBUG, "AddrMode           = \"%s\"", Conf_AddrMode);
        log_event(CPDEBUG, "AddrModeForLocal   = \"%s\"", Conf_AddrModeForLocal);
        log_event(CPDEBUG, "AnonUser           = \"%s\"", Conf_AnonUser);
        log_event(CPDEBUG, "AnonUser           = \"%s\"", Conf_AnonUser);
        log_event(CPDEBUG, "Grp                = \"%s\"", Conf_Grp);
        log_event(CPDEBUG, "Log                = \"%s\"", Conf_Log);
        log_event(CPDEBUG, "Spool              = \"%s\"", Conf_Spool);
        log_event(CPDEBUG, "LogType            = %d", Conf_LogType);
        log_event(CPDEBUG, "LowerCase          = %d", Conf_LowerCase);
        log_event(CPDEBUG, "*** End of Configuration ***");
    }
    return;
}

static int init(char *argv[]) {
    struct stat fstatus;
    struct group *group;
    cp_string filename;
    int grpstat;
    const char *uri=cupsBackendDeviceURI(argv);
    
    // read config file
    if ((uri != NULL) && (strncmp(uri, "print2server:/", 14) == 0) && strlen(uri) > 14) {
        uri = uri + 14;
        sprintf(filename, "%s/print2server-%s.conf", CP_CONFIG_PATH, uri);
    }
    else {
        sprintf(filename, "%s/print2server.conf", CP_CONFIG_PATH);
    }
    read_config_file(filename);
    
    // read options
    read_config_options(argv[5]);
    
    (void) umask(0077);
    
    group=getgrnam(Conf_Grp);
    grpstat=setgid(group->gr_gid);
    
    if (strlen(Conf_Log)) {
        if (stat(Conf_Log, &fstatus) || !S_ISDIR(fstatus.st_mode)) {
            if (create_dir(Conf_Log, 1))
                return 1;
            if (chmod(Conf_Log, 0700))
                return 1;
        }
        
        (void) umask(0022);
        snprintf(filename, BUFSIZE, "%s/%s%s%s", Conf_Log, "print2server-", getenv("PRINTER"), "_log");
        log_open(filename, Conf_LogType);
        //logfp=fopen(filename, "a");
        (void) umask(0077);
    }
    
    // Update Config from plist
    cp_string spListName, PATH_USER_PLIST;
    //ユーザーごとのPlistファイルのディレクトリ
    char *user;
    size_t size;
    size=strlen(argv[2])+1;
    user=calloc(size, sizeof(char));
    snprintf(user, size, "%s", argv[2]);
    
    SetUserID(user);        //test
    
    //char *loginUser = getlogin();
    strcpy(PATH_USER_PLIST, "/etc/cups/com.rits.PdfDriverInstaller_");
    strcat(PATH_USER_PLIST, user);
    strcat(PATH_USER_PLIST, ".plist");
    
    snprintf(spListName, BUFSIZE, "%s", PATH_USER_PLIST);
    read_plist_file(spListName, 0);
    
    // Update Config from Backend plist
    cp_string spListNameBE, PATH_BACKEND_PLIST;
    
    strcpy(PATH_BACKEND_PLIST, "/var/spool/print2server/SPOOL/com.rits.PdfDriverInstaller_");
    strcat(PATH_BACKEND_PLIST, user);
    strcat(PATH_BACKEND_PLIST, ".plist");
    
    snprintf(spListNameBE, BUFSIZE, "%s", PATH_BACKEND_PLIST);
    read_plist_file(spListNameBE, 1);
    
    // dump config
    dump_configuration();
    
    if (!group) {
        log_event(CPERROR, "Grp not found: %s", Conf_Grp);
        return 1;
    }
    else if (grpstat) {
        log_event(CPERROR, "failed to set new gid: %s", Conf_Grp);
        return 1;
    }
    else
        log_event(CPDEBUG, "set new gid: %s", Conf_Grp);
    
    (void) umask(0022);
    
    if (stat(Conf_Spool, &fstatus) || !S_ISDIR(fstatus.st_mode)) {
        if (create_dir(Conf_Spool, 0)) {
            log_event(CPERROR, "failed to create spool directory: %s", Conf_Spool);
            return 1;
        }
        if (chmod(Conf_Spool, 0751)) {
            log_event(CPERROR, "failed to set mode on spool directory: %s", Conf_Spool);
            return 1;
        }
        if (chown(Conf_Spool, -1, group->gr_gid))
            log_event(CPERROR, "failed to set group id %s on spool directory: %s (non fatal)", Conf_Grp, Conf_Spool);
        log_event(CPSTATUS, "spool directory created: %s", Conf_Spool);
    }
    
    (void) umask(0077);
    return 0;
}

static void announce_printers() {
    DIR *dir;
    struct dirent *config_ent;
    size_t len;
    cp_string setup;
    
    printf("file print2server:/ \"PDF Printer Server\" \"Print2Server\" \"MFG:Generic;MDL:PDF Basic;DES:Generic PDF Basic;CLS:PRINTER;CMD:POSTSCRIPT;\"\n");
    
    if ((dir = opendir(CP_CONFIG_PATH)) != NULL) {
        while ((config_ent = readdir(dir)) != NULL) {
            len = strlen(config_ent->d_name);
            if ((strncmp(config_ent->d_name, "print2server-", 13) == 0) &&
                (len > 14 && strcmp(config_ent->d_name + len - 5, ".conf") == 0)) {
                strncpy(setup, config_ent->d_name + 9, BUFSIZE>len-14 ? len-14 : BUFSIZE);
                setup[BUFSIZE>len-14 ? len-14 : BUFSIZE - 1] = '\0';
                printf("file print2server:/%s \"%s Printer Server\" \"Print2Server\" \"MFG:Generic;MDL:PDF Basic;DES:Generic CPDF Basic;CLS:PRINTER;CMD:POSTSCRIPT;\"\n", setup, setup);
            }
        }
        closedir(dir);
    }
    return;
}


static int _assign_power(char *key, char *value) {
    bool bValue;
    int option;
    
    for (option=0; option<END_OF_VERIFYOPTIONS; option++) {
        if (!strcasecmp(key, refData[option].verify_keyname))
            break;
    }
    
    if (option == END_OF_VERIFYOPTIONS) {
        return 0;
    }
    
    if(!strcasecmp(value, "true")){
        bValue = true;
    }
    else{
        bValue = false;
    }
    
    switch(option) {
        case SCAN:
            refData[SCAN].value.bval = bValue;
            break;
        case MONOCOPY:
            refData[MONOCOPY].value.bval = bValue;
            break;
        case COLORCOPY:
            refData[COLORCOPY].value.bval = bValue;
            break;
        case MONOPRINT:
            refData[MONOPRINT].value.bval = bValue;
            break;
        case COLORPRINT:
            refData[COLORPRINT].value.bval = bValue;
            break;
        case FAX:
            refData[FAX].value.bval = bValue;
            break;
        case PRINTBWDUPLEX:
            refData[PRINTBWDUPLEX].value.bval = bValue;
            break;
        case SEAL:
            refData[SEAL].value.bval = bValue;
            break;
        case WATERIMG:
            refData[WATERIMG].value.bval = bValue;
            break;
        case WATERFONT:
            refData[WATERFONT].value.bval = bValue;
            break;
        case WATERQRCODE:
            refData[WATERQRCODE].value.bval = bValue;
            break;
        case BACKUPPRINT:
            refData[BACKUPPRINT].value.bval = bValue;
            break;
        case BACKUPCOPY:
            refData[BACKUPCOPY].value.bval = bValue;
            break;
        case BACKUPSCAN:
            refData[BACKUPSCAN].value.bval = bValue;
            break;
        case KEYWORDSYSTEM:
            refData[KEYWORDSYSTEM].value.bval = bValue;
            break;
        case KEYWORDREVIEW:
            refData[KEYWORDREVIEW].value.bval = bValue;
            break;
        case KEYWORDALARM:
            refData[KEYWORDALARM].value.bval = bValue;
            break;
        default:
            log_event(CPERROR, "Program error: option not treated: %s = %s\n", key, value);
            return 0;
    }
    return 1;
}

bool _getRefData(const char* buffer, char* key, char* refData)
{
    bool ref = false;
    cp_string value;
    cp_string strkey;
    memset(value, 0, BUFSIZE);
    memset(strkey, 0, BUFSIZE);
    
    snprintf(strkey, BUFSIZE, "%s:%s", key, "%[^/}|^,]");  //url
    
//   if (sscanf(buffer,"@PJL SET %[^=]=%[][{^\"|^\n}]",key,value)) {
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


bool getAllRefData(char *outdata)
{
    bool ref = true;
    char refdata[BUFSIZE];
    
    // ColorPrint
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"ColorPrint\"", refdata);
    _assign_power("ColorPrint", refdata);
    
    // MonoPrint
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"MonoPrint\"", refdata);
    _assign_power("MonoPrint", refdata);

    // MonoCopy
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"MonoCopy\"", refdata);
    _assign_power("MonoCopy", refdata);

    // ColorCopy
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"ColorCopy\"", refdata);
    _assign_power("ColorCopy", refdata);
    
    // Scan
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"Scan\"", refdata);
    _assign_power("Scan", refdata);
    
    // Fax
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"Fax\"", refdata);
    _assign_power("Fax", refdata);
    
    // PrintBWDuplex
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"PrintBW_Duplex\"", refdata);
    _assign_power("PrintBWDuplex", refdata);
    
    // Seal
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"Seal\"", refdata);
    _assign_power("Seal", refdata);
    
    // WaterImg
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"WaterImg\"", refdata);
    _assign_power("WaterImg", refdata);
    
    // WaterFont
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"WaterFont\"", refdata);
    _assign_power("WaterFont", refdata);
    // WaterQRCode
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"WaterQRCode\"", refdata);
    _assign_power("WaterQRCode", refdata);
    
    // BackUpPrint
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"BackUpPrint\"", refdata);
    _assign_power("BackUpPrint", refdata);
    
    // BackUpCopy
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"BackUpCopy\"", refdata);
    _assign_power("BackUpCopy", refdata);
    
    // BackUpScan
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"BackUpScan\"", refdata);
    _assign_power("BackUpScan", refdata);
    
    // KeyWordSystem
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"KeyWordSystem\"", refdata);
    _assign_power("KeyWordSystem", refdata);
    
    // KeyWordReview
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"KeyWordReview\"", refdata);
    _assign_power("KeyWordReview", refdata);
    
    // KeyWordAlarm
    memset(refdata, 0, BUFSIZE);
    _getRefData(outdata, "\"KeyWordAlarm\"", refdata);
    _assign_power("KeyWordAlarm", refdata);
    
    return ref;
}


static int _assign_pjl(char *key, char *value) {
    int tmp;
    int option;
    
    for (option=0; option<END_OF_PJLOPTIONS; option++) {
        if (!strcasecmp(key, pjlData[option].pjl_keyname))
            break;
    }
    
    if (option == END_OF_PJLOPTIONS) {
        return 0;
    }
    
    switch(option) {
        case JOBNAME:
            strncpy(pjlData[JOBNAME].value.sval, value, BUFSIZE);
            break;
        case USERID:
            strncpy(pjlData[USERID].value.sval, value, BUFSIZE);
            break;
        case FITTOPAGESIZE:
            strncpy(pjlData[FITTOPAGESIZE].value.sval, value, BUFSIZE);
            break;
        case RENDERMODE:
            strncpy(pjlData[RENDERMODE].value.sval, value, BUFSIZE);
            break;
        case QTYCOPIES:
            strncpy(pjlData[QTYCOPIES].value.sval, value, BUFSIZE);
            break;
        case DUPLEX:
            strncpy(pjlData[DUPLEX].value.sval, value, BUFSIZE);
            break;
        case BINDING:
            strncpy(pjlData[BINDING].value.sval, value, BUFSIZE);
            break;
        default:
            log_event(CPERROR, "Program error: option not treated: %s = %s\n", key, value);
            return 0;
    }
    return 1;
}

void getAllpjlData(cp_string buffer)
{
    bool bFindJobName = true;
    bool bFindUserID = true;
    bool bFindRenderMode = true;
    bool bFindDUPLEX = true;
    bool bFindBinding = true;
    bool bFindPaperSize = true;
    bool bFindQTYCopies = true;

    cp_string value;
    char* npos = NULL;
    
    // Get RenderMode
    if(bFindRenderMode)
    {
        npos = strstr(buffer,"RENDERMODE=");
        if(npos != NULL)
        {
            // get pjl
            memset(value, 0, BUFSIZE);
            if (sscanf(npos,"RENDERMODE=%[^\n]",value))
            {
                //if (!strlen(value))
                    //continue;
                _assign_pjl("RENDERMODE", value);
            }
        }
    }
    
    
    
    // Get Duplex
    if(bFindDUPLEX)
    {
        npos = strstr(buffer,"DUPLEX=");
        if(npos != NULL)
        {
            // get pjl
            memset(value, 0, BUFSIZE);
            if (sscanf(npos,"DUPLEX=%[^\n]",value))
            {
                //if (!strlen(value))
                    //continue;
                _assign_pjl("DUPLEX", value);
            }
        }
    }
    
    // Get Binding
    if(bFindBinding)
    {
        npos = strstr(buffer,"BINDING=");
        if(npos != NULL)
        {
            // get pjl
            memset(value, 0, BUFSIZE);
            if (sscanf(npos,"BINDING=%[^\n]",value))
            {
                //if (!strlen(value))
                    //continue;
                _assign_pjl("BINDING", value);
            }
        }
        
    }
    // Get job name
    if(bFindJobName)
    {
        npos = strstr(buffer,"NAME=");
        if(npos != NULL)
        {
            // get pjl
            memset(value, 0, BUFSIZE);
            if (sscanf(npos,"NAME=\"%4095[^\"]",value))
            {
                //if (!strlen(value))
                    //continue;
                _assign_pjl("JOBNAME", value);
            }
        }
    }
    
    
    // Get User ID
    if(bFindUserID)
    {
        npos = strstr(buffer,"USERID=");
        if(npos != NULL)
        {
            // get pjl
            memset(value, 0, BUFSIZE);
            if (sscanf(npos,"USERID=\"%[^\"]",value))
            {
                //if (!strlen(value))
                    //continue;
                _assign_pjl("USERID", value);
            }
        }
    }
    
    
    // Get PaperSize
    if(bFindPaperSize)
    {
        npos = strstr(buffer,"FITTOPAGESIZE=");
        if(npos != NULL)
        {
            // get pjl
            memset(value, 0, BUFSIZE);
            if (sscanf(npos,"FITTOPAGESIZE=%[^\n]", value))
            {
                //if (!strlen(value))
                    //continue;
                _assign_pjl("FITTOPAGESIZE", value);
            }
        }
    }
    
    
    // Get QTY or Copies
    if(bFindQTYCopies)
    {
        npos = strstr(buffer,"QTY=");
        if(npos != NULL)
        {
            // get pjl
            memset(value, 0, BUFSIZE);
            if (sscanf(npos,"QTY=%[^\n]", value))
            {
                //if (!strlen(value))
                    //continue;
                _assign_pjl("QTYCOPIES", value);
            }
        }
        else
        {
            npos = strstr(buffer,"COPIES=");
            if(npos != NULL)
            {
                // get pjl
                memset(value, 0, BUFSIZE);
                if (sscanf(npos,"COPIES=%[^\n]", value))
                {
                    //if (!strlen(value))
                        //continue;
                    _assign_pjl("QTYCOPIES", value);
                }
            }//End of "if(npos != NULL)"
        }//End of "else"
    }//End of "if(bFindQTYCopies)"
    

}

static unsigned long preparespoolfile(int fpsrc, char *spoolfile, char *title, char *cmdtitle,
                                      int job, struct passwd *passwd, bool isPrintBwDuplex) {
    cp_string buffer, key, value;
    FILE *fpdest;
    int	 status = CUPS_BACKEND_OK;
    fd_set	input_set;		/* Input set for select() */
    ssize_t		print_bytes;	/* Print bytes read */
    struct timeval *timeout,		/* Timeout pointer */
    tv;			/* Time value */
    int		nfds;			/* Number of file descriptors */
    unsigned long	total_bytes;		/* Total bytes written */
    struct sigaction action;		/* Actions for POSIX signals */
    
    /*
     * If we are printing data from a print driver on stdin, ignore SIGTERM
     * so that the driver can finish out any page data, e.g. to eject the
     * current page.  We only do this for stdin printing as otherwise there
     * is no way to cancel a raw print job...
     */
    if (!fpsrc)
    {
        memset(&action, 0, sizeof(action));
        
        sigemptyset(&action.sa_mask);
        action.sa_handler = SIG_IGN;
        sigaction(SIGTERM, &action, NULL);
    }
    
    if (fpsrc != STDIN_FILENO)
    {
        fputs("PAGE: 1 1\n", stderr);
        lseek(fpsrc, 0, SEEK_SET);
    }
    
    log_event(CPDEBUG, "source stream ready");
    fpdest=fopen(spoolfile, "wb");
    if (fpdest == NULL) {
        log_event(CPERROR, "failed to open spoolfile: %s", spoolfile);
        return 0;
    }
    log_event(CPDEBUG, "destination stream ready: %s", spoolfile);
    if (chown(spoolfile, passwd->pw_uid, -1)) {
        (void) fclose(fpdest);
        log_event(CPERROR, "failed to set owner for spoolfile: %s", spoolfile);
        return 0;
    }
    log_event(CPDEBUG, "owner set for spoolfile: %s", spoolfile);
    
    bool bFindJobName = true;
    bool bFindUserID = true;
    bool bFindRenderMode = true;
    bool bFindDUPLEX = true;
    bool bFindBinding = true;
    bool bFindPaperSize = true;
    bool bFindQTYCopies = true;
    size_t nCurPutsSize = 0;
    total_bytes = 0;
    print_bytes = 0;	/* Print bytes read */
    char* npos = NULL;
    
    while (status == CUPS_BACKEND_OK)
    {
        FD_ZERO(&input_set);
        
        if (!print_bytes)
            FD_SET(fpsrc, &input_set);
        
        /*
         * Calculate select timeout...
         *   If we have data waiting to send timeout is 100ms.
         *   else if we're draining print_fd timeout is 0.
         *   else we're waiting forever...
         */
        if (print_bytes)
        {
            tv.tv_sec  = 0;
            tv.tv_usec = 100000;		/* 100ms */
            timeout    = &tv;
        }
        else
        {
            timeout = NULL;
        }
        
        // I/O is unlocked around select...
        nfds = select(fpsrc + 1, &input_set, NULL, NULL, timeout);
        if (nfds < 0)
        {
            if (errno == EINTR && total_bytes == 0)
            {
                log_event(CPDEBUG, "Received an interrupt before any bytes were written, aborting");
                (void) fclose(fpdest);
                return (CUPS_BACKEND_OK);
            }
            else if (errno != EAGAIN && errno != EINTR)
            {
                log_event(CPERROR, "Unable to read print data.(select)");
                (void) fclose(fpdest);
                //return (CUPS_BACKEND_FAILED);
                return (CUPS_BACKEND_CANCEL);
            }
        }
        
        //Check if we have print data ready...
        if (FD_ISSET(fpsrc, &input_set))
        {
            print_bytes = read(fpsrc, buffer, BUFSIZE);
            
            if (print_bytes < 0)
            {
                // Read error - bail if we don't see EAGAIN or EINTR...
                if (errno != EAGAIN && errno != EINTR)
                {
                    log_event(CPERROR, "Unable to read print data.(read)");
                    (void) fclose(fpdest);
                    //return (CUPS_BACKEND_FAILED);
                    return (CUPS_BACKEND_CANCEL);
                }
                print_bytes = 0;
            }
            else if (print_bytes == 0)
            {
                // End of file, break out of the loop...
                break;
            }
            
            log_event(CPDEBUG, "Read %d bytes of print data...",(int)print_bytes);
        }
        
        if (print_bytes)
        {
            
            if(total_bytes < BUFSIZE && bFindDUPLEX){
                //PJL commands only exist in the first block of buffer
                //find DUPLEX (and other PJL command values)
                
                if(true == isPrintBwDuplex)
                {
                    //"PirntBW_Duplex" is true
                    
                    char* nposDuplex = NULL;
                    char* nposBinding = NULL;
                    //char* nposCollate = NULL;
                    char* nposRenderMode = NULL;
                    //char* nposMediaType = NULL;
                    
                    cp_string buffer1;  //contents before "@PJL SET DUPLEX"
                    cp_string buffer2;  //contents of "DUPLEX"
                    cp_string buffer3;  //contents after "DUPLEX" and before "RENDERMODE"
                    cp_string buffer4;  //contents of "RENDERMODE" and "DATAMODE"
                    cp_string buffer5;  //contents after "DATAMODE"
                    
                    //cp_string valueDuplex;
                    //cp_string valueBinding;
                    //cp_string valueRenderMode;
                    
                    
                    //Get All pjl Data
                    getAllpjlData(buffer);
     
                    
                    //if( 0 == strcmp("OFF", pjlData[]) || 0 == strcmp("COLOR", valueRenderMode) )
                    if( 0 == strcasecmp(pjlData[DUPLEX].value.sval, "OFF") ||  0 == strcasecmp(pjlData[RENDERMODE].value.sval, "COLOR"))
                    {
                        //current PJL is not "BW & Duplex LongEdge"
                        memset(buffer1, 0, BUFSIZE);
                        memset(buffer2, 0, BUFSIZE);
                        memset(buffer3, 0, BUFSIZE);
                        memset(buffer4, 0, BUFSIZE);
                        memset(buffer5, 0, BUFSIZE);
                        
                        char *strDuplexAndBindingFormat = "ON\n@PJL SET BINDING=%s\n";
                        char strDuplexAndBinding[64] = {0};
                        
                        char *strRenderModeAndDataMode = "GRAYSCALE\n@PJL SET DATAMODE=GRAYSCALE\n";
                        
                        char *nposDuplexBindingEnd = NULL;
                        nposDuplex = strstr(buffer,"DUPLEX=");
                        nposBinding = strstr(buffer,"BINDING=");
                        if(0 == strcasecmp(pjlData[DUPLEX].value.sval, "OFF"))
                        {
                            nposDuplexBindingEnd = nposDuplex + 7 + 4;  //DUPLEX=OFF\n
                            _assign_pjl("DUPLEX", "ON");
                            _assign_pjl("BINDING", "LONGEDGE");
                        }else if(0 == strcasecmp(pjlData[BINDING].value.sval, "SHORTEDGE"))
                        {
                            nposDuplexBindingEnd = nposBinding + 8 + 10; //BINDING=SHORTEDGE\n
                        }else
                        {
                            nposDuplexBindingEnd = nposBinding + 8 + 9; //BINDING=LONGEDGE\n
                        }
                        
                        sprintf(strDuplexAndBinding, strDuplexAndBindingFormat, pjlData[BINDING].value.sval);
                        
                        char *nposRenderModeDataModeEnd = NULL;
                        nposRenderMode = strstr(buffer,"RENDERMODE=");
                        if(0 == strcasecmp(pjlData[RENDERMODE].value.sval, "COLOR"))
                        {
                            nposRenderModeDataModeEnd = nposRenderMode + 11 + 30;  //DATAMODE=COLOR\n
                            _assign_pjl("RENDERMODE", "GRAYSCALE");
                        }else{
                            nposRenderModeDataModeEnd = nposRenderMode + 11 + 38; //DATAMODE=GRAYSCALE\n
                        }
                        
                        
                        
                        ssize_t print_bytes1 = nposDuplex - buffer + 7; //...DUPLEX=
                        ssize_t print_bytes2 = strlen(strDuplexAndBinding); //ON...LONGEDGE\n
                        ssize_t print_bytes3 = nposRenderMode - nposDuplexBindingEnd + 11;  //@PJL SET COLLATE...RENDERMODE=
                        ssize_t print_bytes4 = strlen(strRenderModeAndDataMode);   //COLOR...DATAMODE=COLOR\n
                        ssize_t print_bytes5 = print_bytes - (nposRenderModeDataModeEnd - buffer);  //@PJL SET MEDIATYPE...
                        
                        memcpy(buffer1, buffer, print_bytes1);
                        memcpy(buffer2, strDuplexAndBinding, print_bytes2);
                        memcpy(buffer3, nposDuplexBindingEnd, print_bytes3);
                        memcpy(buffer4, strRenderModeAndDataMode, print_bytes4);
                        memcpy(buffer5, nposRenderModeDataModeEnd, print_bytes5);
                        
                        
                        
                        nCurPutsSize = fwrite(buffer1, 1, print_bytes1, fpdest);
                        if(nCurPutsSize != print_bytes1){
                            status = CUPS_BACKEND_FAILED;
                            log_event(CPERROR, "Error writing to the file. size in:%d, out:%d, total:%d", print_bytes1, nCurPutsSize, total_bytes);
                            
                            total_bytes = 0;
                        }
                        else{
                            print_bytes -= nCurPutsSize;
                            total_bytes += nCurPutsSize;
                        }
                        
                        nCurPutsSize = fwrite(buffer2, 1, print_bytes2, fpdest);
                        if(nCurPutsSize != print_bytes2){
                            status = CUPS_BACKEND_FAILED;
                            log_event(CPERROR, "Error writing to the file. size in:%d, out:%d, total:%d", print_bytes2, nCurPutsSize, total_bytes);
                            
                            total_bytes = 0;
                        }
                        else{
                            print_bytes -= nCurPutsSize;
                            total_bytes += nCurPutsSize;
                        }
                        
                        nCurPutsSize = fwrite(buffer3, 1, print_bytes3, fpdest);
                        if(nCurPutsSize != print_bytes3){
                            status = CUPS_BACKEND_FAILED;
                            log_event(CPERROR, "Error writing to the file. size in:%d, out:%d, total:%d", print_bytes3, nCurPutsSize, total_bytes);
                            
                            total_bytes = 0;
                        }
                        else{
                            print_bytes -= nCurPutsSize;
                            total_bytes += nCurPutsSize;
                        }
                        
                        nCurPutsSize = fwrite(buffer4, 1, print_bytes4, fpdest);
                        if(nCurPutsSize != print_bytes4){
                            status = CUPS_BACKEND_FAILED;
                            log_event(CPERROR, "Error writing to the file. size in:%d, out:%d, total:%d", print_bytes4, nCurPutsSize, total_bytes);
                            
                            total_bytes = 0;
                        }
                        else{
                            print_bytes -= nCurPutsSize;
                            total_bytes += nCurPutsSize;
                        }
                        
                        nCurPutsSize = fwrite(buffer5, 1, print_bytes5, fpdest);
                        if(nCurPutsSize != print_bytes5){
                            status = CUPS_BACKEND_FAILED;
                            log_event(CPERROR, "Error writing to the file. size in:%d, out:%d, total:%d", print_bytes5, nCurPutsSize, total_bytes);
                            
                            total_bytes = 0;
                        }
                        else{
                            print_bytes -= nCurPutsSize;
                            total_bytes += nCurPutsSize;
                        }
                        
                        
                        if(print_bytes < 0){
                            print_bytes = 0;
                        }

                        
                        
                        
                    }
                    else
                    { //if( 0 == strcmp("OFF", valueDuplex) || 0 == strcmp("COLOR", valueRenderMode) )
                    
                        //Get All pjl Data
                        //getAllpjlData(buffer);
                        
                        nCurPutsSize = fwrite(buffer, 1, print_bytes, fpdest);
                        if(nCurPutsSize != print_bytes)
                        {
                            status = CUPS_BACKEND_FAILED;
                            log_event(CPERROR, "Error writing to the file. size in:%d, out:%d, total:%d", print_bytes, nCurPutsSize, total_bytes);
                            
                            total_bytes = 0;
                        }
                        else{
                            print_bytes -= nCurPutsSize;
                            total_bytes += nCurPutsSize;
                        }

                    
                    }
                                    
                    

                }
                else
                {  //true != isPrintBwDuplex
                
                    //Get All pjl Data
                    getAllpjlData(buffer);
                
                // Get PJL Info
                //if(total_bytes < BUFSIZE * 10){
                    
                    
                    nCurPutsSize = fwrite(buffer, 1, print_bytes, fpdest);
                    if(nCurPutsSize != print_bytes)
                    {
                        status = CUPS_BACKEND_FAILED;
                        log_event(CPERROR, "Error writing to the file. size in:%d, out:%d, total:%d", print_bytes, nCurPutsSize, total_bytes);
                        
                        total_bytes = 0;
                    }
                    else
                    {
                        print_bytes -= nCurPutsSize;
                        total_bytes += nCurPutsSize;
                    }

 

                //}
                }
                
            }
            else
            {   //total_bytes < BUFSIZE && bFindDUPLEX
                nCurPutsSize = fwrite(buffer, 1, print_bytes, fpdest);
                if(nCurPutsSize != print_bytes)
                {
                    status = CUPS_BACKEND_FAILED;
                    log_event(CPERROR, "Error writing to the file. size in:%d, out:%d, total:%d", print_bytes, nCurPutsSize, total_bytes);
                    
                    total_bytes = 0;
                }
                else
                {
                    print_bytes -= nCurPutsSize;
                    total_bytes += nCurPutsSize;
                }
            }   //total_bytes < BUFSIZE && bFindDUPLEX
            
            
            
   
        }   //print_bytes
    }   //while (status == CUPS_BACKEND_OK)
    
    (void) fclose(fpdest);
    if(fpsrc != 0)
        (void) close(fpsrc);
    log_event(CPDEBUG, "all data written to spoolfile: %s", spoolfile);
    
    return total_bytes;
}


static void saveLastJobId(char* job_id)
{
    char *lastJobIdFile;    //the file which save last job id in it
    
    size_t size=strlen(Conf_Spool)+32;
    lastJobIdFile=calloc(size, sizeof(char));
    if (lastJobIdFile == NULL) {
        (void) fputs("print2server: failed to allocate memory\n", stderr);
        log_event(CPDEBUG, "lastJobIdFile name created failed");
        log_close();
        free(lastJobIdFile);
        return;
    }
    
    snprintf(lastJobIdFile, size, "%s/%s", Conf_Spool, "lastJobId");
    log_event(CPDEBUG, "lastJobIdFile name created: %s", lastJobIdFile);
    
    FILE *fpdest=fopen(lastJobIdFile, "wb");
    if (fpdest == NULL) {
        log_event(CPERROR, "failed to open lastJobIdFile: %s", lastJobIdFile);
        free(lastJobIdFile);
        return;
    }

    size_t nCurPutsSize = fwrite(job_id, 1, strlen(job_id), fpdest);
    if(nCurPutsSize == 0){
        log_event(CPERROR, "failed to write lastJobIdFile: %s", lastJobIdFile);
        free(lastJobIdFile);
        return;
    }else{
        log_event(CPDEBUG, "wrote lastJobIdFile job id: %s", job_id);
    }
    free(lastJobIdFile);
}



static void readLastJobId(char* job_id)
{
    char *lastJobIdFile;    //the file which save last job id in it
    
    size_t size=strlen(Conf_Spool)+32;
    lastJobIdFile=calloc(size, sizeof(char));
    if (lastJobIdFile == NULL) {
        (void) fputs("print2server: failed to allocate memory\n", stderr);
        log_event(CPDEBUG, "lastJobIdFile name created failed");
        log_close();
        free(lastJobIdFile);
        return;
    }
    
    snprintf(lastJobIdFile, size, "%s/%s", Conf_Spool, "lastJobId");
    log_event(CPDEBUG, "lastJobIdFile name created: %s", lastJobIdFile);
    
    FILE *fp=fopen(lastJobIdFile, "rb");
    if (fp == NULL) {
        log_event(CPERROR, "failed to open lastJobIdFile: %s", lastJobIdFile);
        free(lastJobIdFile);
        return;
    }
    
    char id[32] = {0};
    size_t bytes = fread(id, sizeof(char), 32, fp);
    if(bytes == 0){
        log_event(CPERROR, "failed to read lastJobIdFile: %s", lastJobIdFile);
        free(lastJobIdFile);
        return;
    }else{
        log_event(CPDEBUG, "read lastJobIdFile job id: %s", id);
        strcpy(job_id, id);
    }
    free(lastJobIdFile);
}




static void readSpoolFileTail(char* tail)
{
    size_t size=strlen(Conf_Spool)+22+4;
    char *spoolfile=calloc(size, sizeof(char));
    if (spoolfile == NULL) {
        (void) fputs("print2server: failed to allocate memory\n", stderr);
        log_close();
        fputs(MSGOUT_CONTECT_TO_DEVICE, stderr);
        free(spoolfile);
        //return (CUPS_BACKEND_FAILED);
        return (CUPS_BACKEND_CANCEL);
    }
    
    cp_string sFileName;
    snprintf(sFileName, BUFSIZE, "print2server-%i", (int) getpid());
    snprintf(spoolfile, size, "%s/%s.prn", Conf_Spool, sFileName);
    //snprintf(spoolfile, size, "%s/%s.pdf", Conf_Spool, sFileName);
    log_event(CPDEBUG, "spoolfile name created: %s", spoolfile);
    unsigned long fSize = 0;
    
    FILE *fp=fopen(spoolfile, "rb");
    if (fp == NULL) {
        log_event(CPERROR, "failed to open spoolfile: %s", spoolfile);
        free(spoolfile);
        return;
    }
    
    fseek(fp, -17L, SEEK_END);  //read last 17 characters of the spool file
    char buf[32] = {0};
    size_t bytes = fread(buf, sizeof(char), 32, fp);
    if(bytes == 0){
        log_event(CPERROR, "failed to read spoolfile: %s", spoolfile);
        free(spoolfile);
        return;
    }else{
        log_event(CPDEBUG, "read spoolfile tail: [%s]", buf);
        strcpy(tail, buf);
    }
 
    free(spoolfile);
}




/**
 SIGTERM シグナルのハンドラー
 @param[in] Signal  シグナル
 */
void SignalTermHandler(int Signal)
{
    //printf("Handle signal");
    log_event(CPSTATUS, "---Handle signal: %d", Signal);
    switch (Signal) {
        case SIGTERM:
            if(!job_canceled)
                job_canceled = 1;
            //exit(1);
            break;
        default:
            break;
    }
}



/**
 get local ip address for interface
 
 @param interfaceName (in) interface name
 @param localIpAddress     (out) the ip address of the interface
 @return 0
 */
int getIpAddressForInterface(char *interfaceName, char *localIpAddress) {
    int n;
    struct ifreq ifr;
    char *array = interfaceName;
    
    n = socket(AF_INET, SOCK_DGRAM, 0);
    
    //Type of address to retrieve - IPv4 IP address
    ifr.ifr_addr.sa_family = AF_INET;
    //Copy the interface name in the ifreq structure
    strncpy(ifr.ifr_name , array , IFNAMSIZ - 1);
    ioctl(n, SIOCGIFADDR, &ifr);
    close(n);
    
    //localIpAddress = inet_ntoa(( (struct sockaddr_in *)&ifr.ifr_addr )->sin_addr);
    strcpy(localIpAddress, inet_ntoa(( (struct sockaddr_in *)&ifr.ifr_addr )->sin_addr));
    
    return 0;
}

static bool checkServerConnnect(char *ip, char *port, char *usercode, char *argv[], FILE *fStderr){

    // Check Connect for Cloud
    cp_string testurl;
    char addrMode[6] = {0};
    strncpy(addrMode, "https", 5);
    /*
    if(0 == strncmp("443", port, 5)){
        strncpy(addrMode, "https", 5);
    }else{
        strncpy(addrMode, "http", 5);
    }
    */
    snprintf(testurl, BUFSIZE, "%s://%s/frcxprint/service_info",
             addrMode, ip);  // url

    log_event(CPSTATUS, "AccessToken: %s.", Plist_AccessToken);
    bool bCheckConnect = check_connect(testurl, Conf_ProxyAddr, Conf_ProxyUserPWD, Plist_AccessToken);
    if(!bCheckConnect){
        // Server addr is not connected!
        log_event(CPERROR, "failed to connect print server with ip: %s, port: %s.", ip , port);
    }else{
        char *access_token;
        access_token = Plist_AccessToken;

        cp_string access_token_path;
        char *user;
        size_t size;
        size=strlen(argv[2])+1;
        user=calloc(size, sizeof(char));
        snprintf(user, size, "%s", argv[2]);
        //char *loginUser = getlogin();
        strcpy(access_token_path, "/var/log/cups/access_token_eu_user_");
        strcat(access_token_path, user);
        strcat(access_token_path, ".txt");
        
        FILE *fp = NULL;
        fp = fopen(access_token_path, "w+");
        fprintf(fp, "%s", access_token);
        fclose(fp);
    }
    
    return bCheckConnect;
    //return false;
}



static void savePlistItem(char *itemName, char *value, char *argv[], FILE *fStderr)
{
    FILE *fp;
    char line_buf[512], buf1[512];
    char buf_head[1024] = {0};    //...<key>LocalIP</key>           (content before LocalIP value)
    char buf_tail[1024] = {0};    //<key>XXX</key>...               (content after LocalIP value)
    int line_len, len=0;
    int buf_head_end = 0;         //buf_head end
    int buf_tail_start = 0;       //buf_tail start
    
    //ユーザーごとのPlistファイルのディレクトリ
    cp_string PATH_USER_PLIST, PATH_BACKEND_PLIST;
    
    char *user;
    size_t size;
    size=strlen(argv[2])+1;
    user=calloc(size, sizeof(char));
    snprintf(user, size, "%s", argv[2]);
    //char *loginUser = getlogin();
    strcpy(PATH_USER_PLIST, "/etc/cups/com.rits.PdfDriverInstaller_");
    strcat(PATH_USER_PLIST, user);
    strcat(PATH_USER_PLIST, ".plist");
    
    strcpy(PATH_BACKEND_PLIST, "/var/spool/print2server/SPOOL/com.rits.PdfDriverInstaller_");
    strcat(PATH_BACKEND_PLIST, user);
    strcat(PATH_BACKEND_PLIST, ".plist");
    
    log_event(CPERROR, "savePlistItem(key = %s, string = %s)", itemName, value);
    if((fp = fopen(PATH_BACKEND_PLIST, "r")) == NULL)
    {
        log_event(CPERROR, "failed to open plist file: %s." , PATH_BACKEND_PLIST);
        if((fp = fopen(PATH_USER_PLIST, "r")) == NULL)
        {
            log_event(CPERROR, "failed to open plist file: %s." , PATH_USER_PLIST);
            return;
        }
    }
    
    while(fgets(line_buf, 512, fp))
    {
        line_len = (int)strlen(line_buf);
        len += line_len;
        sscanf(line_buf, "%s", buf1);
        //printf("buf1: %s\n", buf1);
        
        char searchStr[1024] = {0};
        sprintf(searchStr, "<key>%s</key>", itemName);
        
        if(!strcmp(searchStr, buf1)){
            buf_head_end = len;
            
            fgets(line_buf, 512, fp);
            line_len = (int)strlen(line_buf);
            len += line_len;
            buf_tail_start = len;
            
            
            break;
        }
    }
    
    //read head bytes to buf_head
    fseek(fp, 0L, SEEK_SET);
    size_t head_bytes = fread(buf_head, sizeof(char), buf_head_end, fp);
    
    //read tail bytes to buf_tail
    fseek(fp, buf_tail_start, SEEK_SET);
    size_t tail_bytes = fread(buf_tail, sizeof(char), sizeof(buf_tail), fp);
    
    fclose(fp);


    if((fp = fopen(PATH_BACKEND_PLIST, "w")) == NULL)
    {
        log_event(CPERROR, "failed to open plist file(w): %s." , PATH_BACKEND_PLIST);
        //fclose(fp);
        return;
    }
    log_event(CPERROR, "Success to open plist file(w): %s." , PATH_BACKEND_PLIST);
    //write head bytes from buf_head
    fseek(fp, 0L, SEEK_SET);
    fwrite(buf_head, head_bytes, sizeof(char), fp);
    
    //write value bytes
    char newValueStr[1024] = {0};
    sprintf(newValueStr, "\t<string>%s</string>\n", value);
    fprintf(fp, "%s", newValueStr);
    
    //write tail bytes from buf_tail
    fwrite(buf_tail, tail_bytes, sizeof(char), fp);
    //fflush(fp);
    
    fclose(fp);
}

bool modifySpoolFileDuplex2ON(char *spoolfile)
{
    bool bRet = false;
    char* npos = NULL;
    char *cBindingLongEdge = "\n@PJL SET BINDING=LONGEDGE";
    //char *spoolfile1 = "/var/spool/print2server/SPOOL/print2server-1096.prn";
    //cp_string value;
    cp_string buffer, bufferTail, value;
    FILE *fpdest;
    ssize_t		print_bytes;	/* Print bytes read */
    int bFindDUPLEX = 1;
    int iHeadLenth = 0;
    int iTailLenth = 0;
    char *pTail = NULL;
    char *pValue = NULL;
    long iFilelength = 0;
    char *bufferAll = NULL;
    
    fpdest=fopen(spoolfile, "r");
    if (fpdest == NULL)
    {
        return 0;
    }
    fseek(fpdest, 0, SEEK_END);
    iFilelength = ftell(fpdest);
    fclose(fpdest);
    
    fpdest=fopen(spoolfile, "r");
    if (fpdest == NULL)
    {
        return 0;
    }
    
    npos = strstr(buffer,"DUPLEX=");
    if(npos == NULL)
    {
        return 0;
    }
    // get pjl
    memset(value, 0, BUFSIZE);
    if (!sscanf(npos,"DUPLEX=%[^\n]",value))
    {
        return 0;
    }
    if (strlen(value))
        iHeadLenth = (int)strlen(value);
    pTail = npos + (7 + iHeadLenth);
    if(pTail == NULL)
    {
        return 0;
    }
    
    bufferAll = (char*)malloc(iFilelength * sizeof(char));
    
    strcpy(bufferTail, pTail);
    pValue = npos + 7;
    *pValue = 'O';
    *(pValue+1) = 'N';
    *(pValue+2) = '\0';
    strcpy(bufferAll, buffer);
    strcat(bufferAll, cBindingLongEdge);
    strcat(bufferAll, bufferTail);
    
    fclose(fpdest);
    fpdest=fopen(spoolfile, "wb");
    if (fpdest == NULL)
    {
        free(bufferAll);
        return 0;
    }
    fwrite(bufferAll, iFilelength, sizeof(char), fpdest);
    fclose(fpdest);
    free(bufferAll);

    return bRet;
}

bool modifySpoolFileColorModeGRAYSCALE(char *spoolfile)
{
    bool bRet = false;
    char* npos = NULL;
    char *cBindingLongEdge = "GRAYSCALE\n@PJL SET DATAMODE=GRAYSCALE";
    //cp_string value;
    cp_string buffer, bufferTail, value;
    FILE *fpdest;
    ssize_t		print_bytes;	/* Print bytes read */
    int bFindDUPLEX = 1;
    int iHeadLenth = 0;
    int iTailLenth = 0;
    char *pTail = NULL;
    char *pValue = NULL;
    long iFilelength = 0;
    char *bufferAll = NULL;
    char *pRenderMode = NULL;
    
    fpdest=fopen(spoolfile, "r");
    if (fpdest == NULL)
    {
        return 0;
    }
    fseek(fpdest, 0, SEEK_END);
    iFilelength = ftell(fpdest);
    fclose(fpdest);
    
    fpdest=fopen(spoolfile, "r");
    if (fpdest == NULL)
    {
        return 0;
    }
    
    npos = strstr(buffer,"DATAMODE=");
    pRenderMode = strstr(buffer,"RENDERMODE=");
    pRenderMode = pRenderMode + 11; //11 is the size of "RENDERMODE="
    if(npos == NULL)
    {
        return 0;
    }
    // get pjl
    memset(value, 0, BUFSIZE);
    if (!sscanf(npos,"DATAMODE=%[^\n]",value))
    {
        return 0;
    }
    if (strlen(value))
        iHeadLenth = (int)strlen(value);
    
    //get Tail part of file
    pTail = npos + (9 + iHeadLenth); //9 is the size of "DATAMODE="
    if(pTail == NULL)
    {
        return 0;
    }
    
    bufferAll = (char*)malloc(iFilelength * sizeof(char));
    strcpy(bufferTail, pTail);
    
    *pRenderMode = '\0';
    strcpy(bufferAll, buffer);
    strcat(bufferAll, cBindingLongEdge);
    strcat(bufferAll, bufferTail);
    
    fclose(fpdest);
    fpdest=fopen(spoolfile, "wb");
    if (fpdest == NULL)
    {
        free(bufferAll);
        return 0;
    }
    fwrite(bufferAll, iFilelength, sizeof(char), fpdest);
    fclose(fpdest);
    free(bufferAll);
    
    return bRet;
}

bool change2PrintBWDuplex(char *spoolfile)
{
    bool bRet = false;
    
    // If PJL ColorMode = Color
    if(!strcasecmp(pjlData[RENDERMODE].value.sval, "COLOR"))
    {
        modifySpoolFileColorModeGRAYSCALE(spoolfile);
    }
    
    // If PJL Duplex = Off
    if(!strcasecmp(pjlData[DUPLEX].value.sval, "OFF"))
    {
        //Chang Duplex to ON and LongEdge
        modifySpoolFileDuplex2ON(spoolfile);
        //modifySpoolFile(spoolfile, "BINDING=", "LONGEDGE");
    }

    return bRet;
}

bool showErrInforInPrintQueue(FILE *fstderr)
{
    bool bRet = false;
    int iErrCode = GetCurErrCode();
    
    switch (iErrCode) {
        case 0:
        case 200:
            break;
            
        case 800:
            fputs(MSGIN_CONTECT_OTHERS_ERROR, stderr);
            bRet = true;
            break;
        case 401:
            fputs(MSGIN_CONTECT_ACCESSKEY_ERROR, fstderr);
            bRet = true;
            break;

        case 400:
            fputs(MSGIN_CONTECT_LACKPARAMETERS_ERROR, fstderr);
            bRet = true;
            break;
			
			
        case 13013101:
            fputs(MSGIN_INVALID_CONTENT_TYPE, fstderr);
            bRet = true;
            break;
            
            
            //13013405
        case 13013405:
            fputs(MSGIN_INVALID_ORGID, fstderr);
            bRet = true;
            break;
            
            //13013406
        case 13013406:
            fputs(MSGIN_INVALID_USERID, fstderr);
            bRet = true;
            break;

            
            //13013307
        case 13013307:
            fputs(MSGIN_CONTENTS_NULL, fstderr);
            bRet = true;
            break;
            
            //13013301
        case 13013301:
            fputs(MSGIN_INVALID_DOCNAME, fstderr);
            bRet = true;
            break;
            
            //13013303
        case 13013303:
            fputs(MSGIN_INVALID_DOCTYPE, fstderr);
            bRet = true;
            break;
            
            //13013302
        case 13013302:
            fputs(MSGIN_INVALID_DOCSIZE, fstderr);
            bRet = true;
            break;
            
            //13013308
        case 13013308:
            fputs(MSGIN_INVALID_DOCSIZE0, fstderr);
            bRet = true;
            break;
            
            //13013309
        case 13013309:
            fputs(MSGIN_INVALID_DOCNAME_LENGTH, fstderr);
            bRet = true;
            break;
            
            //13013310
        case 13013310:
            fputs(MSGIN_INVALID_DOCNUM_OVER, fstderr);
            bRet = true;
            break;
            
            //13013201
        case 13013201:
            fputs(MSGIN_INVALID_COLOR, fstderr);
            bRet = true;
            break;
            
            //13013204
        case 13013204:
            fputs(MSGIN_INVALID_DUPLEX, fstderr);
            bRet = true;
            break;

            //13013205
        case 13013205:
            fputs(MSGIN_INVALID_LAYOUT, fstderr);
            bRet = true;
            break;

            //13013202
        case 13013202:
            fputs(MSGIN_INVALID_COPIES, fstderr);
            bRet = true;
            break;
            
            //13013208
        case 13013208:
            fputs(MSGIN_INVALID_PAPERSIZE, fstderr);
            bRet = true;
            break;
            
            //13013216
        case 13013216:
            fputs(MSGIN_INVALID_TXT_RENDER_ENC, fstderr);
            bRet = true;
            break;

            //13013217
        case 13013217:
            fputs(MSGIN_INVALID_USERCODE, fstderr);
            bRet = true;
            break;
            
            //13013206
        case 13013206:
            fputs(MSGIN_INVALID_ORIENTATION, fstderr);
            bRet = true;
            break;
            
            //13011001
        case 13011001:
            fputs(MSGIN_ABSENT_COOKIE, fstderr);
            bRet = true;
            break;
            
            //13011005
        case 13011005:
            fputs(MSGIN_UNAUTHORIZED, fstderr);
            bRet = true;
            break;
            
            //13011006
        case 13011006:
            fputs(MSGIN_UNAUTHORIZED_SERVICE_USER, fstderr);
            bRet = true;
            break;
            
        default:
            break;
    }
    
    return bRet;
}

 
char* getFirstPageSize()
{
    char *cPaperSize = pjlData[FITTOPAGESIZE].value.sval;
    if(0 == strcasecmp("A3", cPaperSize))
    {
        return "A3";
    }
    else if(0 == strcasecmp("A4", cPaperSize))
    {
        return "A4";
    }
    else if(0 == strcasecmp("A5", cPaperSize))
    {
        return "A5";
    }
    else if(0 == strcasecmp("JISB4", cPaperSize))
    {
        return "JISB4";
    }
    else if(0 == strcasecmp("JISB5", cPaperSize))
    {
        return "JISB5";
    }
    else
    {
        return "OTHER";
    }
}

bool upLoadFileToPrintServer(unsigned long fSize, char *spoolfile, char *argv[], FILE *fstderr)
{
    bool bRet = true;
    long response_code;
    
    // Finally, send the print file...
    cp_string url;
    snprintf(url, BUFSIZE, "https://%s/frcxprint/docs", Plist_PrintServerName);
    
    cp_string _spoolfile;
    strcpy(_spoolfile, spoolfile);      // file path
    cp_string _fileSize;
    snprintf(_fileSize, BUFSIZE, "%f", fSize / 1024.0);  // size
    cp_string _fileName;
    snprintf(_fileName, BUFSIZE, "%s.prn", pjlData[JOBNAME].value.sval);
    //snprintf(_fileName, BUFSIZE, "%s.pdf", pjlData[JOBNAME].value.sval);
    
    cp_string access_token_path;
    char *user;
    size_t size;
    size=strlen(argv[2])+1;
    user=calloc(size, sizeof(char));
    snprintf(user, size, "%s", argv[2]);
    //char *loginUser = getlogin();
    strcpy(access_token_path, "/var/log/cups/access_token_eu_user_");
    strcat(access_token_path, user);
    strcat(access_token_path, ".txt");
    
    char access_token[1000] = {0};
    FILE *fp = fopen(access_token_path, "r");
    if (NULL == fp){
        printf("fail to open access_token_eu_user.txt\n");
        exit(1);
    }
    
    while(!feof(fp))
    {
        memset(access_token, 0, sizeof(access_token));
        fgets(access_token, sizeof(access_token) - 1, fp); // 包含了换行符
        printf("%s", access_token);
    }
    fclose(fp);
    
    // post data init
    struct POST_PART_DATA post_data[] = {
        { _fileName, _spoolfile, 1},
    };
    
    if(Plist_UseProxy == 0){
        // do not use proxy
        response_code = client_post_multipart(url, post_data, sizeof(post_data) / sizeof(post_data[0]), NULL, NULL, argv, stderr, OS_Version, OS_Build);
    }
    else{
        // use proxy
        response_code = client_post_multipart(url, post_data, sizeof(post_data) / sizeof(post_data[0]), Conf_ProxyAddr, Conf_ProxyUserPWD, argv, stderr, OS_Version, OS_Build);
    }
    
    if (response_code == 413) {
        fputs(MSGIN_INVALID_DOCSIZE, fstderr);
        return false;
    }
    else if (response_code != 200 && response_code != 201)
    {
        log_event(CPERROR,"Failed to post, url = %s, file size = %s, response_code = %d, errcode = %d", url, _fileSize, response_code, GetCurErrCode());
        
        if(!showErrInforInPrintQueue(fstderr))
        {
            fputs(MSGIN_UPLOAD_FILE_ERROR, fstderr);
        }
        
        return false;
    }
    
    return bRet;
}

struct passwd* getUserAndPasswd(char *argv[], FILE *fStderr)
{
    //bool bRet = true;
    char *user;
    size_t size;
    struct passwd *passwd;
    size=strlen(argv[2])+1;
    user=calloc(size, sizeof(char));
    if (user == NULL) {
        (void) fputs("print2server: failed to allocate memory\n", fStderr);
        fputs(MSGOUT_CONTECT_TO_DEVICE, fStderr);
        //return 5;
        return NULL;
    }
    snprintf(user, size, "%s", argv[2]);
    passwd=getpwnam(user);
    if (passwd == NULL && Conf_LowerCase) {
        log_event(CPDEBUG, "unknown user: %s", user);
        for (size=0;size<(int) strlen(argv[2]);size++)
            argv[2][size]=tolower(argv[2][size]);
        log_event(CPDEBUG, "trying lower case user name: %s", argv[2]);
        size=+strlen(argv[2])+1;
        snprintf(user, size, "%s", argv[2]);
        passwd=getpwnam(user);
    }
    if (passwd == NULL) {
        if (strlen(Conf_AnonUser)) {
            passwd=getpwnam(Conf_AnonUser);
            if (passwd == NULL) {
                log_event(CPERROR, "username for anonymous access unknown: %s", Conf_AnonUser);
                free(user);
                log_close();
                fputs(MSGOUT_CONTECT_TO_DEVICE, fStderr);
                //return 5;
                return NULL;
            }
            log_event(CPDEBUG, "unknown user: %s", user);
        }
        else {
            log_event(CPSTATUS, "anonymous access denied: %s", user);
            free(user);
            log_close();
            fputs(MSGOUT_CONTECT_TO_DEVICE, fStderr);
            //return 0;
            return NULL;
        }
        //mode=(mode_t)(0666&~Conf_AnonUMask);
    }
    else {
        log_event(CPDEBUG, "user identified: %s", passwd->pw_name);
        //mode=(mode_t)(0666&~Conf_UserUMask);
    }
    free(user);
    
    return passwd;
}

bool getToken(const char *servername, char *clientId, char *refreshToken, char *argv[], FILE *fStderr)
{
    bool bRef = false;
    
    cp_string url;
    snprintf(url, BUFSIZE, "https://api.%s/v1/aut/oauth/provider/token", servername);
    
    cp_string post_data;
    memset(post_data, 0, BUFSIZE);
    snprintf(post_data, BUFSIZE," {\n \t\n        \"grant_type\": \"refresh_token\",\n        \n        \"refresh_token\": \"%s\",\n        \n        \"client_id\": \"%s\",\n        \n        \"expires_in\": \"43200\"\n}", refreshToken, clientId);
    
    char outdata[BUFSIZE] = {0};
    long response_code = client_posttoken(url, post_data, outdata, BUFSIZE, Conf_ProxyAddr, Conf_ProxyUserPWD);
    
    if (response_code != 200)
    {
        // network error
        log_event(CPDEBUG,"failed to check_connect, url = %s, response code = %d", url, response_code);
        bRef = false;
    }
    else
    {
        log_event(CPDEBUG,"success to check_connect, url = %s, response code = %d", url, response_code);
        char access_token[1000] = {0};
        char *p1 = strstr(outdata, "\"access_token\":\"");
        char *p2 = strstr(outdata, "\",\"token_type");
        p1 += strlen("\"access_token\":\"");
        memcpy(access_token, p1 , p2 - p1);
        printf("%s\n", access_token);
        
        cp_string access_token_path;
        char *user;
        size_t size;
        size=strlen(argv[2])+1;
        user=calloc(size, sizeof(char));
        snprintf(user, size, "%s", argv[2]);
        strcpy(access_token_path, "/var/log/cups/access_token_eu_user_");
        strcat(access_token_path, user);
        strcat(access_token_path, ".txt");
        
        FILE *fp = NULL;
        fp = fopen(access_token_path, "w+");
        fprintf(fp, "%s", access_token);
        fclose(fp);
        bRef = true;
    }
    return bRef;
}

static int getosversion(char *key, char *value){
    int tmp, option;
    
    for (option=0; option<END_OF_OSPLISTOPTIONS; option++) {
        if (!strcasecmp(key, osplistData[option].keyname))
            break;
    }
    
    if (option == END_OF_OSPLISTOPTIONS) {
        return 0;
    }
    
    switch (option) {
        case BUILD:
            strncpy(osplistData[BUILD].value.sval, value, BUFSIZE);
            break;
        case VERSION:
            strncpy(osplistData[VERSION].value.sval, value, BUFSIZE);
            break;
        default:
            return 0;
    }
    return 1;
}

static void read_os_plist_file(char *filename){
    FILE *fp = NULL;
    cp_string buffer, key, value, tmp;
    fp = fopen(filename, "r");
    if (fp == NULL){
        log_event(CPERROR, "failed to open OS File: %s", filename);
        return;
    }
    
    bool bFindKey = false;
    while (fgets(buffer, BUFSIZE, fp) != NULL) {
        
        tmp[0]='\0';
        if (sscanf(buffer,"%*[^<]<key>%[^<]key>",tmp)) {
            if (strlen(tmp)){
                key[0]='\0';
                strcpy(key, tmp);
                bFindKey = true;
            }
        }
        
        if (sscanf(buffer,"%*[^<]<%[^>]",tmp)) {
            if (strlen(tmp) && !strncmp(tmp,"string",6) && bFindKey == true){
                value[0]='\0';
                if (sscanf(buffer,"%*[^<]<string>%[^<]string>",value)) {
                    getosversion(key, value);
                    bFindKey = false; // clear flag
                }
            }
        }
    }
    (void) fclose(fp);
    return;
}

/**
 * main()
 * @param[in]	argc 	number of argv array
 * @param[in]	argv[0] printer cue name
 * @param[in]	argv[1] job ID
 * @param[in]	argv[2] user name who published job
 * @param[in]	argv[3] job name
 * @param[in]	argv[4] copy
 * @param[in]	argv[5] CUPS OPTION
 * @param[in]	argv[6] (option):Input file name
 * @retval		0	success
 * @retval		1	error
 * @comment
 *	Send pdf file to server (use web api).
 */
int main(int argc, char *argv[]) {
    
    char *dirname, *spoolfile, *outfile, *gscall, *ppcall;
    //cp_string title;
    size_t size;
    struct passwd *passwd;
    pid_t pid;
    int		copies;			/* Number of copies to print */
    int print_duplex = 0;
    int print_color = 0;
    
    struct sigaction action;
    
    //シグナルを対応
    // SIGPIPE: 無視する
    // SIGTERM: ハンドラー SignalTermHandler を呼び出す
#ifdef HAVE_SIGSET
    sigset(SIGPIPE, SIG_IGN);
    sigset(SIGTERM, SignalTermHandler);
#elif defined(HAVE_SIGACTION)
    memset(&action, 0, sizeof(action));
    action.sa_handler = SIG_IGN;
    sigaction(SIGPIPE, &action, NULL);
    
    sigemptyset(&action.sa_mask);
    sigaddset(&action.sa_mask, SIGTERM);
    action.sa_handler = SignalTermHandler;
    sigaction(SIGTERM, &action, NULL);
#else
    signal(SIGPIPE, SIG_IGN);
    //signal(SIGINT, SignalTermHandler);
    //signal(SIGPIPE, SignalTermHandler);
    
    if(signal(SIGTERM, SignalTermHandler) == SIG_ERR)
    {
        printf("Signal err\n\n\n\n");
    }
    
#endif

    // Run as restricted user
    if (setuid(0)) {
        (void) fputs("print2server cannot be called without root privileges!\n", stderr);
        return (CUPS_BACKEND_OK);
    }
    
    // Check command-line...
    if (argc==1) {
        announce_printers();
        return (CUPS_BACKEND_OK);
    }
    if (argc<6 || argc>7) {
        (void) fputs("Usage: print2server job-id user title copies options [file]\n", stderr);
        //return (CUPS_BACKEND_FAILED);
        return (CUPS_BACKEND_CANCEL);
    }
    
    if(job_canceled){
        (void) fputs("print2server job canceled\n", stderr);
        return CUPS_BACKEND_CANCEL;
    }
    
    fputs(MSGIN_CONTECT_TO_DEVICE, stderr);
    
    // init
    if (init(argv)){
        fputs(MSGOUT_CONTECT_TO_DEVICE, stderr);
        //return (CUPS_BACKEND_FAILED);
        return (CUPS_BACKEND_CANCEL);
    }
    log_event(CPDEBUG, "initialization finished: %s", CPVERSION);
    log_event(CPDEBUG, "job id: %s\n", argv[1]);
    

    char jobid[32] = {0};
    readLastJobId(jobid);
    
    if(0 == strcmp(jobid, argv[1])){
        log_event(CPDEBUG, "duplicated job id: %s, will be dropped\n", argv[1]);
        log_close();
        sleep(10);
        //return (CUPS_BACKEND_FAILED);
        return (CUPS_BACKEND_CANCEL);
    }else{
        //saveLastJobId(argv[1]);
    }
    
    
    // Get user and password
    passwd = getUserAndPasswd(argv, stderr);
    if (passwd == NULL) {
        return (CUPS_BACKEND_CANCEL);
    }

    // Create spool file for input data
    size=strlen(Conf_Spool)+22+4;
    spoolfile=calloc(size, sizeof(char));
    if (spoolfile == NULL) {
        (void) fputs("print2server: failed to allocate memory\n", stderr);
        log_close();
        fputs(MSGOUT_CONTECT_TO_DEVICE, stderr);
        //return (CUPS_BACKEND_FAILED);
        return (CUPS_BACKEND_CANCEL);
    }
    
    cp_string sFileName;
    snprintf(sFileName, BUFSIZE, "print2server-%i", (int) getpid());
    snprintf(spoolfile, size, "%s/%s.prn", Conf_Spool, sFileName);
    //snprintf(spoolfile, size, "%s/%s.pdf", Conf_Spool, sFileName);
    log_event(CPDEBUG, "spoolfile name created: %s", spoolfile);
    unsigned long fSize = 0;

    
    ///////////////////////////////////////////////////////
    // mssage remove
    fputs(MSGOUT_CONTECT_TO_DEVICE, stderr);
    fputs(MSGOUT_CONTECT_CLOUDSERVER_ERROR, stderr);
    fputs(MSGOUT_CONTECT_LOCALSERVER_ERROR, stderr);
    fputs(MSGOUT_GET_USER_POWER_ERROR, stderr);
    fputs(MSGOUT_PRINTING_COLOR_ERROR, stderr);
    fputs(MSGOUT_PRINTING_GRAY_ERROR, stderr);
    fputs(MSGOUT_UPLOAD_FILE_ERROR, stderr);
    fputs(MSGOUT_CONTECT_OTHERS_ERROR, stderr);
    fputs(MSGOUT_CONTECT_ACCESSKEY_ERROR, stderr);
    fputs(MSGOUT_CONTECT_LACKPARAMETERS_ERROR, stderr);
    fputs(MSGOUT_CONTECT_DATABASE_ERROR, stderr);
    fputs(MSGOUT_CONTECT_USERNOTEXIST_ERROR, stderr);
    fputs(MSGOUT_CONTECT_USERFORBIDDAN_ERROR, stderr);
    fputs(MSGOUT_CONTECT_BILLNOTTURNON_ERROR, stderr);
    fputs(MSGOUT_GET_AVAILABLE_IPADDRESS_ERROR, stderr);
    fputs(MSGOUT_CONTECT_FORBIDDENUSER_ERROR, stderr);
    fputs(MSGOUT_CONTECT_PASSTRIALPERIOD_ERROR, stderr);
    
    if (argc == 6) {
        if ((fSize = preparespoolfile(0, spoolfile, NULL, argv[3], atoi(argv[1]), passwd, refData[PRINTBWDUPLEX].value.bval)) == 0) {
            //free(spoolfile);
            log_close();
            fputs(MSGOUT_CONTECT_TO_DEVICE, stderr);
            //return (CUPS_BACKEND_FAILED);
            //return (CUPS_BACKEND_CANCEL);
            return false;
        }
        log_event(CPDEBUG, "input data read from stdin");
    }
    else {
        // Try to open the print file...
        if ((fSize = preparespoolfile((int)fopen(argv[6], "r"), spoolfile, NULL, argv[3], atoi(argv[1]), passwd, refData[PRINTBWDUPLEX].value.bval)) == 0) {
            //free(spoolfile);
            log_close();
            fputs(MSGOUT_CONTECT_TO_DEVICE, stderr);
            //return (CUPS_BACKEND_FAILED);
            //return (CUPS_BACKEND_CANCEL);
            return false;
        }
        log_event(CPDEBUG, "input data read from file: %s", argv[6]);
    }
    
    char tail[32] = {0};
    readSpoolFileTail(tail);
    // Check whether spool file is a integral prn file
    if(0 == strcmp(tail, "%-12345X@PJL EOJ\n")){
        //OK spool file
        log_event(CPDEBUG, "spoolfile tail OK");
    }else{
        //NG spool file
        log_event(CPERROR, "spoolfile tail NG, broken pdf tail: [%s]", tail);
        unlink(spoolfile);
        free(spoolfile);
        log_close();
        fputs(MSGIN_UPLOAD_FILE_ERROR, stderr);
        sleep(10);
        //return (CUPS_BACKEND_FAILED);
        return (CUPS_BACKEND_CANCEL);
    }
    
    //Check Server Connect
    if (!checkServerConnnect(Plist_PrintServerName, Plist_ServerPort, cUserCode, argv, stderr))
    {
        log_event(CPSTATUS, "ClientID: %s, RefreshToken: %s.", Plist_ClientId, Plist_RefreshToken);
        if (!getToken(Plist_ServerName, Plist_ClientId, Plist_RefreshToken, argv, stderr))
        {
            fputs(MSGIN_CONTECT_TO_DEVICE, stderr);
            unlink(spoolfile);
            free(spoolfile);
            return (CUPS_BACKEND_CANCEL);
        }
    }
    
    cp_string OS_PLIST_PATH, osplist;
    strcpy(OS_PLIST_PATH, "/System/Library/CoreServices/SystemVersion.plist");
    snprintf(osplist, BUFSIZE, "%s", OS_PLIST_PATH);
    read_os_plist_file(osplist);
    
    // Up load spool file to print server
    if(!upLoadFileToPrintServer(fSize, spoolfile, argv, stderr))
    {
        // network error
        log_event(CPDEBUG,"failed to available IP address");
        // MSG: Failed to get current user print permission
        //if(!showErrInforInPrintQueue(stderr))
        //{
        //    fputs(MSGIN_UPLOAD_FILE_ERROR, stderr);
        //}
        unlink(spoolfile);
        free(spoolfile);
        return (CUPS_BACKEND_CANCEL);
    }

    saveLastJobId(argv[1]);
    //save the dest ip address & port to "LastIP" & "LastIPPort"
    if(0 != strncmp(lastIpAddress, destIpAddress, 16)){
        //the dest ip address is not same from last ip address, save the dest ip address
        //saveLastIP(destIpAddress);
        savePlistItem("LastIP", destIpAddress, argv, stderr);
    }
    if(0 != strncmp(lastIpPort, destIpPort, 6)){
        //the dest ip address is not same from last ip address, save the dest ip address
        //saveLastIPPort(destIpPort);
        savePlistItem("LastIPPort", destIpPort, argv, stderr);
    }
    
    
    if (unlink(spoolfile))
        log_event(CPERROR, "failed to unlink spoolfile: %s (non fatal)", spoolfile);
    else
        log_event(CPDEBUG, "spoolfile unlinked: %s", spoolfile);
    
    free(spoolfile);
    
    log_event(CPDEBUG, "all memory has been freed");
    log_event(CPSTATUS, "PS print successfully finished for %s", passwd->pw_name);
    log_close();
    
    return CUPS_BACKEND_OK;
}

