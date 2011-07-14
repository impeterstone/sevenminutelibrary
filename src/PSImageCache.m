//
//  PSImageCache.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSImageCache.h"
#import "NSString+SML.h"
#import "ASIHTTPRequest.h"
#import "PSNetworkQueue.h"

@implementation PSImageCache

@synthesize cachePath = _cachePath;

+ (PSImageCache *)sharedCache {
  static PSImageCache *sharedCache;
  if (!sharedCache) {
    sharedCache = [[self alloc] init];
  }
  return sharedCache;
}

- (id)init {
  self = [super init];
  if (self) {
    _buffer = [[NSCache alloc] init];
    [_buffer setName:@"PSImageCache"];
    [_buffer setDelegate:self];
    
    _requestQueue = [[PSNetworkQueue alloc] init];
    _pendingRequests = [[NSMutableDictionary alloc] init];
    
    // Set to NSDocumentDirectory by default
    [self setupCachePathWithCacheDirectory:NSDocumentDirectory];
  }
  return self;
}

- (void)setupCachePathWithCacheDirectory:(NSSearchPathDirectory)cacheDirectory {
  self.cachePath = [[NSSearchPathForDirectoriesInDomains(cacheDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"psimagecache"];
  
  BOOL isDir = NO;
  NSError *error;
  if (![[NSFileManager defaultManager] fileExistsAtPath:_cachePath isDirectory:&isDir] && isDir == NO) {
    [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath withIntermediateDirectories:NO attributes:nil error:&error];
  }
}

#pragma mark Setter/Getter for cacheDirectory
- (void)setCacheDirectory:(NSSearchPathDirectory)cacheDirectory {
  _cacheDirectory = cacheDirectory;
  
  // Change the cachePath to use the new directory
  [self setupCachePathWithCacheDirectory:cacheDirectory];
}

- (NSSearchPathDirectory)cacheDirectory {
  return _cacheDirectory;
}

- (void)dealloc {
  RELEASE_SAFELY(_buffer);
  RELEASE_SAFELY(_cachePath);
  RELEASE_SAFELY(_pendingRequests);
  RELEASE_SAFELY(_requestQueue);
  [super dealloc];
}

// Cache Image Data
- (void)cacheImage:(NSData *)imageData forURLPath:(NSString *)urlPath {
  if (imageData) {
    UIImage *image = [UIImage imageWithData:imageData];
    if (image) {
      // First put it in the NSCache buffer
      [_buffer setObject:[UIImage imageWithData:imageData] forKey:[urlPath stringByURLEncoding]];
      
      // Also write it to file
      [imageData writeToFile:[_cachePath stringByAppendingPathComponent:[urlPath stringByURLEncoding]] atomically:YES];
    }
    
    VLog(@"PSImageCache CACHE: %@", urlPath);
  }
}

// Read Cached Image
- (UIImage *)imageForURLPath:(NSString *)urlPath shouldDownload:(BOOL)shouldDownload withDelegate:(id)delegate {
  if (!urlPath) return nil;
  
  // First check NSCache buffer
  //  NSData *imageData = [_buffer objectForKey:[urlPath stringByURLEncoding]];
  UIImage *image = [_buffer objectForKey:[urlPath stringByURLEncoding]];
  if (image) {
    // Image exists in buffer
    VLog(@"PSImageCache CACHE HIT: %@", urlPath);
    return image;
  } else {
    // Image not in buffer, read from disk instead
    VLog(@"PSImageCache CACHE MISS: %@", urlPath);
    image = [UIImage imageWithContentsOfFile:[_cachePath stringByAppendingPathComponent:[urlPath stringByURLEncoding]]];
    
    // If Image is in disk, read it
    if (image) {
      VLog(@"PSImageCache DISK HIT: %@", urlPath);
      // Put this image into the buffer also
      [_buffer setObject:image forKey:[urlPath stringByURLEncoding]];
      return image;
    } else {
      VLog(@"PSImageCache DISK MISS: %@", urlPath);
      if (shouldDownload) {
        // Download the image data from the source URL
        [self downloadImageForURLPath:urlPath withDelegate:delegate];
      }
      return nil;
    }
  }
}

- (BOOL)hasImageForURLPath:(NSString *)urlPath {
  if ([_buffer objectForKey:[urlPath stringByURLEncoding]]) {
    // Image exists in memcache
    return YES;
  } else {
    // Check disk for image
    return [[NSFileManager defaultManager] fileExistsAtPath:[_cachePath stringByAppendingPathComponent:[urlPath stringByURLEncoding]]];
  }
}

- (void)cacheImageForURLPath:(NSString *)urlPath withDelegate:(id)delegate {
  if (![self hasImageForURLPath:urlPath]) {
    [self downloadImageForURLPath:urlPath withDelegate:delegate];
  }
}

#pragma mark Remote Image Load Request
- (void)downloadImageForURLPath:(NSString *)urlPath withDelegate:(id)delegate {
  // Check to make sure urlPath is not in a pendingRequest already
  if ([_pendingRequests objectForKey:urlPath]) return;
  
  __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlPath]];
  request.requestMethod = @"GET";
  request.allowCompressedResponse = YES;
  
  // Request Completion Block
  [request setCompletionBlock:^{
    [self downloadImageRequestFinished:request withDelegate:delegate];
    // Remove request from pendingRequests
    [_pendingRequests removeObjectForKey:[[request originalURL] absoluteString]];
  }];
  [request setFailedBlock:^{
    [self downloadImageRequestFailed:request withDelegate:delegate];
    
    // Remove request from pendingRequests
    [_pendingRequests removeObjectForKey:[[request originalURL] absoluteString]];
  }];
  
  // Start the Request
  [_pendingRequests setObject:request forKey:urlPath];
  [_requestQueue addOperation:request];
}

- (void)downloadImageRequestFinished:(ASIHTTPRequest *)request withDelegate:(id)delegate {
  NSString *urlPath = [[request originalURL] absoluteString];
  
  if ([request responseData]) {
    [self cacheImage:[request responseData] forURLPath:urlPath];
    // Notify delegate
//    if (delegate && [delegate respondsToSelector:@selector(imageCacheDidLoad:forURLPath:)]) {
//      [delegate performSelector:@selector(imageCacheDidLoad:forURLPath:) withObject:[request responseData] withObject:urlPath];
//    }
    
    // fire notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kPSImageCacheDidCacheImage object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[request responseData], @"imageData", urlPath, @"urlPath", nil]];
  } else {
    // something bad happened
  }
}

- (void)downloadImageRequestFailed:(ASIHTTPRequest *)request withDelegate:(id)delegate {
  // something bad happened
}

#pragma mark NSCacheDelegate
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
  VLog(@"NSCache evicting object");
}
   
#pragma mark Helpers
+ (NSString *)documentDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)cachesDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

@end