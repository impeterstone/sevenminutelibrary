//
//  PSImageArrayView.h
//  PhotoFeed
//
//  Created by Peter Shih on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "ASIHTTPRequest.h"

@interface PSImageArrayView : UIImageView {
  NSArray *_urlPathArray;
  NSMutableDictionary *_images;
  NSMutableArray *_pendingRequests;
  UIActivityIndicatorView *_loadingIndicator;
  NSTimer *_animateTimer;
  
  BOOL _shouldScale;
  NSInteger _animateIndex;
}

@property (nonatomic, retain) NSArray *urlPathArray;
@property (nonatomic, assign) BOOL shouldScale;

- (void)getImageRequestWithUrlPath:(NSString *)urlPath;
- (void)loadImageArray;
- (void)animateImages;

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request withError:(NSError *)error;

- (void)prepareImageArray;
- (void)checkAndResetImageArray;

@end
