//
//  showHelpHowToGetUID.m
//  PDFAutoInstallerForDingPrint
//
//  Created by rits on 2018/11/28.
//  Copyright © 2018 rits. All rights reserved.
//

#import "showHelpHowToGetUID.h"

@interface showHelpHowToGetUID ()

@end

@implementation showHelpHowToGetUID

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.ImgHelpPage setImage:[NSImage imageNamed:NSLocalizedString(@"FileNameHelpPage1", nil)]];
    [self.btnLastPage setEnabled:NO];
    self.lblTitleHelpPage.stringValue = NSLocalizedString(@"TitleHelpPage1", nil);
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)clickLastPageButton:(id)sender {
    if([self.ImgHelpPage.image.name isEqualToString:NSLocalizedString(@"FileNameHelpPage3", nil)])
    {
        [self.ImgHelpPage setImage:[NSImage imageNamed:NSLocalizedString(@"FileNameHelpPage2", nil)]];
        self.lblTitleHelpPage.stringValue = NSLocalizedString(@"TitleHelpPage2", nil);
        [self.btnNextPage setEnabled:YES];
    }
    else if([self.ImgHelpPage.image.name isEqualToString:NSLocalizedString(@"FileNameHelpPage2", nil)])
    {
        [self.ImgHelpPage setImage:[NSImage imageNamed:NSLocalizedString(@"FileNameHelpPage1", nil)]];
        self.lblTitleHelpPage.stringValue = NSLocalizedString(@"TitleHelpPage1", nil);
        [self.btnLastPage setEnabled:NO];
    }
    
}

- (IBAction)clickNextPageButton:(id)sender {
    if([self.ImgHelpPage.image.name isEqualToString:NSLocalizedString(@"FileNameHelpPage1", nil)])
    {
        [self.ImgHelpPage setImage:[NSImage imageNamed:NSLocalizedString(@"FileNameHelpPage2", nil)]];
        self.lblTitleHelpPage.stringValue = NSLocalizedString(@"TitleHelpPage2", nil);
        [self.btnLastPage setEnabled:YES];
    }
    else if([self.ImgHelpPage.image.name isEqualToString:NSLocalizedString(@"FileNameHelpPage2", nil)])
    {
        [self.ImgHelpPage setImage:[NSImage imageNamed:NSLocalizedString(@"FileNameHelpPage3", nil)]];
        self.lblTitleHelpPage.stringValue = NSLocalizedString(@"TitleHelpPage3", nil);
        [self.btnNextPage setEnabled:NO];
    }
}

- (IBAction)clickCloseWindow:(id)sender {
    [self close];
    //[[NSApplication sharedApplication] terminate:self];
}

@end
