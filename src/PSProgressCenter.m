//
//  PSProgressCenter.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 7/14/11.
//  Copyright 2011 Seven Minute Labs, Inc.. All rights reserved.
//

#import "PSProgressCenter.h"
#import "DDProgressView.h"
#import "UIView+SML.h"

@implementation PSProgressCenter

@synthesize progressView = _progressView;

+ (PSProgressCenter *)defaultCenter {
  static PSProgressCenter *defaultCenter;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

- (id)init {
  self = [super init];
  if (self) {
    _isShowing = NO;
    
    // Container View
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
      window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, window.bounds.size.height, window.bounds.size.width, 44.0)];
    _containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_bar_320x44.png"]];
    
    [window addSubview:_containerView];
    
    // Progress View
    _progressView = [[DDProgressView alloc] initWithFrame:CGRectMake(10, 18, _containerView.width - 20, 22)];
    _progressView.progress = 0.0;
    
    // Progress Label
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, _containerView.width - 20, 14)];
    _progressLabel.backgroundColor = [UIColor clearColor];
    _progressLabel.textAlignment = UITextAlignmentCenter;
    _progressLabel.font = SUBTITLE_FONT;
    _progressLabel.textColor = [UIColor whiteColor];
    
    [_containerView addSubview:_progressView];
    [_containerView addSubview:_progressLabel];
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_progressView);
  RELEASE_SAFELY(_progressLabel);
  RELEASE_SAFELY(_containerView);
  [super dealloc];
}

#pragma mark - Set Progress
- (void)setProgress:(float)newProgress {
  _progressView.progress = newProgress;
}

- (void)setMessage:(NSString *)message {
  _progressLabel.text = message;
}

#pragma mark - Show/Hide
- (void)showProgress {
  if (_isShowing) {
    return;
  }
  _progressView.progress = 0.0;
  
  [UIView animateWithDuration:0.4
                   animations:^{
                     _containerView.top -= _containerView.height;
                     _isShowing = YES;
                   }
                   completion:^(BOOL finished) {
                   }];
}

- (void)hideProgress {
  if (!_isShowing) {
    return;
  }
  [UIView animateWithDuration:0.4
                   animations:^{
                     _isShowing = NO;
                     _containerView.top += _containerView.height;
                   }
                   completion:^(BOOL finished) {
                     _progressView.progress = 0.0;
                   }];
}

@end
