//
//  LVScreensaverView.h
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/21/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "LVTraverser.h"

@class LVCHTTPClient;

typedef enum {
    FadingIn,
    Normal,
    FadingOut,
} ScreenSaverStateType;

@interface LVScreensaverView : ScreenSaverView <TraverserDelegate>
{
    IBOutlet id configSheet;
    IBOutlet NSTextField *emailField;
    IBOutlet NSTextField *passwordField;
    IBOutlet NSProgressIndicator *spinner;
    LVCHTTPClient *client;
    NSMutableSet *imageURLs;
    NSDate *thresholdDate;

    LVTraverser *traverser;
}

- (void)addImageURL:(NSURL *)url;

@end
