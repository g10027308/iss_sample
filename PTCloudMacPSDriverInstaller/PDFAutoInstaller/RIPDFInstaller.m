//
//  RIPrinterInstaller.m
//  Ricoh_Printer_Installer
//
//  Created by rits on 11/2/17.
//  Copyright (c) 2017 ricoh. All rights reserved.
//

#import "RIPDFInstaller.h"
#import <CommonCrypto/CommonCryptor.h> // DES, AES
#import <CommonCrypto/CommonDigest.h> // SHA1, SHA256

#include <sys/types.h>
#include <pwd.h>


@interface RIPrinterInstaller (Install)
-(BOOL)installPackageWithAuthority;
-(BOOL)installPackage:(NSString *)pkgpath;
-(BOOL)copyCustomPPDWithAuthority;

-(NSString *)printerNameRandom;
@end

@implementation RIPrinterInstaller

-(NSString *) getloginUser{
    uid_t current_user_id = getuid();
    struct passwd *pwentry = getpwuid(current_user_id);
    char *loginUser = pwentry->pw_name;
    NSString *loginName = [[NSString alloc] initWithUTF8String:loginUser];
    return loginName;
}

-(BOOL)runShellInstallPkg:(NSString*)usrID PrinterName:(NSString*)printerName Url:(NSString*)UrlProtocol
{
    BOOL bRet = NO;
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    NSString * resourcePath = [NSString stringWithFormat:@"/%@/Contents/Resources", appPath];
    NSString * shellPathFile = [NSString stringWithFormat:@"/%@/InstallPkg.sh", resourcePath];
    
    NSString *loginName = [self getloginUser];
    NSString * plistPath = [NSString stringWithFormat: @"/Library/Preferences/com.rits.PdfDriverInstaller_%@.plist", loginName];
    
    NSString *homePrePath = NSHomeDirectory();
    homePrePath = [homePrePath stringByAppendingString:plistPath];
    
    //run shell script(install *.pkg\install printer\set userId)
    NSString * scriptCommand = nil;
    scriptCommand = [NSString stringWithFormat:@"do shell script \"/bin/bash \'%@\' \'%@\' \'%@\' \'%@\' \'%@\' \'%@\' / -allowUntrusted\" with administrator privileges", shellPathFile, resourcePath, printerName, UrlProtocol, usrID, homePrePath];
    
    
    NSLog(@"scriptCommand=%@", scriptCommand);
    NSDictionary * error = [NSDictionary new];
    NSAppleScript * appleScript = [[NSAppleScript alloc] initWithSource:scriptCommand];
    NSAppleEventDescriptor * retDescriptor = [appleScript executeAndReturnError: &error];
    
    if (retDescriptor!=nil && [error count]==0)
    {
        [self setDefaultPrinter];
        bRet = YES;
    }
    else
    {
        NSLog(@"%@", error);
        bRet = NO;
    }
    
    return bRet;
}

-(BOOL)setDefaultPrinter
{
    BOOL bRet = NO;
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    NSString * resourcePath = [NSString stringWithFormat:@"/%@/Contents/Resources", appPath];
    NSString * shellPathFile = [NSString stringWithFormat:@"/%@/setDefalutPrinter.sh", resourcePath];
    
    //run shell script(install *.pkg\install printer\set userId)
    NSString * scriptCommand = nil;
    
    scriptCommand = [NSString stringWithFormat:@"do shell script \"/bin/bash \'%@\' -allowUntrusted\"", shellPathFile];
    
    
    NSLog(@"scriptCommand=%@", scriptCommand);
    NSDictionary * error = [NSDictionary new];
    NSAppleScript * appleScript = [[NSAppleScript alloc] initWithSource:scriptCommand];
    NSAppleEventDescriptor * retDescriptor = [appleScript executeAndReturnError: &error];
    
    if (retDescriptor!=nil && [error count]==0)
    {
        bRet = YES;
    }
    
    
    return bRet;
}



-(BOOL)runShellCopyPlist {
    BOOL bRet = NO;
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    NSString * resourcePath = [NSString stringWithFormat:@"/%@/Contents/Resources", appPath];
    NSString * shellPathFile = [NSString stringWithFormat:@"/%@/CopyPlist.sh", resourcePath];
    
    
    NSString *loginName = [self getloginUser];
    NSString * plistPath = [NSString stringWithFormat: @"/Library/Preferences/com.rits.PdfDriverInstaller_%@.plist", loginName];
    
    NSString *homePrePath = NSHomeDirectory();
    homePrePath = [homePrePath stringByAppendingString:plistPath];
    
    
    //run shell script(install *.pkg\install printer\set userId)
    NSString * scriptCommand = nil;
    
    scriptCommand = [NSString stringWithFormat:@"do shell script \"/bin/bash \'%@\' \'%@\' -allowUntrusted\" with administrator privileges", shellPathFile, homePrePath];
    
    
    NSLog(@"scriptCommand=%@", scriptCommand);
    NSDictionary * error = [NSDictionary new];
    NSAppleScript * appleScript = [[NSAppleScript alloc] initWithSource:scriptCommand];
    NSAppleEventDescriptor * retDescriptor = [appleScript executeAndReturnError: &error];
    
    if (retDescriptor!=nil && [error count]==0)
    {
        bRet = YES;
    }
    else
    {
        NSLog(@"%@", error);
        bRet = NO;
    }
    
    return bRet;
}

@end

