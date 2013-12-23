//
//  LVTraverser.m
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/21/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import "LVTraverser.h"

#import <LayerVaultAPI.h>

@implementation LVTraverser

@synthesize delegate;

- (id)initWithClient:(LVCHTTPClient *)aClient andWidth:(CGFloat)aWidth andHeight:(CGFloat)aHeight
{
    self = [super init];

    if (self) {
        client = aClient;
        width = aWidth;
        height = aHeight;
    }

    return self;
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

    [client getPreviewURLsForFile:file width:width height:height completion:^(NSArray *previewURLs, NSError *error, AFHTTPRequestOperation *operation) {
        if (self.delegate)
            [self.delegate addImageURL:[previewURLs objectAtIndex:([previewURLs count] - 1)]];
    }];
}

@end
