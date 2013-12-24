//
//  LVScreensaverView.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/21/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVScreensaverView.h"

#import <LayerVaultAPI.h>

@implementation LVScreensaverView

static NSString * const MyModuleName = @"com.layervault.LVScreensaver";
static NSTimeInterval const FRAMES_PER_SECOND = 30.0;
static NSString * const CLIENT_KEY = @"YOUR_CLIENT_KEY";
static NSString * const CLIENT_SECRET = @"YOUR_CLIENT_SECRET";

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self reloadIsPreview:isPreview];
    }
    
    return self;
}

- (void)addImageURL:(NSURL *)url
{
    @synchronized(imageURLs) {
        [imageURLs addObject:url];

        // Make sure the logo gets removed from the rotation.
        if ([imageURLs containsObject:defaultImageURL])
            [imageURLs removeObject:defaultImageURL];

        [animator imageAdded: url];
    }
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
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    [self setNeedsDisplay:YES];
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

    if ([defaults integerForKey:@"RiverMode"])
        [riverMode setState:NSOnState];

    if ([defaults integerForKey:@"SlideshowMode"])
        [slideshowMode setState:NSOnState];

    return configSheet;
}

- (IBAction)cancelClick:(id)sender
{
    [[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction)okClick:(id)sender
{
    self.layer.sublayers = nil;
    [self.layer setNeedsDisplay];
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];

    [spinner setHidden:NO];

    [defaults setBool:riverMode.state       forKey:@"RiverMode"];
    [defaults setBool:slideshowMode.state   forKey:@"SlideshowMode"];
    [defaults synchronize];

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
                               [traverser fetchImagesNewerThan:thresholdDate];
                           }

                          [[NSApplication sharedApplication] endSheet:configSheet];
                       }
     ];

    [self reloadIsPreview:YES];
}

- (void)reloadIsPreview:(BOOL)isPreview
{
    [self setWantsLayer:YES];
    [self.layer setBackgroundColor:[[NSColor blackColor] CGColor]];
    [self setAnimationTimeInterval:1/FRAMES_PER_SECOND];

    [self setupThresholdDate];

    NSString *defaultImageName = isPreview ? @"Small-Logo" : @"Logo";
    defaultImageURL = [[NSBundle bundleForClass:[self class]] URLForImageResource:defaultImageName];
    imageURLs = [NSMutableSet setWithObjects:defaultImageURL, nil];

    [self setupTraverser];
    [self setupAnimator];
}

- (NSSet *)imageURLs
{
    return imageURLs;
}

- (void)setupAnimator
{
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];

    if (![defaults boolForKey:@"RiverMode"] && ![defaults boolForKey:@"SlideshowMode"]) {
        [defaults setBool:YES forKey:@"RiverMode"];
        [defaults synchronize];
    }

    if ([defaults boolForKey:@"RiverMode"])
        animator = [[LVFloatingAnimator alloc] initWithLayer:self.layer];
    else if ([defaults boolForKey:@"SlideshowMode"])
        animator = [[LVFadeAnimator alloc] initWithLayer:self.layer];

    animator.delegate = self;
    [animator imageAdded: nil];
}

- (void)setupTraverser
{
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];

    client = [[LVCHTTPClient alloc] initWithClientID:CLIENT_KEY secret:CLIENT_SECRET];
    traverser = [[LVTraverser alloc] initWithClient:client
                                           andWidth:[self bounds].size.width
                                          andHeight:[self bounds].size.height];
    traverser.delegate = self;

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
                                   [traverser fetchImagesNewerThan:thresholdDate];
                               }
                           }];
    }
}

- (void)setupThresholdDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *lastWeekComponents = [[NSDateComponents alloc] init];
    NSDate *today = [NSDate date];
    [lastWeekComponents setWeek:-1];
    thresholdDate = [calendar dateByAddingComponents:lastWeekComponents toDate:today options:0];
}

@end
