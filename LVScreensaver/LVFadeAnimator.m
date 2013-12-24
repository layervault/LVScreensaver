//
//  LVFadeAnimator.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVFadeAnimator.h"
#import "LVImageLayer.h"

@implementation LVFadeAnimator

static NSTimeInterval const SECONDS_PER_DESIGN = 10.0;
static NSTimeInterval const BLANK_SECONDS = 1.0;
static NSTimeInterval const FADE_IN_SECONDS = 1.0;

- (void)imageAdded:(NSURL *)imageURL
{
    NSLog(@"yo yo yo %@", imageURL);
    if (!self.delegate)
        return;

    if ([self logoSlateExists]) {
        [self fadeOutLogoSlate:^{
            [self imageAdded:imageURL];
        }];
        return;
    }

    if ([view.layer.sublayers count] > 0)
        return;

    [self displayNewImage];
}

- (void)displayNewImage
{
    NSURL *url = [self randomImageURL];

    if (!url)
        return;

    NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
    CALayer *imageLayer = [[LVImageLayer alloc] initWithImage:image andView:view];
    [view.layer addSublayer:imageLayer];
    [view.layer setNeedsDisplay];

    NSLog(@"Going to display image with URL %@", url);
    [imageLayer addAnimation:[self animation] forKey:@"animationGroup"];
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
    view.layer.sublayers = nil;
    [self imageAdded:nil];
}

@end
