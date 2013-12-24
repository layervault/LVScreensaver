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

@class LVLogoLayer;

@protocol LVImageDelegate <NSObject>
@required
- (NSSet *)imageURLs;
@end

@interface LVAnimator : NSObject {
    ScreenSaverView *view;
}

@property (nonatomic, weak) id <LVImageDelegate> delegate;

- (id)initWithView:(ScreenSaverView *)view;
- (void)imageAdded:(NSURL *)imageURL;
- (NSURL *)randomImageURL;

- (BOOL)logoSlateExists;
- (LVLogoLayer *)logoSlate;
- (void)stop;

@end