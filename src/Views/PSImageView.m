//
//  PSImageView.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSImageView.h"
#import "UIImage+SML.h"

@implementation PSImageView

@synthesize placeholderImage = _placeholderImage;
@synthesize shouldScale = _shouldScale;
@synthesize shouldAnimate = _shouldAnimate;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    DLog(@"Called by class: %@", [self class]);
    _shouldScale = NO;
    _shouldAnimate = NO;
    _placeholderImage = nil;
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _loadingIndicator.hidesWhenStopped = YES;
    _loadingIndicator.frame = self.bounds;
    _loadingIndicator.contentMode = UIViewContentModeCenter;
    [_loadingIndicator startAnimating];
    [self addSubview:_loadingIndicator];
    self.backgroundColor = [UIColor blackColor];
    self.contentMode = UIViewContentModeScaleAspectFill;
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_loadingIndicator);
  RELEASE_SAFELY(_placeholderImage);
  
  DLog(@"Called by class: %@", [self class]);
  [super dealloc];
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  _loadingIndicator.frame = self.bounds;
}

- (void)setImage:(UIImage *)image {
  [self setImage:image animated:YES];
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated {
  if (image && image != _placeholderImage) {
    // RETINA
    [_loadingIndicator stopAnimating];
//    UIImage *newImage = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:image.imageOrientation];
    UIImage *newImage = [image imageScaledForScreen];
    if (_shouldAnimate && animated) {
      [super setImage:newImage];
      [self animateImageFade:newImage];
    } else {
      [super setImage:newImage];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageDidLoad:)]) {
      [self.delegate performSelector:@selector(imageDidLoad:) withObject:image];
    }
  } else if (image == _placeholderImage && _placeholderImage) {
    [super setImage:image];
    [_loadingIndicator stopAnimating];
  } else {
    [super setImage:image];
    [_loadingIndicator startAnimating];
  }
//  [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, image.size.width, image.size.height)];
}

- (void)animateImageFade:(UIImage *)image {  
  CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
  fade.duration = 0.2;
  fade.fromValue = [NSNumber numberWithFloat:0.0];
  fade.toValue = [NSNumber numberWithFloat:1.0];
  [self.layer addAnimation:fade forKey:@"opacity"];
}

- (void)stopAnimations {
  [self.layer removeAllAnimations];
}

@end
