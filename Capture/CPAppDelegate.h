//
//  CPAppDelegate.h
//  Capture
//
//  Created by Jason Frame on 13/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#import "CPBorderView.h"

@interface CPAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet CPBorderView       *borderLeft_;
    IBOutlet CPBorderView       *borderRight_;
    IBOutlet CPBorderView       *borderBottom_;
    
    IBOutlet NSToolbar          *toolbar_;
    IBOutlet NSPopUpButton      *kernelSelect_;
    
    IBOutlet NSBox              *imageBox_;
    IBOutlet NSImageView        *imageView_;
    
    NSImage                     *originalImage_;
    
    NSUserDefaults              *defaults_;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)capture:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)update:(id)sender;
- (IBAction)save:(id)sender;

- (IBAction)showPreferences:(id)sender;

@end
