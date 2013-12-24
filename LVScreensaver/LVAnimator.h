//
//  LVAnimator.h
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@protocol LVImageDelegate <NSObject>
@required
- (NSSet *)imageURLs;
@end

@interface LVAnimator : NSObject {
    CALayer *parentLayer;
}

@property (nonatomic, weak) id <LVImageDelegate> delegate;

- (id)initWithLayer:(CALayer *)layer;
- (void)imageAdded:(NSURL *)imageURL;
- (NSURL *)randomImageURL;
- (CALayer *)sublayerWithImage:(NSImage *)image;
- (CABasicAnimation *)fadeOutAnimation;

@end