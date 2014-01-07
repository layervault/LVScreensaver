//
//  LVScreensaverView.h
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/21/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

#import "LVFadeAnimator.h"
#import "LVFloatingAnimator.h"

@class LVCHTTPClient;
@class LVConfiguration;

@interface LVScreensaverView : ScreenSaverView
{
    IBOutlet id configSheet;

    IBOutlet NSButtonCell *riverMode;
    IBOutlet NSButtonCell *slideshowMode;

    NSMutableOrderedSet *_imageURLs;

    LVAnimator *animator;
    NSURL *defaultImageURL;

    LVConfiguration *config;
}

- (void)addImageURL:(NSURL *)url;
- (NSSet *)imageURLs;

@end
