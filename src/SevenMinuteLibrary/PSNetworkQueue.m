//
//  PSNetworkQueue.m
//  PSNetworkStack
//
//  Created by Peter Shih on 1/27/11.
//  Copyright 2011 Seven Minute Apps. All rights reserved.
//

#import "PSNetworkQueue.h"
#import "PSNetworkOperation.h"

@implementation PSNetworkQueue

- (id)init {
  self = [super init];
  if (self) {
    [self setMaxConcurrentOperationCount:4];
    [self setSuspended:NO];
  }
	return self;
}

- (void)cancelAllOperations {
  for (PSNetworkOperation *op in [self operations]) {
    [op clearDelegatesAndCancel];
  }
}

+ (PSNetworkQueue *)sharedQueue {
  static PSNetworkQueue *sharedQueue = nil;
  @synchronized(self) {
    if (sharedQueue == nil) {
      sharedQueue = [[self alloc] init];
    }
    return sharedQueue;
  }
}

@end
