//
//  AppDelegate.m
//  PDFAutoInstaller
//
//  Created by rits on 2018/06/06.
//  Copyright © 2018 rits. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    // Override point for customization after application launch.
    
    // OpenSSL
    SSL_load_error_strings();                /* readable error messages */
    SSL_library_init();                      /* initialize library */
    
    // libcurl - see http://curl.haxx.se/libcurl/
    curl_global_init(0L);
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
    // libcurl cleanup
    curl_global_cleanup();
}

- (IBAction)clickPreferencesMemu:(id)sender {
//    if(nil == _settingWindow){
//        _settingWindow = [[SettingWindow alloc] initWithWindowNibName:@"SettingWindow"];
//    }
//
//    [[_settingWindow window] center];
//    [_settingWindow.window orderFront:nil];
 //   [[NSApplication sharedApplication] runModalForWindow:_loginWindow.window];
}

@end
