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

typedef enum {
    FadingIn,
    Normal,
    FadingOut,
} ScreenSaverStateType;

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
    NSMutableSet *imageURLs;
    NSDate *thresholdDate;

    LVTraverser *traverser;
    LVAnimator *animator;
    NSURL *defaultImageURL;
}

- (void)addImageURL:(NSURL *)url;

@end
