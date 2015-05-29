//
//  CPAppDelegate.m
//  Capture
//
//  Created by Jason Frame on 13/12/2011.
//  Copyright (c) 2012 Garage Duo. All rights reserved.
//

#import "CPAppDelegate.h"

#import "JFImageSavePanel.h"

typedef struct capture_kernel {
    NSString *name;
    float red[3];
    float green[3];
    float blue[3];
} capture_kernel_t;

static capture_kernel_t kernels[] = {
    { .name = @"Deuteranopia (red-green)",      .red = { 0.43, 0.72, -0.15 },       .green = { 0.34, 0.57, 0.09 },      .blue = { -0.02, 0.03, 1.0 } },
    { .name = @"Protanopia (red-green)",        .red = { 0.2, 0.99, -0.19 },        .green = { 0.16, 0.79, 0.04 },      .blue = { 0.01, 0.01, 1 } },
    { .name = @"Tritanopia (blue-yellow)",      .red = { 0.972, 0.112, -0.084 },    .green = { 0.022, 0.818, 0.160 },   .blue = { -0.063, 0.881, 0.182 } },
    { .name = @"Achromatopsia (limited color)", .red = { 0.299, 0.587, 0.114 },     .green = { 0.299, 0.587, 0.114 },   .blue = { 0.299, 0.587, 0.114 } },
//    { .name = @"Achromatopsia (no color)",      .red = { 0.299, 0.299, 0.299 },     .green = { 0.299, 0.299, 0.299 },   .blue = { 0.299, 0.299, 0.299 } },
    { .name = @"No Color Correction",           .red = { 1.0, 0.0, 0.0 },           .green = { 0.0, 1.0, 0.0 },         .blue = { 0.0, 0.0, 1.0 } }
};

static const int numKernels = 5;

static inline float clampf(float v, float min, float max)
{
    if (v < min) return min;
    if (v > max) return max;
    return v;
}

static inline UInt8 colormix(UInt8* pixel, float fac[3])
{
    float c = ((float)pixel[0] * fac[0]) + ((float)pixel[1] * fac[1]) + ((float)pixel[2] * fac[2]);
    return (UInt8) clampf(c, 0, 255);
}

static void applyKernel(capture_kernel_t *kernel, unsigned char *pixels, NSInteger len)
{
    for (CFIndex i = 0; i < len; i += 4) {
        pixels[i]   = colormix(&(pixels[i]), kernel->red);
        pixels[i+1] = colormix(&(pixels[i]), kernel->green);
        pixels[i+2] = colormix(&(pixels[i]), kernel->blue);
    }
}

@implementation CPAppDelegate

@synthesize window = _window;

#pragma mark AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedIx = [defaults integerForKey:@"SelectedKernelIndex"];
    
    [self.window makeFirstResponder:nil];
    
    [toolbar_ setShowsBaselineSeparator:NO];
    
    [self.window setOpaque:NO];
    [self.window setBackgroundColor:[NSColor clearColor]];
    
    for (int i = 0; i < numKernels; i++) {
        [kernelSelect_ addItemWithTitle:kernels[i].name];
    }
    
    [kernelSelect_ selectItemAtIndex:selectedIx];
    [self updateSize];
    [self updateTools];
    
    sampledImage_ = nil;
    liveUpdating_ = NO;
    liveUpdateBusy_ = NO;

    [self startLiveUpdates];
}

- (void)applicationDidResignActive:(NSNotification *)notification
{
    [self _syncActive];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self _syncActive];
}

- (void)_syncActive
{
    BOOL isActive = [[NSApplication sharedApplication] isActive];
    [borderBottom_ setActive:isActive];
    [borderLeft_ setActive:isActive];
    [borderRight_ setActive:isActive];
    [borderTop_ setActive:isActive];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

#pragma mark Lifecycle

- (void)dealloc
{
    [super dealloc];
}

#pragma mark Main

- (void)startLiveUpdates
{
    if (liveUpdating_) {
        return;
    }
    liveUpdating_ = YES;
    if (!liveUpdateBusy_) {
        [self liveCaptureAndUpdate];
    }
}

- (void)stopLiveUpdates
{
    liveUpdating_ = NO;
}

- (void)liveCaptureAndUpdate
{
    liveUpdateBusy_= YES;
    
    __block NSImage *capturedImage = [[self captureImage] retain];
    __block capture_kernel_t *kernel = &kernels[[kernelSelect_ indexOfSelectedItem]];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSImage *processed = [[self applyProcessing:capturedImage withKernel:kernel] retain];
        [capturedImage release];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (liveUpdating_) {
                if (processed) {
                    imageBox_.filteredImage = processed;
                }
                [self performSelector:@selector(liveCaptureAndUpdate)
                           withObject:nil
                           afterDelay:0.03];
            }
            if (processed) {
                [processed release];
            }
            liveUpdateBusy_ = NO;
        });
    });
}

#pragma mark Actions

- (IBAction)save:(id)sender
{
    if (!imageBox_.filteredImage) {
        return;
    }

    [self stopLiveUpdates];
    
    JFImageSavePanel *savePanel = [JFImageSavePanel savePanel];
    [savePanel runModalForImage:imageBox_.filteredImage error:NULL];
    
    [self startLiveUpdates];
}

- (IBAction)copyToClipboard:(id)sender
{
    if (!imageBox_.filteredImage) {
        return;
    }
    
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    if (![pasteboard writeObjects:[NSArray arrayWithObjects:imageBox_.filteredImage, nil]]) {
        NSLog(@"Error writing to pasteboard!");
    }
}

- (IBAction)update:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[kernelSelect_ indexOfSelectedItem] forKey:@"SelectedKernelIndex"];
}

#pragma mark NSWindowDelegate

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
    [imageBox_ setHidden:YES];
    return frameSize;
}

- (void)windowDidResize:(NSWindow *)sender {
    [imageBox_ setHidden:YES];
    [self updateSize];
    [self updateTools];
}

#pragma mark Mojo

- (NSImage *)captureImage
{
    NSWindow *window = imageBox_.window;
    CGWindowID winID = (CGWindowID) [window windowNumber];
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    
    CGRect viewRect = [window convertRectToScreen:[imageBox_ frame]];
    viewRect.origin.y = NSMaxY([mainScreen frame]) - NSMaxY(viewRect);
    
    CGImageRef capture = CGWindowListCreateImage(viewRect,
                                                 kCGWindowListOptionOnScreenBelowWindow,
                                                 winID,
                                                 kCGWindowImageDefault);
    
    if (CGImageGetWidth(capture) <= 1) {
        CGImageRelease(capture);
        return NULL;
    } else {
        NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:capture];
        NSImage *image = [[NSImage alloc] initWithSize:NSSizeFromCGSize(viewRect.size)];
        [image addRepresentation:imageRep];
        [imageRep release];
        CGImageRelease(capture);
        return [image autorelease];
    }
}

- (NSImage*)applyProcessing:(NSImage*)image withKernel:(capture_kernel_t*)kernel
{
    if (!image) return NULL;
    
    NSSize imageLogicalSize = image.size; // size of source image when displayed on screen
    
    //
    // Create a new bitmap with the correct raw pixel size
    
    NSBitmapImageRep *imageRep = [[image representations] objectAtIndex:0];
    
    NSInteger           pixelsWide      = imageRep.pixelsWide;
    NSInteger           pixelsHigh      = imageRep.pixelsHigh;
    
    NSBitmapImageRep    *bitmap         = nil;
    NSGraphicsContext   *context        = nil;
    
    bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                     pixelsWide:pixelsWide
                                                     pixelsHigh:pixelsHigh
                                                  bitsPerSample:8
                                                samplesPerPixel:4
                                                       hasAlpha:YES
                                                       isPlanar:NO
                                                 colorSpaceName:NSDeviceRGBColorSpace
                                                   bitmapFormat:0
                                                    bytesPerRow:(pixelsWide * 4)
                                                   bitsPerPixel:32];
    
    if (!bitmap) {
        return nil;
    }
    
    context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    
    //
    // Draw the source image into the new buffer
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];
    
    [image drawInRect:NSMakeRect(0, 0, pixelsWide, pixelsHigh)
             fromRect:NSMakeRect(0, 0, imageLogicalSize.width, imageLogicalSize.height)
            operation:NSCompositeCopy
             fraction:1.0];
    
    [NSGraphicsContext restoreGraphicsState];
    
    //
    // Apply color shifting kernel
    
    applyKernel(kernel, [bitmap bitmapData], pixelsWide * pixelsHigh * 4);
    
    //
    // Create new image with color-adjusted version and return
    
    NSImage *processed = [[NSImage alloc] initWithSize:imageLogicalSize];
    [processed addRepresentation:bitmap];
    [bitmap release];
    
    return [processed autorelease];
}

- (void)updateSize {
    CGRect imageRect = imageBox_.frame;
    [txtWidth_ setStringValue:[NSString stringWithFormat:@"%d", (int)imageRect.size.width]];
    [txtHeight_ setStringValue:[NSString stringWithFormat:@"%d", (int)imageRect.size.height]];
}

- (IBAction)setSizeFromTextFields:(id)sender {
    CGFloat width = [txtWidth_ floatValue];
    CGFloat height = [txtHeight_ floatValue];
    if (width > 0 && height > 0) {
        NSRect imageFrame = imageBox_.frame;
        NSRect windowFrame = self.window.frame;
        
        CGFloat paddingX = windowFrame.size.width - imageFrame.size.width;
        CGFloat paddingY = windowFrame.size.height - imageFrame.size.height;

        CGFloat dHeight = height - imageFrame.size.height;

        windowFrame.size.width = width + paddingX;
        windowFrame.size.height = height + paddingY;
        windowFrame.origin.y -= dHeight;
        
        [self.window setFrame:windowFrame display:YES];
    }
}

- (void)updateTools {
    
    NSRect frame = imageBox_.frame;
    
    [kernelSelect_ setHidden:(frame.size.width < 233.0f)];
    
    BOOL hideSize = frame.size.width < 149.0f;
    [txtWidth_ setHidden:hideSize];
    [txtHeight_ setHidden:hideSize];
    [lblX_ setHidden:hideSize];
    
}

@end
