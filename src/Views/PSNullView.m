//
//  PSNullView.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 4/9/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSNullView.h"

@interface PSNullView (Private)

@end

@implementation PSNullView

@synthesize state = _state;
@synthesize titleLabel = _titleLabel;
@synthesize subtitleLabel = _subtitleLabel;
@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {    
    _state = PSNullViewStateDisabled;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.font = [PSStyleSheet fontForStyle:@"nullTitle"];
    _titleLabel.textColor = [PSStyleSheet textColorForStyle:@"nullTitle"];
    _titleLabel.shadowColor = [PSStyleSheet shadowColorForStyle:@"nullTitle"];
    _titleLabel.shadowOffset = [PSStyleSheet shadowOffsetForStyle:@"nullTitle"];
    
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _subtitleLabel.backgroundColor = [UIColor clearColor];
    _subtitleLabel.textAlignment = UITextAlignmentCenter;
    _subtitleLabel.font = [PSStyleSheet fontForStyle:@"nullSubtitle"];
    _subtitleLabel.textColor = [PSStyleSheet textColorForStyle:@"nullSubtitle"];
    _subtitleLabel.shadowColor = [PSStyleSheet shadowColorForStyle:@"nullSubtitle"];
    _subtitleLabel.shadowOffset = [PSStyleSheet shadowOffsetForStyle:@"nullSubtitle"];
    
    [self addSubview:_imageView];
    [self addSubview:_titleLabel];
    [self addSubview:_subtitleLabel];
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  CGFloat top = floorf(self.height / 2);
  
  if (_imageView.image) {
    _imageView.left = floorf(self.width / 2) - floorf(_imageView.width / 2);
    _imageView.top = top - floorf(_imageView.height / 2) - 30;
    top = _imageView.bottom + 20;
  }

  _titleLabel.width = self.width;
  _titleLabel.top = top;
  top = _titleLabel.bottom;
  
  _subtitleLabel.width = self.width;
  _subtitleLabel.top = top;
}

#pragma mark - State
- (void)setLoadingTitle:(NSString *)loadingTitle loadingSubtitle:(NSString *)loadingSubtitle emptyTitle:(NSString *)emptyTitle emptySubtitle:(NSString *)emptySubtitle image:(UIImage *)image {
  _loadingTitle = [loadingTitle retain];
  _loadingSubtitle = [loadingSubtitle retain];
  _emptyTitle = [emptyTitle retain];
  _emptySubtitle = [emptySubtitle retain];
  if (image) {
    [_imageView setImage:image];
  }
}

- (void)setState:(PSNullViewState)state
{
  _state = state;
  
  switch (state) {
    case PSNullViewStateDisabled:
      _titleLabel.text = nil;
      _subtitleLabel.text = nil;
      _imageView.hidden = YES;
      break;
    case PSNullViewStateEmpty:
      _titleLabel.text = _emptyTitle;
      _subtitleLabel.text = _emptySubtitle;
      _imageView.hidden = NO;
      break;
    case PSNullViewStateLoading:
      _titleLabel.text = _loadingTitle;
      _subtitleLabel.text = _loadingSubtitle;
      _imageView.hidden = NO;
      break;
    default:
      _titleLabel.text = nil;
      _subtitleLabel.text = nil;
      _imageView.hidden = YES;
      break;
  }
  [_titleLabel sizeToFit];
  [_subtitleLabel sizeToFit];
  [_imageView sizeToFit];
  [self setNeedsLayout];
}
- (void)dealloc {
  RELEASE_SAFELY(_titleLabel);
  RELEASE_SAFELY(_subtitleLabel);
  RELEASE_SAFELY(_imageView);
  RELEASE_SAFELY(_loadingTitle);
  RELEASE_SAFELY(_loadingSubtitle)
  RELEASE_SAFELY(_emptyTitle);
  RELEASE_SAFELY(_emptySubtitle);
  
  [super dealloc];
}

@end
