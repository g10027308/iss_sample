//
//  ViewController2.h
//  PDFAutoInstaller
//
//  Created by rits on 2018/06/07.
//  Copyright © 2018 rits. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface ViewController2 : NSViewController
{

    NSString *_UserID;
    NSString *_DingUID;
    NSString *_PrinterName;
}

@property NSString *UserID;
@property NSString *DingUID;
@property NSString *PrinterName;
@property (weak) IBOutlet NSTextField *lblInstallInfor;

@property (weak) IBOutlet NSProgressIndicator *installProgress;

@property (weak) IBOutlet NSButton *buttonFinish;


@end
