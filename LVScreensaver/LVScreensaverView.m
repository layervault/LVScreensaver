//
//  LVScreensaverView.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/21/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVScreensaverView.h"

#import <LayerVaultAPI.h>

#import "LVCredentialTextLayer.h"
#import "LVLogoLayer.h"
#import "LVConfiguration.h"

@implementation LVScreensaverView

static NSString * const MyModuleName = @"com.layervault.LVScreensaver";
static NSTimeInterval const FRAMES_PER_SECOND = 30.0;
static NSString * const CLIENT_KEY = @"YOUR_CLIENT_KEY";
static NSString * const CLIENT_SECRET = @"YOUR_CLIENT_SECRET";
static NSInteger const MAX_IMAGES = 20;

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        _imageURLs = [[NSMutableOrderedSet alloc] init];
        config = [[LVConfiguration alloc] init];
        [self setWantsLayer:YES];
        [self.layer setBackgroundColor:[[NSColor blackColor] CGColor]];
        [self setAnimationTimeInterval:1/FRAMES_PER_SECOND];
        [self setupThresholdDate];

        [self start];
    }
    
    return self;
}

- (void)addImageURL:(NSURL *)url
{
    @synchronized(_imageURLs) {
        [_imageURLs addObject:url];
        [animator imageAdded:url];

        // If some new images have come in, force the "oldest" one out.
        // It won't get displayed immediately, but it will get displayed eventually.
        if ([_imageURLs count] > MAX_IMAGES) {
            [_imageURLs removeObjectAtIndex:0];
        }
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

    if ([config email])
        emailField.stringValue = [config email];

    if ([config password])
        passwordField.stringValue = [config password];

    if ([config isRiverMode]) {
        [riverMode setState:NSOnState];
        [slideshowMode setState:NSOffState];
    }
    else if ([config isSlideshowMode]) {
        [riverMode setState:NSOffState];
        [slideshowMode setState:NSOnState];
    }

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

    [spinner setHidden:NO];

    if (riverMode.state)
        [config setRiverMode];
    else if (slideshowMode.state)
        [config setSlideshowMode];

    [self stop];
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

                               [config setEmail:emailField.stringValue];
                               [config setPassword:passwordField.stringValue];
                               [self restart];
                           }

                          [[NSApplication sharedApplication] endSheet:configSheet];
                       }
     ];
}

- (void)start
{
    [self.layer addSublayer: [[LVLogoLayer alloc] initWithView:self]];

    if (![config hasCredentials])
        [self.layer addSublayer: [[LVCredentialTextLayer alloc] initWithView:self]];

    [self setupTraverser];
    [self setupAnimator];
}

- (void)stop
{
    self.layer.sublayers = nil;
}

- (void)restart
{
    [self stop];
    [self start];
}

- (NSSet *)imageURLs
{
    NSLog(@"sup sup sup sup %@", _imageURLs);
    return [_imageURLs set];
}

- (void)setupAnimator
{
    if ([config isRiverMode])
        animator = [[LVFloatingAnimator alloc] initWithView:self];
    else if ([config isSlideshowMode])
        animator = [[LVFadeAnimator alloc] initWithView:self];

    animator.delegate = self;
}

- (void)setupTraverser
{
    client = [[LVCHTTPClient alloc] initWithClientID:CLIENT_KEY secret:CLIENT_SECRET];
    traverser = [[LVTraverser alloc] initWithClient:client
                                           andWidth:[self bounds].size.width
                                          andHeight:[self bounds].size.height];
    traverser.delegate = self;

    if ([config hasCredentials]) {
        [client authenticateWithEmail:[config email]
                             password:[config password]
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
