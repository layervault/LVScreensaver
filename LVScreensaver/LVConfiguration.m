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
static NSString * const EMAIL_DEFAULTS_KEY = @"Email";
static NSString * const PASSWORD_DEFAULTS_KEY = @"Password";
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

- (NSString *)email
{
    return [defaults stringForKey:EMAIL_DEFAULTS_KEY];
}

- (NSString *)password
{
    return [defaults stringForKey:PASSWORD_DEFAULTS_KEY];
}

- (BOOL)hasCredentials
{
    return [self email] && [self password];
}

- (void)eraseCredentials
{
    [defaults removeObjectForKey:EMAIL_DEFAULTS_KEY];
    [defaults removeObjectForKey:PASSWORD_DEFAULTS_KEY];
    [defaults synchronize];
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

- (void)setEmail:(NSString *)email
{
    [defaults setValue:email forKey:EMAIL_DEFAULTS_KEY];
    [defaults synchronize];
}

- (void)setPassword:(NSString *)password
{
    [defaults setValue:password forKey:PASSWORD_DEFAULTS_KEY];
    [defaults synchronize];
}

@end
