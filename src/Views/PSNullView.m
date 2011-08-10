//
//  PSNullView.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 4/9/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSNullView.h"

@interface PSNullView (Private)

- (void)setupLoadingView;
- (void)setupEmptyView;

@end

@implementation PSNullView

@synthesize state = _state;
@synthesize loadingView = _loadingView;
@synthesize emptyView = _emptyView;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {    
    _state = PSNullViewStateDisabled;
    
    _loadingView = [[UIView alloc] initWithFrame:self.bounds];
    _loadingView.autoresizingMask = self.autoresizingMask;
    
    _emptyView = [[UIView alloc] initWithFrame:self.bounds];
    _emptyView.autoresizingMask = self.autoresizingMask;
    
    [self addSubview:_loadingView];
    [self addSubview:_emptyView];
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
}

#pragma mark - State
- (void)setState:(PSNullViewState)state
{
  _state = state;
  
  switch (state) {
    case PSNullViewStateDisabled:
      _emptyView.alpha = 0.0;
      _loadingView.alpha = 0.0;
      [self hideNullView];
      break;
    case PSNullViewStateEmpty:
      _emptyView.alpha = 1.0;
      _loadingView.alpha = 0.0;
      [self showNullView];
      break;
    case PSNullViewStateLoading:
      _loadingView.alpha = 1.0;
      _emptyView.alpha = 0.0;
      [self showNullView];
      break;
    default:
      _emptyView.alpha = 0.0;
      _loadingView.alpha = 0.0;
      [self hideNullView];
      break;
  }
}

#pragma mark Loading
- (void)showNullView {
  //  [UIView beginAnimations:nil context:NULL];
  //  [UIView setAnimationDuration:0.3];
  self.alpha = 1.0;
  //  [UIView commitAnimations];
}

- (void)hideNullView {
  //  [UIView beginAnimations:nil context:NULL];
  //  [UIView setAnimationDuration:0.3];
  self.alpha = 0.0;
  //  [UIView commitAnimations];
}

- (void)dealloc {
  RELEASE_SAFELY(_loadingView);
  RELEASE_SAFELY(_emptyView);
  [super dealloc];
}

@end
