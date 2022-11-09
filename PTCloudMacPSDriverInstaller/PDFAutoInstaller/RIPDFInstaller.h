//
//  RIPrinterInstaller.h
//  Ricoh_Printer_Installer
//
//  Created by rits on 11/2/17.
//  Copyright (c) 2017 ricoh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIPrinterInstaller : NSObject

-(BOOL)runShellInstallPkg:(NSString*)usrID PrinterName:(NSString*)printerName Url:(NSString*)UrlProtocol;
-(BOOL)runShellCopyPlist;
@end
