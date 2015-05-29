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
#import "CPCaptureBox.h"

@interface CPAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet CPBorderView       *borderLeft_;
    IBOutlet CPBorderView       *borderRight_;
    IBOutlet CPBorderView       *borderBottom_;
    IBOutlet CPBorderView       *borderTop_;
    
    IBOutlet NSToolbar          *toolbar_;
    IBOutlet NSPopUpButton      *kernelSelect_;
    
    IBOutlet NSTextField        *txtWidth_;
    IBOutlet NSTextField        *txtHeight_;
    IBOutlet NSTextField        *lblX_;
    
    IBOutlet CPCaptureBox       *imageBox_;
    
    NSImage                     *sampledImage_;
    
    BOOL                        liveUpdating_;
    BOOL                        liveUpdateBusy_;
    
    NSUserDefaults              *defaults_;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)save:(id)sender;
- (IBAction)copyToClipboard:(id)sender;
- (IBAction)update:(id)sender;
- (IBAction)setSizeFromTextFields:(id)sender;

@end
