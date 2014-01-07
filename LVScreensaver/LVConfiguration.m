//
//  LVConfiguration.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/23/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVConfiguration.h"
#import <ScreenSaver/ScreenSaverDefaults.h>

@implementation LVConfiguration

static NSString * const MyModuleName = @"com.layervault.LVScreensaver";
static NSString * const RIVER_MODE_DEFAULTS_KEYS = @"RiverMode";
static NSString * const SLIDESHOW_MODE_DEFAULTS_KEYS = @"SlideshowMode";

- (id)init
{
    self = [super init];

    if (self) {
        defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
        if (![defaults boolForKey:RIVER_MODE_DEFAULTS_KEYS] && ![defaults boolForKey:SLIDESHOW_MODE_DEFAULTS_KEYS]) {
            [defaults setBool:YES forKey:RIVER_MODE_DEFAULTS_KEYS];
            [defaults synchronize];
        }

        if ([defaults boolForKey:RIVER_MODE_DEFAULTS_KEYS] && [defaults boolForKey:SLIDESHOW_MODE_DEFAULTS_KEYS]) {
            [defaults setBool:NO forKey:SLIDESHOW_MODE_DEFAULTS_KEYS];
            [defaults synchronize];
        }
    }

    return self;
}

- (BOOL)isRiverMode
{
    return [defaults boolForKey:RIVER_MODE_DEFAULTS_KEYS];
}

- (BOOL)isSlideshowMode
{
    return [defaults boolForKey:SLIDESHOW_MODE_DEFAULTS_KEYS];
}

- (void)setRiverMode
{
    [defaults setBool:YES forKey:RIVER_MODE_DEFAULTS_KEYS];
    [defaults setBool:NO  forKey:SLIDESHOW_MODE_DEFAULTS_KEYS];
    [defaults synchronize];
}

- (void)setSlideshowMode
{
    [defaults setBool:NO forKey:RIVER_MODE_DEFAULTS_KEYS];
    [defaults setBool:YES  forKey:SLIDESHOW_MODE_DEFAULTS_KEYS];
    [defaults synchronize];
}

@end
