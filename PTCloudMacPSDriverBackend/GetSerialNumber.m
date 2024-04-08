//
//  GetSerialNumber.m
//  CGetSerial
//
//  Created by g10027308 on 2023/01/16.
//  Copyright © 2023 ricoh. All rights reserved.
//

#import <Foundation/Foundation.h>

char *GetSerialNumber(void);
void SetUserID(char *);
char *GetUserID(void);

static cp_string _user;
static cp_string _serial;

/**
 * GetSerialNumber
 * デバイスのシリアル番号を内部変数_serialに設定して返す
 * @retval  シリアル番号（取得できない場合は0x00）
 */
char *GetSerialNumber() {
    NSString *serial = nil;
    memset(_serial, 0x00, sizeof(cp_string));
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,                                      IOServiceMatching("IOPlatformExpertDevice"));
    if (platformExpert) {
        CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,                                         CFSTR(kIOPlatformSerialNumberKey),                                         kCFAllocatorDefault, 0);
        if (serialNumberAsCFString) {
            serial = CFBridgingRelease(serialNumberAsCFString);
        }
        IOObjectRelease(platformExpert);
    }
    if (serial != nil) {
        strncpy(_serial, (char *)[serial UTF8String], sizeof(cp_string)-1);
    }
    return _serial;
}

/**
 * SetUserID
 * 指定されたログインユーザIDを内部変数_userに設定する
 * @param[in]    userid    ログインユーザID
 */
void SetUserID(char *userid) {
    if (userid) {
        if (strlen(userid) >= sizeof(cp_string)) {
            strncpy(_user, userid, sizeof(cp_string)-1);
        } else {
            strcpy(_user, userid);
        }
    } else {
        memset(_user, 0x00, sizeof(cp_string));
    }
}

/**
 * GetUserID
 * 内部変数_userの値を返す
 * @retval  _userに設定されたログインユーザID（取得できない場合は0x00）
 */
char *GetUserID() {
    return _user;
}
