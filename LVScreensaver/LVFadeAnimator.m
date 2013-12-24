//
//  LVFadeAnimator.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVFadeAnimator.h"

@implementation LVFadeAnimator

static NSTimeInterval const SECONDS_PER_DESIGN = 10.0;
static NSTimeInterval const BLANK_SECONDS = 1.0;
static NSTimeInterval const FADE_IN_SECONDS = 1.0;

- (void)imageAdded:(NSURL *)imageURL
{
    if (!self.delegate)
        return;

    if (parentLayer.sublayers.count) {
        CALayer *sublayer = [parentLayer.sublayers firstObject];

        // If our sublayer does not have an animation applied, it is the starting slate for the
        // screensaver. We then apply an animation to remove the slate.
        if ([[sublayer animationKeys] count] == 0) {
            [sublayer addAnimation:[self fadeOutAnimation] forKey:@"fadeOutAnimation"];
        }

        return;
    }

    NSURL *url = [self randomImageURL];

    if (!url)
        return;

    NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
    CALayer *imageLayer = [self sublayerWithImage:image];
    [parentLayer addSublayer:imageLayer];
    [parentLayer setNeedsDisplay];

    // Don't cycle images if we only have the starting image.
    if ([[self.delegate imageURLs] count] > 1)
        [imageLayer addAnimation:[self animation] forKey:@"animationGroup"];
    else
        imageLayer.opacity = 1.0;

}

- (CAAnimationGroup *)animation
{
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = @0.0;
    fadeInAnimation.toValue = @1.0;
    fadeInAnimation.duration = FADE_IN_SECONDS;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode = kCAFillModeForwards;

    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.fromValue = @1.0;
    fadeOutAnimation.toValue = @0.0;
    fadeOutAnimation.duration = FADE_IN_SECONDS;
    fadeOutAnimation.removedOnCompletion = NO;
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.beginTime = SECONDS_PER_DESIGN - FADE_IN_SECONDS;

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = SECONDS_PER_DESIGN;
    group.animations = @[fadeInAnimation, fadeOutAnimation];
    group.delegate = self;

    return group;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    parentLayer.sublayers = nil;
    [self imageAdded:nil];
}

@end
