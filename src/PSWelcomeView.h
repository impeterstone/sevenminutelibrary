//
//  PSWelcomeView.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 7/13/11.
//  Copyright 2011 Seven Minute Labs, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSView.h"

@interface PSWelcomeView : PSView <UIScrollViewDelegate> {
  UIScrollView *_scrollView;
  NSUInteger _currentPage;
  NSArray *_viewArray;
}

@property (nonatomic, retain) NSArray *viewArray;
@property (nonatomic, readonly) NSUInteger currentPage;

- (void)scrollToPage:(NSUInteger)page animated:(BOOL)animated;
- (void)next;
- (void)prev;

- (NSUInteger)numPages;

@end
