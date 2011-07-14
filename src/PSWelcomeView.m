//
//  PSWelcomeView.m
//  Moogle
//
//  Created by Peter Shih on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSWelcomeView.h"

@implementation PSWelcomeView

@synthesize viewArray = _viewArray;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - 38)];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.height - 38, self.width, 38)];
    
    _scrollView.scrollsToTop = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    
    _pageControl.numberOfPages = 1;
    _pageControl.hidesForSinglePage = YES;
    
    [self addSubview:_scrollView];
    [self addSubview:_pageControl];
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_viewArray);
  RELEASE_SAFELY(_scrollView);
  RELEASE_SAFELY(_pageControl);
  [super dealloc];
}

#pragma mark - Layout
- (void)layoutSubviews {
  [super layoutSubviews];
  
}

#pragma mark - Configure
- (void)setViewArray:(NSArray *)viewArray {
  [_viewArray autorelease];
  _viewArray = [viewArray retain];

  NSUInteger viewCount = [viewArray count];
  [_scrollView removeSubviews];
  
  int i = 0;
  for (UIView *view in viewArray) {
//    view.height -= 38;
    view.left = i * view.width;
    [_scrollView addSubview:view];
    i++;
  }
  _scrollView.contentOffset = CGPointZero;
  _scrollView.contentSize = CGSizeMake(_scrollView.width * viewCount, _scrollView.height);
  _pageControl.numberOfPages = viewCount;
  _pageControl.currentPage = 0;
  
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // Switch the indicator when more than 50% of the previous/next page is visible
  CGFloat pageWidth = scrollView.width;
  int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  _pageControl.currentPage = page;
}

@end
