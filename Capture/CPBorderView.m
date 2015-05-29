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
        isActive_ = YES;
    }
    return self;
}

- (void)awakeFromNib
{
    CGFloat gray = 175.0f / 255.0f;
    gray = 210.0f / 255.0f;
    fillActive_ = [[NSColor colorWithDeviceRed:gray green:gray blue:gray alpha:1.0f] retain];
    
    gray = 225.0f / 255.0f;
    fillInactive_ = [[NSColor colorWithDeviceRed:gray green:gray blue:gray alpha:1.0f] retain];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (isActive_) {
        [fillActive_ setFill];
    } else {
        [fillInactive_ setFill];
    }
    NSRectFill(dirtyRect);
}

- (void)setActive:(BOOL)isActive
{
    if (isActive != isActive_) {
        isActive_ = isActive;
        [self setNeedsDisplay:YES];
    }
}

@end
