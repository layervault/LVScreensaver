//
//  LVCredentialTextLayer.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVCredentialTextLayer.h"

@implementation LVCredentialTextLayer

- (id)initWithView:(ScreenSaverView *)view
{
    self = [super initWithView:view];
    if (self) {
        self.position = NSMakePoint(view.bounds.size.width / 2, view.bounds.size.height * 0.3 * -1.0);
        self.string = @"Please enter valid credentials.";
        self.opacity = 1.0;
        self.bounds = view.bounds;
        self.fontSize = view.isPreview ? 12.0 : 48.0;
        self.foregroundColor = [[NSColor whiteColor] CGColor];
        self.alignmentMode = kCAAlignmentCenter;
    }

    return self;
}

@end
