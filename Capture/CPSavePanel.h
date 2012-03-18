//
//  CPSavePanel.h
//  Capture
//
//  Created by Jason Frame on 06/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPSavePanel : NSObject
{
}

+ (CPSavePanel *)savePanel;

- (void)runForWindow:(NSWindow *)window withImage:(NSImage *)image;

@end
