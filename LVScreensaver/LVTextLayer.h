//
//  LVTextLayer.h
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <ScreenSaver/ScreenSaver.h>

@interface LVTextLayer : CATextLayer {
    ScreenSaverView *view;
    BOOL fading;
}

- (id)initWithView:(ScreenSaverView *)view;
- (BOOL)fadeOut:(void (^)(void))completion;

@end
