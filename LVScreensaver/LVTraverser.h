//
//  LVTraverser.h
//  LVScreensaver
//
//  Created by Kelly Sutton on 12/21/13.
//  Copyright (c) 2013 LayerVault. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LVCHTTPClient;

@protocol TraverserDelegate <NSObject>
@required
- (void)addImageURL:(NSURL *)url;
@end

@interface LVTraverser : NSObject {
    LVCHTTPClient *client;
    CGFloat width;
    CGFloat height;
}

@property (nonatomic, weak) id <TraverserDelegate> delegate;

- (id)initWithClient:(LVCHTTPClient *)aClient andWidth:(CGFloat)aWidth andHeight:(CGFloat)aHeight;
- (void)fetchImagesNewerThan:(NSDate *)date;

@end
