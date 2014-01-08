//
//  LVConfiguration.h
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ScreenSaverDefaults;

@interface LVConfiguration : NSObject {
    ScreenSaverDefaults *defaults;
}

- (void)setRiverMode;
- (void)setSlideshowMode;
- (BOOL)isRiverMode;
- (BOOL)isSlideshowMode;

@end
