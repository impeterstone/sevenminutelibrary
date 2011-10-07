//
//  PSCoreDataImageCache.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 5/19/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

/**
 THIS CLASS IS DEPRECATED, DO NOT USE
 */

#import <Foundation/Foundation.h>
#import "PSObject.h"
#import "PSCoreDataStack.h"

@class ASIHTTPRequest;

@interface PSCoreDataImageCache : PSObject {
  NSMutableArray *_pendingRequests;
}

+ (id)sharedCache;

- (void)cacheImageWithURLPath:(NSString *)URLPath forEntity:(id)entity;
- (void)cacheImageWithURLPath:(NSString *)URLPath forEntity:(id)entity scaledSize:(CGSize)scaledSize;

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request withError:(NSError *)error;

@end
