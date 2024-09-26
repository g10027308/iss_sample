//
//  EncodeDecode.m
//  CGetSerial
//
//  Created by g10027308 on 2023/01/16.
//  Copyright © 2023 ricoh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

#include <sys/types.h>
#include <pwd.h>

#define CRYPTLEN 16;

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

//文字列をSHA256でハッシュして返す
NSString *_sha256(NSString *text)
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

//文字列をSHA256でハッシュして返す（C言語用interface）
const char *sha256(char *str) {
    NSString *text = [NSString stringWithCString: str encoding: NSUTF8StringEncoding];
    return [_sha256(text) UTF8String];
}

//文字列をSHA256でハッシュして返す（サイズ制限あり）（C言語用interface）
const char *sha256WithLen(char *str, unsigned long size) {
    NSString *st = [NSString stringWithCString:str encoding: NSUTF8StringEncoding];
    NSString *text = [NSMutableString stringWithString:[_sha256(st) substringToIndex: size]];
    return [text UTF8String];
}

// 平文パスワード、keyword、initial vectorから
// AES128方式で暗号化されたパスワードを返す
// デバイスのシリアル番号＋ログインユーザIDをSHA256でハッシュし、
// 最初のCRYPTLENバイトをkey、最後のCRYPTLENバイトを逆順に使用してinitial vectorとして渡す前提
unsigned char *encode(char *str, char *key, char *iv) {
    unsigned char *buf;
    NSString *mypassword = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
//NSLog(@"mypasword: %@", mypassword);
    NSData *mypassdata = [mypassword dataUsingEncoding:NSUTF8StringEncoding];
    NSData *mypd = [mypassdata AES128EncryptWithKey:[NSString stringWithCString:key encoding:NSUTF8StringEncoding] iv:[NSString stringWithCString:iv encoding:NSUTF8StringEncoding]];
//    NSLog(@"mypd: %@", mypd);
    buf = (unsigned char *)[mypd bytes];
    return buf;
}

/**
 * getmypass
 * プロパティリストから暗号化されたデータを取得する
 * @param[in]    plistfile    プロパティリストファイル名（パスを含む）
 * @param[in]    key    取得する項目名
 * @param[out]   size    取得したデータのサイズ
 * @retval  取得したデータ（取得に失敗した場合はNULL）
 */
unsigned char *getmypass(char *plistfile, char *key, int *size) {
    NSString *plistName = [NSString stringWithCString:plistfile encoding:NSUTF8StringEncoding];
    NSMutableDictionary *dicSetting = [NSMutableDictionary dictionaryWithContentsOfFile:plistName];
    NSData *val = nil;
    unsigned long len = 0L;
    
    if (dicSetting != nil) {
        val = [dicSetting objectForKey:[NSString stringWithCString:key encoding:NSUTF8StringEncoding]];
        len = val.length;
    }
    if (len) {
        unsigned char *pas = malloc(len+1);
        memcpy(pas, (unsigned char *)[val bytes], len);
        pas[len] = 0x00;
        *size = (int)len;
        return pas;
    }
    return NULL;
}

//デバイスのシリアル番号、ログインユーザID、キーワードサイズから暗号化・復号化に使うkeywordとinitial vectorを返す
void getKeyIV(char *sid, char *uid, char *keystr, char *ivstr, int len) {
    static cp_string keyword;

//    strcpy(keystr, "abcd1234");
//    strcpy(ivstr, "4321dcba");
    
//    printf("SerialNumber:%s\n", sid);
//    printf("LoginUserID:%s\n", uid);
    if (sid && uid) {
        strcpy(keyword, sid);
        strcat(keyword, uid);
        printf("SerialNumber:%s\n", keyword);
        strcpy(keyword, sha256(keyword));
        printf("SHA256:%s\n", keyword);
        memset(keystr, 0x00, len+1);
        memset(ivstr, 0x00, len+1);
        int slen = (int)strlen(keyword);
        if (slen >= len) {
            strncpy(keystr, keyword, len);
            int i = 0;
            char *p = keyword + (slen - 1);
            for (i = 0; i < len; i++, p--) {
                ivstr[i] = *p;
            }
            ivstr[i] = 0x00;
        }
//        printf("keystr:%s\n", keystr);
//        printf("ivstr:%s\n", ivstr);
    } else {
        printf("CANNNOT GET SERIAL NUMBER\n");
    }
}

// 暗号化されたパスワード、keyword、initial vector、データサイズから
// AES128方式で復号化して平文パスワードを返す
// デバイスのシリアル番号＋ログインユーザIDをSHA256でハッシュし、
// 最初のCRYPTLENバイトをkey、最後のCRYPTLENバイトを逆順に使用してinitial vectorとして渡す前提
char *decode(unsigned char *str, char *key, char *iv, int size) {
    static cp_string _decode;

    NSData *mypd = [NSData dataWithBytes:str length:size];
 //   NSLog(@"length: %u, length2: %d¥n", sizeof(str), i);
    NSData *mydepd = [mypd AES128DecryptWithKey:[NSString stringWithCString:key encoding:NSUTF8StringEncoding]  iv:[NSString stringWithCString:iv encoding:NSUTF8StringEncoding]];
    NSString *mydec = [[NSString alloc]initWithData:mydepd encoding:NSUTF8StringEncoding];
//    NSLog(@"mydec: %@¥n", mydec);
    memset(_decode, 0x00, sizeof(cp_string));
    if (mydec != nil) {
        strncpy(_decode, (char *)[mydec UTF8String], sizeof(cp_string)-1);
        [mydec release];
    }
    return _decode;
}

/**
 * decrypt
 * 暗号化されたデータを復号化して返す
 * @param[in]    str    暗号化されたデータ
 * @param[in]    sid    デバイスのシリアル番号
 * @param[in]    uid    ログインユーザID
 * @param[in]   size    暗号化データのサイズ
 * @retval  復号化したデータ（取得に失敗した場合はNULL）
 */
char *decrypt(unsigned char *str, char *sid, char *uid, int size) {
    int len = CRYPTLEN;
    char keystr[len+1];
    char ivstr[len+1];
    
    getKeyIV(sid, uid, keystr, ivstr, len);
//    printf("sid: %s, uid: %s, keystr:%s, ivstr:%s, len:%d\n", sid, uid, keystr, ivstr, len);
    char *dec = decode(str, keystr, ivstr, size);
//    printf("decode(size:%d): %s -> %s\n", size, str, dec);
    return dec;
}
