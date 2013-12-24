//
//  LVFloatingAnimator.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVFloatingAnimator.h"

#define ARC4RANDOM_MAX 0x100000000

@implementation LVFloatingAnimator

static NSTimeInterval const TRANSLATE_DURATION = 40.0;
static CGFloat const MIN_SCALE = 0.2;
static CGFloat const MAX_SCALE = 0.9;
static CGFloat const MIN_DEPTH = -200.0;
static CGFloat const MAX_DEPTH = 200.0;

- (id)initWithLayer:(CALayer *)layer
{
    self = [super initWithLayer:layer];

    if (self) {
        currentLayers = [NSMutableSet set];
    }

    return self;
}

- (void)imageAdded:(NSURL *)imageURL
{
    if (!self.delegate)
        return;

    double delay = [self fuzzedDelay] * NSEC_PER_SEC;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
        CALayer *imageLayer = [self sublayerWithImage:image];
        imageLayer.opacity = 1.0;
        imageLayer.position = NSMakePoint(0.0, parentLayer.bounds.origin.y + parentLayer.bounds.size.height);

        CGFloat randomScale = [self randomScale];
        CGFloat randomXOffset = arc4random_uniform(parentLayer.bounds.size.width);
        CGFloat randomDepth = [self randomDepth];
        imageLayer.transform = CATransform3DConcat(CATransform3DMakeTranslation(randomXOffset, 0.0, randomDepth),
                                                   CATransform3DMakeScale(randomScale, randomScale, 1.0));

        [parentLayer addSublayer:imageLayer];
        [parentLayer setNeedsDisplay];

        [imageLayer addAnimation:[self animateDownTheScreen] forKey:@"position"];
    });
}

- (CABasicAnimation *)animateDownTheScreen
{
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];

    positionAnimation.toValue = [NSNumber numberWithFloat: -2 * (parentLayer.bounds.origin.y + parentLayer.bounds.size.height)];
    positionAnimation.duration = TRANSLATE_DURATION;
    positionAnimation.removedOnCompletion = NO;
    positionAnimation.delegate = self;
    positionAnimation.fillMode = kCAFillModeForwards;

    return positionAnimation;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    CALayer *layerToRemove = nil;

    for (CALayer *layer in currentLayers) {
        if ([layer animationForKey:@"position"] == theAnimation) {
            layerToRemove = layer;
        }
    }

    if (layerToRemove) {
        [currentLayers removeObject:layerToRemove];
    }

    [self imageAdded:[self randomImageURL]];
}

- (NSTimeInterval)fuzzedDelay
{
    return arc4random_uniform(TRANSLATE_DURATION);
}

- (CGFloat)randomScale
{
    return ((double)arc4random() / ARC4RANDOM_MAX) * (MAX_SCALE - MIN_SCALE) + MIN_SCALE;
}

- (CGFloat)randomDepth
{
    return ((double)arc4random() / ARC4RANDOM_MAX) * (MAX_DEPTH - MIN_DEPTH) + MIN_DEPTH;
}


@end