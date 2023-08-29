//
//  GetSerialNumber.m
//  CGetSerial
//
//  Created by r3pc on 2023/01/16.
//

#import <Foundation/Foundation.h>

char *GetSerialNumber(void);
void SetUserID(char *);
char *GetUserID(void);

static cp_string _user;
static cp_string _serial;

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

char *GetUserID() {
    return _user;
}
