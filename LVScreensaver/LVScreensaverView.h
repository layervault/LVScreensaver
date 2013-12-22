//
//  LVScreensaverView.h
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/21/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@class LVCHTTPClient;

typedef enum {
    FadingIn,
    Normal,
    FadingOut,
} ScreenSaverStateType;

@interface LVScreensaverView : ScreenSaverView
{
    IBOutlet id configSheet;
    IBOutlet NSTextField *emailField;
    IBOutlet NSTextField *passwordField;
    IBOutlet NSProgressIndicator *spinner;
    LVCHTTPClient *client;
    NSMutableSet *imageURLs;
    NSDate *thresholdDate;
    NSImage *currentImage;
    NSInteger state;
    NSInteger tick;
    double alpha;
    double seconds;
}

@end
