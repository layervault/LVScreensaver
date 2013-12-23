//
//  LVAnimator.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVAnimator.h"

#import "NSImage+ProportionalScaling.h"
#import "NSImage+BitmapRepresentation.h"

@implementation LVAnimator

@synthesize delegate;

- (id)initWithLayer:(CALayer *)layer
{
    self = [super init];

    if (self) {
        parentLayer = layer;
    }

    return self;
}

- (void)imageAdded { }

- (NSURL *)randomImageURL
{
    NSUInteger myCount = [[self.delegate imageURLs] count];
    if (myCount)
        return [[[self.delegate imageURLs] allObjects] objectAtIndex:arc4random_uniform(myCount)];
    else
        return nil;
}

- (CALayer *)sublayerWithImage:(NSImage *)image
{
    CGImageRef ref = [[image bitmapImageRepresentation] CGImage];
    CALayer *imageLayer = [[CALayer alloc] init];
    NSSize containerSize = parentLayer.bounds.size;

    imageLayer.bounds = NSMakeRect(0, 0, image.size.width, image.size.height);
    imageLayer.position = NSMakePoint((containerSize.width - image.size.width) / 2.0, (containerSize.height - image.size.height) / 2.0);
    imageLayer.contents = (__bridge id)(ref);
    imageLayer.opacity = 0.0;
    imageLayer.anchorPoint = NSZeroPoint;

    return imageLayer;
}

- (CABasicAnimation *)fadeOutAnimation
{
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];

    fadeOutAnimation.fromValue = @1.0;
    fadeOutAnimation.toValue = @0.0;
    fadeOutAnimation.duration = 1.0;
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.removedOnCompletion = NO;
    fadeOutAnimation.delegate = self;

    return fadeOutAnimation;
}

@end
