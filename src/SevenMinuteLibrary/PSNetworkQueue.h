//
//  PSNetworkQueue.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 1/27/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PSNetworkQueue : NSOperationQueue {
}

// Access shared instance
+ (PSNetworkQueue *)sharedQueue;

// This will tell each PSNetworkOperation to clear delegates and cancel operation
- (void)cancelAllOperations;

@end
