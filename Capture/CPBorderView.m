//
//  CPBorderView.m
//  Capture
//
//  Created by Jason Frame on 18/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CPBorderView.h"

@implementation CPBorderView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    CGFloat gray = 175.0f / 255.0f;
    fill_ = [[NSColor colorWithDeviceRed:gray green:gray blue:gray alpha:1.0f] retain];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [fill_ setFill];
    NSRectFill(dirtyRect);
}

@end
