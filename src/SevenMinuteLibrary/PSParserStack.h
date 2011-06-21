//
//  PSParserStack.h
//  PhotoFeed
//
//  Created by Peter Shih on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSParserStack : NSObject {
  NSOperationQueue *_parserQueue;
}

+ (PSParserStack *)sharedParser;
- (void)addOperation:(NSOperation *)op;

@end
