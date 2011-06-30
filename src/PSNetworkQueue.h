//
//  PSNetworkQueue.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 1/27/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Constants.h"

@interface PSNetworkQueue : ASINetworkQueue {
  NSMutableDictionary *_pendingRequests;
}

// Access shared instance
+ (PSNetworkQueue *)sharedQueue;

@end
