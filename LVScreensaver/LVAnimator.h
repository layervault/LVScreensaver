//
//  LVAnimator.h
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <ScreenSaver/ScreenSaver.h>

@protocol LVImageDelegate <NSObject>
@required
- (NSSet *)imageURLs;
@end

@interface LVAnimator : NSObject {
    ScreenSaverView *view;
    BOOL fadingLogoSlate;
}

@property (nonatomic, weak) id <LVImageDelegate> delegate;

- (id)initWithView:(ScreenSaverView *)view;
- (void)imageAdded:(NSURL *)imageURL;
- (NSURL *)randomImageURL;
- (CABasicAnimation *)fadeOutAnimation;

- (BOOL)logoSlateExists;
- (BOOL)fadeOutLogoSlate:(void (^)(void))completion;

@end