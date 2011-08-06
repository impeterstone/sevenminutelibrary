//
//  PSCoreDataImageCache.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 5/19/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSObject.h"
#import "PSCoreDataStack.h"

@interface PSCoreDataImageCache : PSObject {
  NSMutableArray *_pendingRequests;
}

+ (PSCoreDataImageCache *)sharedCache;

- (void)cacheImageWithURLPath:(NSString *)URLPath forEntity:(id)entity;
- (void)cacheImageWithURLPath:(NSString *)URLPath forEntity:(id)entity scaledSize:(CGSize)scaledSize;

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request withError:(NSError *)error;

@end
