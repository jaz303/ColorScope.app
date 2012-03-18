//
//  CPSavePanel.m
//  Capture
//
//  Created by Jason Frame on 06/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPSavePanel.h"
#import "CPPreferencesController.h"

@interface CPSavePanel ()
@property (assign) IBOutlet NSView *accessoryView;
@property (assign) IBOutlet NSPopUpButton *fileTypes;
@property (assign) IBOutlet NSSlider *compressionFactor;
@end

@implementation CPSavePanel

@synthesize accessoryView, fileTypes, compressionFactor;

+ (CPSavePanel *)savePanel
{
    CPSavePanel *panel = [[CPSavePanel alloc] init];
    return [panel autorelease];
}

- (void)dealloc
{
    [self.accessoryView release];
}

- (void)runForWindow:(NSWindow *)window withImage:(NSImage *)image
{
    if (!image) return;
    
    [self retain];
    [image retain];
    
    NSNib *accessoryNib = [[NSNib alloc] initWithNibNamed:@"CPSavePanelAccessoryView" bundle:nil];
    [accessoryNib instantiateNibWithOwner:self topLevelObjects:nil];
    [accessoryNib release];
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *savedPath = [defaults stringForKey:kCPPrefsLastSaveDir];
//    NSURL *dir = [NSURL fileURLWithPath:(savedPath ? savedPath : NSHomeDirectory())];
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAccessoryView:self.accessoryView];
//    [savePanel setDirectoryURL:dir];
    [savePanel setCanCreateDirectories:YES];
    [savePanel setCanSelectHiddenExtension:YES];
    [savePanel setExtensionHidden:NO];
    [savePanel setTitle:@"Save Captured Image"];
    [savePanel setAllowsOtherFileTypes:NO];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObjects:
                                    (NSString*)kUTTypePNG,
                                    (NSString*)kUTTypeJPEG,
                                    (NSString*)kUTTypeTIFF,
                                    nil]];
    
    [savePanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            
//            [defaults setObject:[[savePanel directoryURL] absoluteString]
//                         forKey:kCPPrefsLastSaveDir];
            
            NSString *extension = [[savePanel URL] pathExtension];
            CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                                        (CFStringRef)extension,
                                                                        NULL);
            
            NSData *outData = nil;
            
            if (UTTypeConformsTo(fileUTI, kUTTypePNG)) {
                outData = [NSBitmapImageRep representationOfImageRepsInArray:[image representations]
                                                                   usingType:NSPNGFileType
                                                                  properties:nil];
            } else if (UTTypeConformsTo(fileUTI, kUTTypeJPEG)) {
                outData = [NSBitmapImageRep representationOfImageRepsInArray:[image representations]
                                                                   usingType:NSJPEGFileType
                                                                  properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                              [NSNumber numberWithFloat:0.2], NSImageCompressionFactor, nil]];
            } else if (UTTypeConformsTo(fileUTI, kUTTypeTIFF)) {
                outData = [NSBitmapImageRep representationOfImageRepsInArray:[image representations]
                                                                   usingType:NSTIFFFileType
                                                                  properties:nil];
            } else {
                
            }
            
            CFRelease(fileUTI);
            
            if (outData) {
                [outData writeToURL:[savePanel URL] atomically:YES];
            } else {
                
            }
        }
        
        [self release];
        [image release];
    }];
}

@end
