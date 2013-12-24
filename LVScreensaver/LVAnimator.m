//
//  LVAnimator.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVAnimator.h"
#import "LVLogoLayer.h"

@implementation LVAnimator

@synthesize delegate;

- (id)initWithView:(ScreenSaverView *)aView
{
    self = [super init];

    if (self) {
        view = aView;
        fadingLogoSlate = NO;
    }

    return self;
}

- (NSURL *)randomImageURL
{
    NSLog(@"image urls %lu", (unsigned long)[[self.delegate imageURLs] count]);
    NSUInteger myCount = [[self.delegate imageURLs] count];
    if (myCount)
        return [[[self.delegate imageURLs] allObjects] objectAtIndex:arc4random_uniform(myCount)];
    else
        return nil;
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

// Idempotent method that will fade out the logo slate if it exists.
- (BOOL)fadeOutLogoSlate:(void (^)(void))completion
{
    if (fadingLogoSlate)
        return YES;

    if (![self logoSlateExists])
        return NO;

    fadingLogoSlate = YES;
    CALayer *logoSlate = [self logoSlate];
    CABasicAnimation *fadeOut = [self fadeOutAnimation];

    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            [[self logoSlate] removeFromSuperlayer];
            view.layer.sublayers = nil;
            [view.layer setNeedsDisplay];
            completion();
        }];
        [logoSlate addAnimation:fadeOut forKey:@"fadeOut"];
    } [CATransaction commit];

    return YES;
}

- (CALayer *)logoSlate
{
    for (CALayer *layer in view.layer.sublayers) {
        if ([layer isMemberOfClass:[LVLogoLayer class]]) {
            return layer;
        }
    }

    return nil;
}

- (BOOL)logoSlateExists
{
    return !![self logoSlate];
}

@end
