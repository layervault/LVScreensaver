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

static NSTimeInterval const POLL_INTERVAL = 30.0;

- (id)initWithClient:(LVCHTTPClient *)aClient andWidth:(CGFloat)aWidth andHeight:(CGFloat)aHeight
{
    self = [super init];

    if (self) {
        client = aClient;
        width = aWidth;
        height = aHeight;
        projectNames = [NSMutableSet set];
    }

    return self;
}

- (void)fetchImagesNewerThan:(NSDate *)date
{
    [client getMeWithCompletion:^(LVCUser *user,
                                  NSError *error,
                                  AFHTTPRequestOperation *operation) {

        for (LVCProject *project in user.projects) {
            [projectNames addObject:@[project.name, project.organizationPermalink]];
        }

        for (NSArray *project in projectNames) {
            [self descendIntoProject:project newerThan:date];
        }

        NSDate *currentTime = [NSDate date];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, POLL_INTERVAL * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self fetchImagesNewerThan:currentTime];
        });
    }];
}

- (void)descendIntoProject:(NSArray *)projectArray newerThan:(NSDate *)date
{
    LVCProject *project = [[LVCProject alloc] initWithName:projectArray.firstObject
                                     organizationPermalink:projectArray.lastObject];

    // So this is a significantly more expensive way to collect this information, since we have to issue a
    // new request for every project. This is because the /me endpoint returns stale project data. Once
    // that issue is remedied, we can get smarter about how we query this.
    [client getProjectFromPartial:project completion:^(LVCProject *project, NSError *error, AFHTTPRequestOperation *operation) {
        if ([project.dateUpdated compare:date] != NSOrderedDescending)
            return;

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
        if (self.delegate && [previewURLs count])
            [self.delegate addImageURL:[previewURLs objectAtIndex:([previewURLs count] - 1)]];
    }];
}

@end
