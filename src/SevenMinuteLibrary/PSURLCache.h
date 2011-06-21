//
//  PSURLCache.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PSURLCache : NSObject {
}

+ (PSURLCache *)sharedCache;

- (NSDictionary *)cacheResponse:(NSDictionary *)responseDict forURLPath:(NSString *)urlPath shouldMerge:(BOOL)shouldMerge;
- (NSDictionary *)responseForURLPath:(NSString *)urlPath;
- (NSDictionary *)mergeResponse:(NSDictionary *)oldResponse withResponse:(NSDictionary *)newResponse;

// Convenience Methods
+ (NSString *)filePathForURLPath:(NSString *)urlPath;
+ (NSString *)applicationDocumentsDirectory;

@end
