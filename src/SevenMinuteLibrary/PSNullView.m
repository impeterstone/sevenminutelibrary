//
//  PSNullView.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 4/9/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSNullView.h"

static UIImage *_emptyImage = nil;
static UIImage *_loadingImage = nil;

@implementation PSNullView

@synthesize state = _state;

+ (void)initialize {
//  _emptyImage = [[UIImage imageNamed:@"bamboo_bg.png"] retain];
//  _loadingImage = [[UIImage imageNamed:@"bamboo_bg_alpha.png"] retain];
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor colorWithPatternImage:_emptyImage];
    
    _state = PSNullViewStateDisabled;
    
    [self setupEmptyView];
    [self setupLoadingView];
  }
  return self;
}

- (void)setupLoadingView {
  _loadingView = [[UIView alloc] initWithFrame:self.bounds];
  _loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//  _loadingView.backgroundColor = [UIColor colorWithPatternImage:_loadingImage];
  
  UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  [loadingIndicator startAnimating];
  loadingIndicator.center = _loadingView.center;
  loadingIndicator.top = 180.0;
  [_loadingView addSubview:loadingIndicator];
  
  UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  loadingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  loadingLabel.backgroundColor = [UIColor clearColor];
  loadingLabel.text = @"Loading...";
  loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
  loadingLabel.textColor = [UIColor whiteColor];
  [loadingLabel sizeToFit];
  loadingLabel.center = _loadingView.center;
  loadingLabel.top = loadingIndicator.bottom + 5.0;
  [_loadingView addSubview:loadingLabel];
  
  [loadingIndicator release];
  [loadingLabel release];
}

- (void)setupEmptyView {
  _emptyView = [[UIView alloc] initWithFrame:self.bounds];
  _emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//  _emptyView.backgroundColor = [UIColor colorWithPatternImage:_emptyImage];
}

- (void)setState:(PSNullViewState)state {
  _state = state;
  [self removeSubviews];
  
  switch (state) {
    case PSNullViewStateDisabled:
      [self hideNullView];
      break;
    case PSNullViewStateEmpty:
      [self addSubview:_emptyView];
      [self showNullView];
      break;
    case PSNullViewStateLoading:
      [self addSubview:_loadingView];
      [self showNullView];
      break;
    default:
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
