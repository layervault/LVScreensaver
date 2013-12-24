//
//  LVLayer.h
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <ScreenSaver/ScreenSaver.h>

@interface LVLayer : CALayer {
    BOOL fading;
    ScreenSaverView *view;
}

- (id)initWithView:(ScreenSaverView *)view;
- (BOOL)fadeOut:(void (^)(void))completion;

@end
