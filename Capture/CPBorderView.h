//
//  CPBorderView.h
//  Capture
//
//  Created by Jason Frame on 18/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CPBorderView : NSView
{
    NSColor *fillActive_;
    NSColor *fillInactive_;
    BOOL isActive_;
}

- (void)setActive:(BOOL)isActive;

@end
