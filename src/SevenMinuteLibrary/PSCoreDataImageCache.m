//
//  PSCoreDataImageCache.m
//  PhotoFeed
//
//  Created by Peter Shih on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCoreDataImageCache.h"
#import "ASIHTTPRequest.h"
#import "UIImage+SML.h"

@implementation PSCoreDataImageCache

+ (PSCoreDataImageCache *)sharedCache {
  static PSCoreDataImageCache *sharedCache;
  if (!sharedCache) {
    sharedCache = [[self alloc] init];
  }
  return sharedCache;
}

- (id)init {
  self = [super init];
  if (self) {
    _pendingRequests = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)cacheImageWithURLPath:(NSString *)URLPath forEntity:(id)entity {
  [self cacheImageWithURLPath:URLPath forEntity:entity scaledSize:CGSizeZero];
}

- (void)cacheImageWithURLPath:(NSString *)URLPath forEntity:(id)entity scaledSize:(CGSize)scaledSize {
  // Fire the request
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:URLPath]];
  
  request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:entity, @"entity", NSStringFromCGSize(scaledSize), @"scaledSize", nil];
  
  // Request Completion Block
  [request setCompletionBlock:^{
    [self requestFinished:request];
  }];
  
  // Request Failed Block
  [request setFailedBlock:^{
    NSError *error = [request error];
    [self requestFailed:request withError:error];
  }];
  
  // Start the Request
  [request startAsynchronous];
  
  [_pendingRequests addObject:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
  id entity = [request.userInfo objectForKey:@"entity"];
  if ([entity respondsToSelector:@selector(imageData)]) {
    NSData *imageData = nil;
    CGSize desiredSize = CGSizeFromString([request.userInfo valueForKey:@"scaledSize"]);
    if (!CGSizeEqualToSize(desiredSize, CGSizeZero)) {
      // We need to scale the image
      UIImage *scaledImage = [[UIImage imageWithData:[request responseData]] cropProportionalToSize:desiredSize withRuleOfThirds:YES];
      imageData = UIImageJPEGRepresentation(scaledImage, 1.0);
    } else {
      imageData = [request responseData];
    }
    [entity performSelector:@selector(setImageData:) withObject:imageData];
    [PSCoreDataStack saveInContext:[(NSManagedObject *)entity managedObjectContext]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kImageCached object:nil userInfo:request.userInfo];
  }
  
  [_pendingRequests removeObject:request];
}

- (void)requestFailed:(ASIHTTPRequest *)request withError:(NSError *)error {
  [_pendingRequests removeObject:request];
}

@end
