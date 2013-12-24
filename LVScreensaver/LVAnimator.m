//
//  LVAnimator.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVAnimator.h"

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
- (void)fadeOutLogoSlate
{

}

@end
