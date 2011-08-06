//
//  PSSearchCenter.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 7/12/11.
//  Copyright 2011 Seven Minute Labs, Inc.. All rights reserved.
//

#import "PSSearchCenter.h"

static NSString *_savedPath = nil;

@implementation PSSearchCenter

+ (PSSearchCenter *)defaultCenter {
  static PSSearchCenter *defaultCenter = nil;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

+ (void)initialize {
  _savedPath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"pssearchcenter.plist"] retain];
}

- (id)init {
  self = [super init];
  if (self) {
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_savedPath];
    if (fileExists) {
      NSError *error = nil;
      NSData *termsData = [NSData dataWithContentsOfFile:_savedPath];
      _terms = [[NSMutableDictionary dictionaryWithDictionary:[NSPropertyListSerialization propertyListWithData:termsData options:0 format:NULL error:&error]] retain];
    } else {
      _terms = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_terms);
  [super dealloc];
}

#pragma mark - Terms
- (NSArray *)searchResultsForTerm:(NSString *)term {
  NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] %@", term];
  NSArray *sortedKeys = [_terms keysSortedByValueUsingComparator:^(id obj1, id obj2) {
    // DESCENDING
    if ([obj1 integerValue] < [obj2 integerValue]) {
      return (NSComparisonResult)NSOrderedDescending;
    } else if ([obj1 integerValue] > [obj2 integerValue]) {
      return (NSComparisonResult)NSOrderedAscending;
    } else {
      return (NSComparisonResult)NSOrderedSame;
    }
  }];
  
  return [sortedKeys filteredArrayUsingPredicate:searchPredicate];
}

- (NSDictionary *)sessionTerms {
  return [NSDictionary dictionaryWithDictionary:_terms];
}

- (NSDictionary *)savedTerms {
  return [NSDictionary dictionaryWithDictionary:_terms];
}

- (BOOL)addTerm:(NSString *)term {
  id val = nil;
  val = [_terms objectForKey:term];
  if (val) {
    NSUInteger count = [val integerValue] + 1;
    [_terms setObject:[NSNumber numberWithInteger:count] forKey:term];
  } else {
    [_terms setObject:[NSNumber numberWithInteger:1] forKey:term];
  }
  
  // Write to disk
  NSError *error = nil;
  NSData *termsData = [NSPropertyListSerialization dataWithPropertyList:_terms format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
  
  return [termsData writeToFile:_savedPath atomically:YES];
}

@end
