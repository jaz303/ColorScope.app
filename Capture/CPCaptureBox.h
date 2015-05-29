//
//  CPCaptureBox.h
//  ColorScope
//
//  Created by Jason Frame on 15/12/2014.
//
//

#import <Cocoa/Cocoa.h>

@interface CPCaptureBox : NSBox
{
    NSImageView *imageView_;
}

@property (retain) NSImage *filteredImage;

@end
