//
//  CPPreferencesController.m
//  Capture
//
//  Created by Jason Frame on 30/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CPPreferencesController.h"

NSString *kCPPrefsLastSaveDir           = @"CPPrefsLastSaveDir";
NSString *kCPPrefsShouldClearOnResize   = @"CPPrefsShouldClearOnResize";
NSString *kCPPrefsShouldClearOnMove     = @"CPPrefsShouldClearOnMove";

@implementation CPPreferencesController

- (id)init
{
    self = [super initWithWindowNibName:@"CPPreferencesController" owner:self];
    if (self) {
        
    }
    return self;
}

- (void)windowDidLoad
{
    [self.window center];
}

- (IBAction)close:(id)sender
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSApp stopModal];
}

@end
