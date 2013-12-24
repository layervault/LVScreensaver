//
//  LVLogoLayer.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVLogoLayer.h"

#import "NSImage+BitmapRepresentation.h"

@implementation LVLogoLayer

- (id)initWithView:(ScreenSaverView *)view
{
    NSString *defaultImageName = view.isPreview ? @"Small-Logo" : @"Logo";
    NSURL *defaultImageURL = [[NSBundle bundleForClass:[self class]] URLForImageResource:defaultImageName];

    NSImage *image = [[NSImage alloc] initWithContentsOfURL:defaultImageURL];
    self = [super initWithImage:image andView:view];

    if (self) {
        self.opacity = 1.0;
    }

    return self;
}
@end
