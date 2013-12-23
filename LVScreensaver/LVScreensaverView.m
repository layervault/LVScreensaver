//
//  LVScreensaverView.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/21/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVScreensaverView.h"

#import <LayerVaultAPI.h>
#import <QuartzCore/QuartzCore.h>

#import "NSImage+ProportionalScaling.h"
#import "NSImage+BitmapRepresentation.h"

@implementation LVScreensaverView

static NSString * const MyModuleName = @"com.layervault.LVScreensaver";
static NSTimeInterval const FRAMES_PER_SECOND = 30.0;
static NSTimeInterval const SECONDS_PER_DESIGN = 10.0;
static NSTimeInterval const BLANK_SECONDS = 1.0;
static NSTimeInterval const FADE_IN_SECONDS = 1.0;
static NSString * const CLIENT_KEY = @"YOUR_CLIENT_KEY";
static NSString * const CLIENT_SECRET = @"YOUR_CLIENT_SECRET";

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *lastWeekComponents = [[NSDateComponents alloc] init];
        NSDate *today = [NSDate date];
        [lastWeekComponents setWeek:-1];
        thresholdDate = [calendar dateByAddingComponents:lastWeekComponents toDate:today options:0];

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

        [self setWantsLayer:YES];
        [self.layer setBackgroundColor:[[NSColor blackColor] CGColor]];
        [self setAnimationTimeInterval:1/FRAMES_PER_SECOND];

        NSString *defaultImageName = isPreview ? @"Small-Logo" : @"Logo";
        imageURLs = [NSMutableSet setWithObjects:[[NSBundle bundleForClass:[self class]] URLForImageResource:defaultImageName], nil];
        [self addedImage];
    }
    return self;
}

- (void)addImageURL:(NSURL *)url
{
    [imageURLs addObject:url];
    [self addedImage];
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
                               [traverser fetchImagesNewerThan:thresholdDate];
                           }

                          [[NSApplication sharedApplication] endSheet:configSheet];
                       }
     ];
}

- (void)addedImage
{
    if (self.layer.sublayers.count)
        return;

    NSURL *url = [self randomImageURL];

    if (!url)
        return;

    NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
    CALayer *imageLayer = [self sublayerWithImage:image];
    [self.layer addSublayer:imageLayer];
    [self.layer setNeedsDisplay];

    // Don't cycle images if we only have the starting image.
    if ([imageURLs count] > 1)
        [imageLayer addAnimation:[self fadeInFadeOut] forKey:@"animationGroup"];
    else
        imageLayer.opacity = 1.0;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    self.layer.sublayers = nil;
    [self addedImage];
}

- (NSURL *)randomImageURL
{
    NSUInteger myCount = [imageURLs count];
    if (myCount)
        return [[imageURLs allObjects] objectAtIndex:arc4random_uniform(myCount)];
    else
        return nil;
}

- (CAAnimationGroup *)fadeInFadeOut
{
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = @0.0;
    fadeInAnimation.toValue = @1.0;
    fadeInAnimation.duration = FADE_IN_SECONDS;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode = kCAFillModeForwards;

    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.fromValue = @1.0;
    fadeOutAnimation.toValue = @0.0;
    fadeOutAnimation.duration = FADE_IN_SECONDS;
    fadeOutAnimation.removedOnCompletion = NO;
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.beginTime = SECONDS_PER_DESIGN - FADE_IN_SECONDS;

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = SECONDS_PER_DESIGN;
    group.animations = @[fadeInAnimation, fadeOutAnimation];
    group.delegate = self;

    return group;
}

- (CALayer *)sublayerWithImage:(NSImage *)image
{
    CGImageRef ref = [[image bitmapImageRepresentation] CGImage];
    CALayer *imageLayer = [[CALayer alloc] init];
    NSSize containerSize = self.layer.bounds.size;

    imageLayer.bounds = NSMakeRect(0, 0, image.size.width, image.size.height);
    imageLayer.position = NSMakePoint((containerSize.width - image.size.width) / 2.0, (containerSize.height - image.size.height) / 2.0);
    imageLayer.contents = (__bridge id)(ref);
    imageLayer.opacity = 0.0;
    imageLayer.anchorPoint = NSZeroPoint;

    return imageLayer;
}


@end
