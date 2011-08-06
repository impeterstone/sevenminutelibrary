//
//  PSViewController.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 3/16/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSViewController.h"

@implementation PSViewController

- (id)init {
  self = [super init];
  if (self) {
    DLog(@"Called by class: %@", [self class]);
  }
  return self;
}

- (void)loadView {
  [super loadView];
  self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (void)dealloc {
  DLog(@"Called by class: %@", [self class]);
  [super dealloc];
}

@end
