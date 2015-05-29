//
//  CPCaptureBox.m
//  ColorScope
//
//  Created by Jason Frame on 15/12/2014.
//
//

#import "CPCaptureBox.h"

@implementation CPCaptureBox

- (void)awakeFromNib {
    imageView_ = [self viewWithTag:1234];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (NSImage *)filteredImage {
    return imageView_.image;
}

- (void)setFilteredImage:(NSImage *)filteredImage {
    imageView_.image = filteredImage;
    [self setHidden:(self.window.inLiveResize || filteredImage == nil)];
}

@end
