//
//  LVScreensaverView.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/21/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVScreensaverView.h"

#import <LayerVaultAPI.h>
#import "NSImage+ProportionalScaling.h"

@implementation LVScreensaverView

static NSString * const MyModuleName = @"com.layervault.LVScreensaver";
static NSTimeInterval const FRAMES_PER_SECOND = 30.0;
static NSTimeInterval const SECONDS_PER_DESIGN = 10.0;
static NSTimeInterval const BLANK_SECONDS = 1.0;
static NSTimeInterval const FADE_IN_SECONDS = 1.0;
static NSString * const CLIENT_KEY = @"YOUR_CLIENT_KEY";
static NSString * const CLIENT_SECRET = @"YOUR_SECRET_KEY";

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        tick = 0;
        alpha = 0;
        seconds = 0;
        state = FadingIn;

        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *lastWeekComponents = [[NSDateComponents alloc] init];
        NSDate *today = [NSDate date];
        [lastWeekComponents setWeek:-1];
        thresholdDate = [calendar dateByAddingComponents:lastWeekComponents toDate:today options:0];

        ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];

        client = [[LVCHTTPClient alloc] initWithClientID:CLIENT_KEY
                                                  secret:CLIENT_SECRET];

        if ([defaults stringForKey:@"Email"]) {
            [client authenticateWithEmail:[defaults stringForKey:@"Email"]
                                 password:[defaults stringForKey:@"Password"]
                               completion:^(AFOAuthCredential *credential, NSError *error) {
                                   if (credential) {
                                       // Save Credential to Keychain
                                       [AFOAuthCredential storeCredential:credential
                                                           withIdentifier:client.serviceProviderIdentifier];

                                       // Set Authorization Header
                                       [client setAuthorizationHeaderWithCredential:credential];
                                       [self fetchImagesNewerThan:thresholdDate];
                                   }
                               }];

        }

        imageURLs = [NSMutableSet new];

        [self setAnimationTimeInterval:1/FRAMES_PER_SECOND];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [[NSColor blackColor] drawSwatchInRect:rect];

    if (state == FadingIn) {
        alpha = MIN(seconds / FADE_IN_SECONDS, 1.0);
    }
    else if (state == Normal) {
        alpha = 1.0;
    }
    else if (state == FadingOut) {
        alpha = MAX(1.0 - (seconds / FADE_IN_SECONDS), 0);
    }

    [[currentImage imageByScalingProportionallyToSize:[self bounds].size] drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:alpha];
}

- (void)animateOneFrame
{
    if (state == FadingIn && seconds > FADE_IN_SECONDS) {
        tick = 0;
        state = Normal;
    }
    else if (state == Normal && seconds > SECONDS_PER_DESIGN) {
        tick = 0;
        state = FadingOut;
    }
    else if (state == FadingOut && seconds > FADE_IN_SECONDS) {
        tick = 0;
        state = FadingIn;
        currentImage = nil;
        [self addedImage];
    }

    seconds = tick / FRAMES_PER_SECOND;
    tick += 1;

    [self setNeedsDisplay:YES];
    return;
    return;
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];

    if (!configSheet) {
        if (![NSBundle loadNibNamed:@"ConfigureSheet" owner:self]) {
            NSLog( @"Failed to load configure sheet.");
            NSBeep();
        }
    }

    if ([defaults stringForKey:@"Email"])
        emailField.stringValue = [defaults stringForKey:@"Email"];

    if ([defaults stringForKey:@"Password"])
        passwordField.stringValue = [defaults stringForKey:@"Password"];

    return configSheet;
}

- (IBAction)cancelClick:(id)sender
{
    [[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction)okClick:(id)sender
{
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];

    [spinner setHidden:NO];

    [client authenticateWithEmail:emailField.stringValue
                         password:passwordField.stringValue
                       completion:^(AFOAuthCredential *credential, NSError *error) {
                           [spinner setHidden:YES];

                           if (credential) {
                               // Save Credential to Keychain
                               [AFOAuthCredential storeCredential:credential
                                                   withIdentifier:client.serviceProviderIdentifier];

                               // Set Authorization Header
                               [client setAuthorizationHeaderWithCredential:credential];

                               [defaults setValue:emailField.stringValue forKey:@"Email"];
                               [defaults setValue:passwordField.stringValue forKey:@"Password"];
                               [defaults synchronize];
                               [self fetchImagesNewerThan:thresholdDate];
                           }

                          [[NSApplication sharedApplication] endSheet:configSheet];
    }];
}

- (void)fetchImagesNewerThan:(NSDate *)date
{
    [client getMeWithCompletion:^(LVCUser *user,
                                  NSError *error,
                                  AFHTTPRequestOperation *operation) {

        for (LVCProject *project in user.projects) {
            [self descendIntoProject:project newerThan:date];
        }

    }];
}

- (void)descendIntoProject:(LVCProject *)project newerThan:(NSDate *)date
{
    if ([project.dateUpdated compare:date] != NSOrderedDescending)
        return;

    [client getProjectFromPartial:project completion:^(LVCProject *project, NSError *error, AFHTTPRequestOperation *operation) {
        for (LVCFile *file in project.files)
            [self descendIntoFile:file newerThan:date];

        for (LVCFolder *folder in project.folders)
            [self descendIntoFolder:folder newerThan:date];
    }];
}

- (void)descendIntoFolder:(LVCFolder *)folder newerThan:(NSDate *)date
{
    if ([folder.dateUpdated compare:date] != NSOrderedDescending)
        return;

    for (LVCFile *file in folder.files)
        [self descendIntoFile:file newerThan:date];

    for (LVCFolder *subfolder in folder.folders)
        [self descendIntoFolder:subfolder newerThan:date];
}

- (void)descendIntoFile:(LVCFile *)file newerThan:(NSDate *)date
{
    if ([file.dateUpdated compare:date] != NSOrderedDescending)
        return;

    [client getPreviewURLsForFile:file width:[self bounds].size.width height:[self bounds].size.height completion:^(NSArray *previewURLs, NSError *error, AFHTTPRequestOperation *operation) {
        [imageURLs addObject:[previewURLs objectAtIndex:([previewURLs count] - 1)]];
        [self addedImage];
    }];
}

- (void)addedImage
{
    NSLog(@"Images %lu", (unsigned long)[imageURLs count]);
    if (currentImage)
        return;

    NSURL *url = [self randomImageURL];
    NSLog(@"Setting image: %@", url);

    if (!url)
        return;

    currentImage = [[NSImage alloc] initWithContentsOfURL:url];
}

- (NSURL *)randomImageURL
{
    NSUInteger myCount = [imageURLs count];
    if (myCount)
        return [[imageURLs allObjects] objectAtIndex:arc4random_uniform(myCount)];
    else
        return nil;
}


@end
