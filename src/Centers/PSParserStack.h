//
//  PSParserStack.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 5/21/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSParserStack : NSObject {
  NSOperationQueue *_parserQueue;
}

+ (id)sharedParser;
- (void)addOperation:(NSOperation *)op;

@end
