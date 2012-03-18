//
//  CPPreferencesController.h
//  Capture
//
//  Created by Jason Frame on 30/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *kCPPrefsLastSaveDir;
extern NSString *kCPPrefsShouldClearOnResize;
extern NSString *kCPPrefsShouldClearOnMove;

@interface CPPreferencesController : NSWindowController
{
}

- (IBAction)close:(id)sender;

@end
