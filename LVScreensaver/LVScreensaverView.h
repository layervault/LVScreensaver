//
//  LVScreensaverView.h
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/21/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "LVTraverser.h"
#import "LVFadeAnimator.h"
#import "LVFloatingAnimator.h"

@class LVCHTTPClient;
@class LVConfiguration;

@interface LVScreensaverView : ScreenSaverView <LVTraverserDelegate, LVImageDelegate>
{
    IBOutlet id configSheet;
    IBOutlet NSTextField *emailField;
    IBOutlet NSTextField *passwordField;
    IBOutlet NSProgressIndicator *spinner;
    IBOutlet NSMatrix *modeMatrix;

    IBOutlet NSButtonCell *riverMode;
    IBOutlet NSButtonCell *slideshowMode;

    LVCHTTPClient *client;
    NSMutableOrderedSet *_imageURLs;
    NSDate *thresholdDate;

    LVTraverser *traverser;
    LVAnimator *animator;
    NSURL *defaultImageURL;

    LVConfiguration *config;
}

- (void)addImageURL:(NSURL *)url;
- (NSSet *)imageURLs;

@end
