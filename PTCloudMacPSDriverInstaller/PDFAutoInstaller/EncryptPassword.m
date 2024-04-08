//
//  EncryptPassword.m
//  Ricoh PS Print Setting
//
//  Created by g10027308 on 2023/02/01.
//  Copyright © 2023 ricoh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "EncryptPassword.h"

#include <sys/types.h>
#include <pwd.h>

const int CRYPTLEN = 16;    //暗号化に使うキーの長さ

@interface NSData (AES)
- (NSData *)AES128crypte:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv;
- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv;
- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv;
@end

@implementation NSData (AES)
//指定したkeyword, initial vectorでAES128方式の暗号/復号を行い、結果を返す
- (NSData *)AES128crypte:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv
{
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
    }
    free(buffer);
    return nil;
}
//指定したkeyword, initial vectorで暗号化
- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128crypte:kCCEncrypt key:key iv:iv];
}

//指定したkeyword, initial vectorで復号化
- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128crypte:kCCDecrypt key:key iv:iv];
}
@end

@interface EncryptPassword()

- (NSString *)sha256:(NSString *)text;
- (NSString *)getSerialNumber;

@end

@implementation EncryptPassword

//文字列をSHA256でハッシュして返す
- (NSString *)sha256:(NSString *)text
{
    const char *s=[text cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *out =
    [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

//デバイスのシリアル番号を返す（暗号化キーに使用）
- (NSString *)getSerialNumber
{
    NSString *serial = nil;
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    if (platformExpert) {
        CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, CFSTR(kIOPlatformSerialNumberKey), kCFAllocatorDefault, 0);
        if (serialNumberAsCFString) {
            serial = CFBridgingRelease(serialNumberAsCFString);
        }
        IOObjectRelease(platformExpert);
    }
    return serial;
}

/**
 * EncryptPassword::getEncryptPassword
 * AES128方式で暗号化されたパスワードを返す
 * デバイスのシリアル番号＋ログインユーザIDをSHA256でハッシュし、
 * 最初のCRYPTLENバイトをkey、最後のCRYPTLENバイトを逆順に使用してinitial vectorとする
 * @param[in]    strPassword    平文のパスワード
 * @param[in]    userid    ログインユーザID
 * @retval  暗号化されたパスワード
 */
- (NSData *)getEncryptPassword:(NSString *)strPassword userid:(NSString *)userid
{
    NSString *serialnumber = [self getSerialNumber];
    NSString *keyword = [NSString stringWithFormat:@"%@%@",serialnumber, userid];
    NSString *keyiv = [self sha256:keyword];
    NSLog(@"Serial Number:%@, userid: %@ -> %@ -> %@", serialnumber, userid, keyword, keyiv);
    NSData *mypd = nil;
/*
    NSMutableString *keystr = [NSMutableString stringWithString:[NSString stringWithCString:CRYPTKEY encoding:NSUTF8StringEncoding]];
    NSMutableString *ivstr = [NSMutableString stringWithString:[NSString stringWithCString:CRYPTVEC encoding:NSUTF8StringEncoding]];
 */

    if (keyiv.length >= CRYPTLEN) {
        NSMutableString *keystr = [NSMutableString stringWithString:[keyiv substringToIndex: CRYPTLEN]];
        NSMutableString *ivstr = [NSMutableString stringWithString:@""];
        NSString *substr = [keyiv substringFromIndex: keyiv.length - CRYPTLEN];
        for (NSUInteger i = [substr length]; i > 0; i--) {
            [ivstr appendString: [substr substringWithRange: NSMakeRange(i-1, 1)]];
        }
        NSLog(@"keystr:%@, ivstr:%@", keystr, ivstr);
/*
        keystr = [NSMutableString stringWithString:[[self sha256:keystr] substringToIndex: CRYPTLEN]];
        ivstr = [NSMutableString stringWithString:[[self sha256:ivstr] substringToIndex: CRYPTLEN]];
        NSLog(@"SHA256 -> keystr:%@, ivstr:%@", keystr, ivstr);
 */
//        NSLog(@"cryptkey:%@, cryptiv:%@", keystr, ivstr);
        
        const char *myp = [strPassword UTF8String];
        NSString *mypassword = [NSString stringWithCString:myp encoding:NSUTF8StringEncoding];
        NSData *mypassdata = [mypassword dataUsingEncoding:NSUTF8StringEncoding];
        mypd = [mypassdata AES128EncryptWithKey:keystr iv:ivstr];
    }
    
    
    return mypd;
}

/**
 * EncryptPassword::getDecryptPassword
 * 暗号化されたパスワードを復号化して返す
 * @param[in]    password    暗号化されたパスワード
 * @param[in]    userid    ログインユーザID
 * @retval  平文に復号されたパスワード
 */
- (NSString *)getDecryptPassword:(NSData *)password userid:(NSString *)userid
{
    NSString *serialnumber = [self getSerialNumber];
    NSString *keyword = [NSString stringWithFormat:@"%@%@",serialnumber, userid];
    NSString *keyiv = [self sha256:keyword];
    NSString *mypassword = nil;
    NSLog(@"Serial Number:%@, userid: %@ -> %@ -> %@", serialnumber, userid, keyword, keyiv);
/*
    NSMutableString *keystr = [NSMutableString stringWithString:[self sha256:[NSString stringWithCString:CRYPTKEY encoding:NSUTF8StringEncoding]]];
    NSMutableString *ivstr = [NSMutableString stringWithString:[self sha256:[NSString stringWithCString:CRYPTVEC encoding:NSUTF8StringEncoding]]];
*/
    if (keyiv.length >= CRYPTLEN) {
        NSMutableString *keystr = [NSMutableString stringWithString:[keyiv substringToIndex: CRYPTLEN]];
        NSMutableString *ivstr = [NSMutableString stringWithString:@""];
        NSString *substr = [keyiv substringFromIndex: keyiv.length - CRYPTLEN];
        for (NSUInteger i = [substr length]; i > 0; i--) {
            [ivstr appendString: [substr substringWithRange: NSMakeRange(i-1, 1)]];
        }
        NSLog(@"keystr:%@, ivstr:%@", keystr, ivstr);
        /*
         keystr = [NSMutableString stringWithString:[[self sha256:keystr] substringToIndex: CRYPTLEN]];
         ivstr = [NSMutableString stringWithString:[[self sha256:ivstr] substringToIndex: CRYPTLEN]];
         NSLog(@"SHA256 -> keystr:%@, ivstr:%@", keystr, ivstr);
         */
        //NSLog(@"cryptkey:%@, cryptiv:%@", keystr, ivstr);
        
        NSData *mypd = [password AES128DecryptWithKey:keystr iv:ivstr];
        mypassword = [[NSString alloc] initWithData:mypd
                                                     encoding:NSUTF8StringEncoding];
    }
    
    return mypassword;
}
@end
