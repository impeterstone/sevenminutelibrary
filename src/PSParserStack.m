//
//  PSParserStack.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 5/21/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSParserStack.h"

@implementation PSParserStack

#pragma mark Shared Parser Instance
+ (PSParserStack *)sharedParser {
  static PSParserStack *sharedParser = nil;
  if (!sharedParser) {
    sharedParser = [[self alloc] init];
  }
  return sharedParser;
}

- (id)init {
  self = [super init];
  if (self) {
    _parserQueue = [[NSOperationQueue alloc] init];
    [_parserQueue setMaxConcurrentOperationCount:10];
  }
  return self;
}

#pragma mark -
#pragma mark NSOperationQueue Actions
- (void)addOperation:(NSOperation *)op {
  [_parserQueue addOperation:op];
}

@end
