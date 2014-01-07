//
//  LVScreensaverView.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/21/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVScreensaverView.h"

#import <LayerVaultAPI/LayerVaultAPI.h>
#import <AFOAuth2Client/AFOAuth2Client.h>

#import "LVCredentialTextLayer.h"
#import "LVLogoLayer.h"
#import "LVConfiguration.h"
#import "LVTraverser.h"

static void *LVScreensaverViewContext = &LVScreensaverViewContext;

@interface LVScreensaverView ()  <LVTraverserDelegate, LVImageDelegate>
@property (weak) IBOutlet NSTextField *emailField;
@property (weak) IBOutlet NSTextField *passwordField;
@property (weak) IBOutlet NSButton *loginButton;
@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (nonatomic, readonly) LVCAuthenticatedClient *client;
@property (nonatomic, readonly) LVTraverser *traverser;
@property (nonatomic, readonly) LVCredentialTextLayer *credentialTextLayer;
@end

@implementation LVScreensaverView

static NSString * const MyModuleName = @"com.layervault.LVScreensaver";
static NSTimeInterval const FRAMES_PER_SECOND = 30.0;
static NSString * const CLIENT_KEY = @"YOUR_CLIENT_KEY";
static NSString * const CLIENT_SECRET = @"YOUR_CLIENT_SECRET";
static NSInteger const MAX_IMAGES = 20;

+ (NSDate *)thresholdDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *lastWeekComponents = [[NSDateComponents alloc] init];
    NSDate *today = [NSDate date];
    [lastWeekComponents setWeek:-1];
    return [calendar dateByAddingComponents:lastWeekComponents toDate:today options:0];
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        _client = [[LVCAuthenticatedClient alloc] initWithClientID:CLIENT_KEY
                                                            secret:CLIENT_SECRET];

        [_client addObserver:self
                  forKeyPath:@"user"
                     options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                     context:LVScreensaverViewContext];
        [_client addObserver:self
                  forKeyPath:@"authenticationState"
                     options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                     context:LVScreensaverViewContext];

        __weak typeof(self) wSelf = self;
        _client.authenticationCallback = ^(LVCUser *user, NSError *error) {
            __strong typeof(wSelf) sSelf = wSelf;
            [sSelf removeCredentialsLayer];
            [sSelf.traverser fetchImagesNewerThan:[LVScreensaverView thresholdDate]];
        };

        _traverser = [[LVTraverser alloc] initWithClient:self.client
                                               andWidth:[self bounds].size.width
                                              andHeight:[self bounds].size.height];
        _traverser.delegate = self;

        AFOAuthCredential *cred = [AFOAuthCredential retrieveCredentialWithIdentifier:_client.serviceProviderIdentifier];
        if (cred) {
            [_client loginWithCredential:cred];
        }

        _imageURLs = [[NSMutableOrderedSet alloc] init];
        config = [[LVConfiguration alloc] init];
        [self setWantsLayer:YES];
        [self.layer setBackgroundColor:[[NSColor blackColor] CGColor]];
        [self setAnimationTimeInterval:1/FRAMES_PER_SECOND];

        _credentialTextLayer = [[LVCredentialTextLayer alloc] initWithView:self];

        [self start];
    }
    
    return self;
}


- (void)dealloc
{
    [_client removeObserver:self
                 forKeyPath:@"user"
                    context:LVScreensaverViewContext];
    [_client removeObserver:self
                 forKeyPath:@"authenticationState"
                    context:LVScreensaverViewContext];
}

- (void)addImageURL:(NSURL *)url
{
    @synchronized(_imageURLs) {
        if (url) {
            [_imageURLs addObject:url];
            [animator imageAdded:url];

            // If some new images have come in, force the "oldest" one out.
            // It won't get displayed immediately, but it will get displayed eventually.
            if ([_imageURLs count] > MAX_IMAGES) {
                [_imageURLs removeObjectAtIndex:0];
            }
        }
    }
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
    if (!configSheet) {
        if (![NSBundle loadNibNamed:@"ConfigureSheet" owner:self]) {
            NSLog( @"Failed to load configure sheet.");
            NSBeep();
        }
    }

    [self updateSheetState];

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

- (IBAction)loginPressed:(NSButton *)sender {
    if (self.client.authenticationState == LVCAuthenticationStateAuthenticated) {
        NSLog(@"logout called");
        [self.client logout];
        self.emailField.stringValue = @"";
        self.passwordField.stringValue = @"";
        [self.emailField becomeFirstResponder];
    }
    else if (self.client.authenticationState == LVCAuthenticationStateUnauthenticated) {
        self.layer.sublayers = nil;
        [self.layer setNeedsDisplay];

        if (riverMode.state)
            [config setRiverMode];
        else if (slideshowMode.state)
            [config setSlideshowMode];

        [self stop];
        [self.client loginWithEmail:self.emailField.stringValue
                           password:self.passwordField.stringValue];
    }
}

- (IBAction)okClick:(id)sender
{
    [[NSApplication sharedApplication] endSheet:configSheet];
}


- (void)start
{
    [self.layer addSublayer: [[LVLogoLayer alloc] initWithView:self]];

    if (self.client.authenticationState == LVCAuthenticationStateUnauthenticated) {
        [self.layer addSublayer:self.credentialTextLayer];
    }

    [self setupAnimator];
}

- (void)stop
{
    self.layer.sublayers = nil;
    animator.delegate = nil;
    animator = nil;
}

- (NSSet *)imageURLs
{
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

- (void)removeCredentialsLayer
{
    [self.credentialTextLayer fadeOut:nil];
}


- (void)updateSheetState
{
    if (self.client.authenticationState == LVCAuthenticationStateAuthenticating) {
        [self.spinner startAnimation:nil];
    }
    else {
        [self.spinner stopAnimation:nil];
    }
    self.emailField.stringValue = self.client.user.email ?: @"";
    self.passwordField.stringValue = self.client.authenticationState == LVCAuthenticationStateUnauthenticated ? @"" : @"TEMPORARYPASSWORD";
    switch (self.client.authenticationState) {
        case LVCAuthenticationStateUnauthenticated:
            self.loginButton.title = @"Login";
            [self.loginButton setEnabled:YES];
            [self.emailField setEnabled:YES];
            [self.passwordField setEnabled:YES];
            break;
        case LVCAuthenticationStateAuthenticating:
            self.loginButton.title = @"Logging In";
            [self.loginButton setEnabled:NO];
            [self.emailField setEnabled:NO];
            [self.passwordField setEnabled:NO];
            break;
        case LVCAuthenticationStateAuthenticated:
            self.loginButton.title = @"Logout";
            [self.loginButton setEnabled:YES];
            [self.emailField setEnabled:NO];
            [self.passwordField setEnabled:NO];
            break;
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == LVScreensaverViewContext) {
        [self updateSheetState];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
