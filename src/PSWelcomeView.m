//
//  PSWelcomeView.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 7/13/11.
//  Copyright 2011 Seven Minute Labs, Inc.. All rights reserved.
//

#import "PSWelcomeView.h"

@interface PSWelcomeView (Private)

@end

@implementation PSWelcomeView

@synthesize viewArray = _viewArray;
@synthesize currentPage = _currentPage;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _currentPage = 0;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    
    _scrollView.scrollsToTop = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollEnabled = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
      _scrollView.delegate = self;
    
    [self addSubview:_scrollView];
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_viewArray);
  RELEASE_SAFELY(_scrollView);
  [super dealloc];
}

#pragma mark - Layout
- (void)layoutSubviews {
  [super layoutSubviews];
  
}

#pragma mark - Scroll
- (void)scrollToPage:(NSUInteger)page animated:(BOOL)animated {
  [_scrollView scrollRectToVisible:[[_viewArray objectAtIndex:page] frame] animated:animated];
  _currentPage = page;
}

- (void)next {
  if (_currentPage == [_viewArray count] - 1) return;
  
  [self scrollToPage:(_currentPage + 1) animated:YES];
}

- (void)prev {
  if (_currentPage == 0) return;
  
  [self scrollToPage:(_currentPage - 1) animated:YES];
}

#pragma mark - Configure
- (void)setViewArray:(NSArray *)viewArray {
  [_viewArray autorelease];
  _viewArray = [viewArray retain];

  NSUInteger viewCount = [viewArray count];
  [_scrollView removeSubviews];
  
  int i = 0;
  for (UIView *view in viewArray) {
//    view.layer.cornerRadius = 10;
//    view.layer.masksToBounds = YES;
    view.top = 0;
    view.left = (i * view.width);
    [_scrollView addSubview:view];
    i++;
  }
  _scrollView.contentOffset = CGPointZero;
  _scrollView.contentSize = CGSizeMake(_scrollView.width * viewCount, _scrollView.height);
  
}

- (NSUInteger)numPages {
  return [_viewArray count];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // Switch the indicator when more than 50% of the previous/next page is visible
  CGFloat pageWidth = scrollView.width;
  int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  
  _currentPage = page;
}

@end
