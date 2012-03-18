//
//  CPAppDelegate.m
//  Capture
//
//  Created by Jason Frame on 13/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CPAppDelegate.h"

#import "CPPreferencesController.h"
#import "CPSavePanel.h"

@interface CPAppDelegate ()
- (void)installDefaults;
@end

typedef struct capture_kernel {
    NSString *name;
    float red[3];
    float green[3];
    float blue[3];
} capture_kernel_t;

static capture_kernel_t kernels[] = {
    { .name = @"Deuteranopia (No Green)",   .red = { 0.43, 0.72, -0.15 },       .green = { 0.34, 0.57, 0.09 },      .blue = { -0.02, 0.03, 1.0 } },
    { .name = @"Protanopia (No Red)",       .red = { 0.2, 0.99, -0.19 },        .green = { 0.16, 0.79, 0.04 },      .blue = { 0.01, 0.01, 1 } },
    { .name = @"Tritanopia (No Blue)",      .red = { 0.972, 0.112, -0.084 },    .green = { 0.022, 0.818, 0.160 },   .blue = { -0.063, 0.881, 0.182 } },
    { .name = @"Achromatopsia (No Color)",  .red = { 0.299, 0.587, 0.114 },     .green = { 0.299, 0.587, 0.114 },   .blue = { 0.299, 0.587, 0.114 } },
    { .name = @"Normal",                    .red = { 1.0, 0.0, 0.0 },           .green = { 0.0, 1.0, 0.0 },         .blue = { 0.0, 0.0, 1.0 } }
};

static const int numKernels = 5;

static float clampf(float v, float min, float max)
{
    if (v < min) return min;
    if (v > max) return max;
    return v;
}

static UInt8 colormix(UInt8* pixel, float fac[3])
{
    float c = ((float)pixel[0] * fac[0]) + ((float)pixel[1] * fac[1]) + ((float)pixel[2] * fac[2]);
    return (UInt8) clampf(c, 0, 255);
}

@implementation CPAppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self installDefaults];
    
    [toolbar_ setShowsBaselineSeparator:NO];
    
    [imageBox_ setHidden:YES];
    [self.window setOpaque:NO];
    [self.window setBackgroundColor:[NSColor clearColor]];
    
    for (int i = 0; i < numKernels; i++) {
        [kernelSelect_ addItemWithTitle:kernels[i].name];
    }
    
    originalImage_ = NULL;
}

- (NSImage *)captureImage
{
    NSWindow *window = [imageView_ window];
    
    CGWindowID winID = (CGWindowID) [window windowNumber];
    
    CGRect viewRect = NSRectToCGRect([imageBox_ frame]);
    viewRect.origin.y = NSMaxY([[window screen] frame]) - NSMaxY(viewRect);
    
    CGRect windowRect = [window frame];
    viewRect.origin.x += windowRect.origin.x;
    viewRect.origin.y -= windowRect.origin.y;
    
    CGImageRef capture = CGWindowListCreateImage(viewRect,
                                                 kCGWindowListOptionOnScreenBelowWindow,
                                                 winID,
                                                 kCGWindowImageDefault);
    
    if (CGImageGetWidth(capture) <= 1) {
        CGImageRelease(capture);
        return NULL;
    } else {
        NSImage *image = [[NSImage alloc] initWithCGImage:capture size:NSZeroSize];
        CGImageRelease(capture);
        return [image autorelease];
    }
}

- (NSImage*)applyProcessing:(NSImage*)image
{
    if (!image) return NULL;
    
    int                 width           = [image size].width;
    int                 height          = [image size].height;
    NSInteger           pixelDataLength = width * height * 4;
    unsigned char       *pixels         = NULL;
    NSBitmapImageRep    *bitmap         = nil;
    NSGraphicsContext   *context        = nil;

    bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                     pixelsWide:width
                                                     pixelsHigh:height
                                                  bitsPerSample:8
                                                samplesPerPixel:4
                                                       hasAlpha:YES
                                                       isPlanar:NO
                                                 colorSpaceName:NSDeviceRGBColorSpace
                                                   bitmapFormat:0
                                                    bytesPerRow:([image size].width * 4)
                                                   bitsPerPixel:32];
    
    if (!bitmap) {
        return nil;
    }
    
    pixels  = [bitmap bitmapData];
    context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];
    
    [image drawInRect:NSMakeRect(0, 0, width, height)
             fromRect:NSMakeRect(0, 0, width, height)
            operation:NSCompositeCopy
             fraction:1.0];
    
    [NSGraphicsContext restoreGraphicsState];
    
    capture_kernel_t *selectedKernel = &kernels[[kernelSelect_ indexOfSelectedItem]];

    for (CFIndex i = 0; i < pixelDataLength; i += 4) {
        UInt8   r = colormix(&(pixels[i]), selectedKernel->red),
                g = colormix(&(pixels[i]), selectedKernel->green),
                b = colormix(&(pixels[i]), selectedKernel->blue);
        
        pixels[i]   = r;
        pixels[i+1] = g;
        pixels[i+2] = b;
    }
    
    NSImage *processed = [[NSImage alloc] initWithSize:[image size]];
    [processed addRepresentation:bitmap];
    
    return [processed autorelease];
}

- (void)presentImage:(NSImage*)image
{
    [imageBox_ setHidden:NO];
    [imageView_ setImage:image];
    [imageBox_ setNeedsDisplay:YES];
    [imageView_ setNeedsDisplay:YES];
}

- (IBAction)capture:(id)sender
{
    //[sender setEnabled:NO];
    
    NSImage *capturedImage = [self captureImage];
    
    if (!capturedImage) {
        NSLog(@"error - couldn't capture image");
        //[sender setEnabled:YES];
        return;
    }
    
    if (originalImage_) {
        [originalImage_ release];
        originalImage_ = nil;
    }
    
    originalImage_ = [capturedImage retain];
    
    [self update:nil];
}

- (IBAction)clear:(id)sender
{
    [imageView_ setImage:nil];
    [imageBox_ setHidden:YES];
    
    NSWindow *win = [imageView_ window];
    [win setHasShadow:NO];
    [win setHasShadow:YES];
    
    if (originalImage_) {
        [originalImage_ release];
        originalImage_ = nil;
    }
}

- (IBAction)update:(id)sender
{
    if (!originalImage_) return;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSImage *processed = [[self applyProcessing:originalImage_] retain];
        if (processed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentImage:processed];
                [processed release];
                //[sender setEnabled:YES];
            });
        }
    });
}

- (IBAction)save:(id)sender
{
    CPSavePanel *savePanel = [CPSavePanel savePanel];
    [savePanel runForWindow:self.window withImage:[imageView_ image]];
}

- (IBAction)showPreferences:(id)sender
{
    CPPreferencesController *prefs = [[CPPreferencesController alloc] init];
    [NSApp runModalForWindow:[prefs window]];
    [[prefs window] orderOut:self];
    [prefs release];
}

#pragma mark NSWindowDelegate

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
    if (originalImage_ && [defaults_ boolForKey:kCPPrefsShouldClearOnResize]) {
        [self clear:nil];
    }
    return frameSize;
}

- (void)windowDidMove:(NSNotification *)notification {
    if (originalImage_ && [defaults_ boolForKey:kCPPrefsShouldClearOnMove]) {
        [self clear:nil];
    }
}

- (void)installDefaults
{
    defaults_ = [NSUserDefaults standardUserDefaults];
    [defaults_ registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:NO], kCPPrefsShouldClearOnMove,
                                 [NSNumber numberWithBool:NO], kCPPrefsShouldClearOnResize,
                                 nil]];
}

@end
