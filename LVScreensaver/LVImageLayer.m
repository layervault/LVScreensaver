//
//  LVImageLayer.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVImageLayer.h"

#import "NSImage+BitmapRepresentation.h"

@implementation LVImageLayer

- (id)initWithImage:(NSImage *)image andView:(ScreenSaverView *)view
{
    self = [super initWithView:view];

    if (self) {
        CGImageRef ref = [[image bitmapImageRepresentation] CGImage];
        NSSize containerSize = view.layer.bounds.size;

        self.bounds = NSMakeRect(0, 0, image.size.width, image.size.height);
        self.position = NSMakePoint((containerSize.width - image.size.width) / 2.0, (containerSize.height - image.size.height) / 2.0);
        self.contents = (__bridge id)(ref);
        self.opacity = 0.0;
        self.anchorPoint = NSZeroPoint;
    }

    return self;
}

@end
