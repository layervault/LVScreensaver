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
    }

    return self;
}

- (void)imageAdded:(NSURL *)imageURL
{
    
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

- (LVLogoLayer *)logoSlate
{
    for (CALayer *layer in view.layer.sublayers) {
        if ([layer isMemberOfClass:[LVLogoLayer class]]) {
            return (LVLogoLayer *)layer;
        }
    }

    return nil;
}

- (BOOL)logoSlateExists
{
    return !![self logoSlate];
}

@end
