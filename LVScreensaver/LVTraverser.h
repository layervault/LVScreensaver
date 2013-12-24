//
//  LVTraverser.h
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/21/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LVCHTTPClient;

@protocol LVTraverserDelegate <NSObject>
@required
- (void)addImageURL:(NSURL *)url;
@end

@interface LVTraverser : NSObject {
    LVCHTTPClient *client;
    CGFloat width;
    CGFloat height;
    NSMutableSet *projectNames;
}

@property (nonatomic, weak) id <LVTraverserDelegate> delegate;

- (id)initWithClient:(LVCHTTPClient *)aClient andWidth:(CGFloat)aWidth andHeight:(CGFloat)aHeight;
- (void)fetchImagesNewerThan:(NSDate *)date;

@end
