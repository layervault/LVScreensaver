//
//  LVTextLayer.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVTextLayer.h"

@implementation LVTextLayer

- (id)initWithView:(ScreenSaverView *)aView {
    self = [super init];
    if (self) {
        view = aView;
    }
    return self;
}

// Idempotent method that will fade out the logo slate if it exists.
- (BOOL)fadeOut:(void (^)(void))completion
{
    if (fading)
        return YES;

    fading = YES;
    CABasicAnimation *fadeOut = [self fadeOutAnimation];

    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            [self removeFromSuperlayer];
            [view.layer setNeedsDisplay];

            if (completion)
                completion();
        }];
        [self addAnimation:fadeOut forKey:@"fadeOut"];
    } [CATransaction commit];

    return YES;
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
