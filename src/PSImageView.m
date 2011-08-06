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
    self.contentMode = UIViewContentModeScaleAspectFit;
  }
  return self;
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  _loadingIndicator.frame = self.bounds;
}

- (void)setImage:(UIImage *)image {
  if (image && image != _placeholderImage) {
    // RETINA
    [_loadingIndicator stopAnimating];
//    UIImage *newImage = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:image.imageOrientation];
    UIImage *newImage = [image imageScaledForScreen];
    if (_shouldAnimate) {
//      [self animateCrossFade:newImage];
      [self animateImageFade:newImage];
    } else {
      [super setImage:newImage];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageDidLoad:)]) {
      [self.delegate performSelector:@selector(imageDidLoad:) withObject:image];
    }
  } else {
    [super setImage:image];
    [_loadingIndicator startAnimating];
  }
//  [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, image.size.width, image.size.height)];
}

- (void)animateImageFade:(UIImage *)image {
  [super setImage:image];
  
  CGFloat beginAlpha, endAlpha;
  beginAlpha = 0.0;
  endAlpha = 1.0;
  
  self.alpha = beginAlpha;
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationCurve:UIViewAnimationCurveLinear];
  [UIView setAnimationDuration:0.4];
  self.alpha = endAlpha;
  [UIView commitAnimations];
}

- (void)animateCrossFade:(UIImage *)image {
  CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
  crossFade.duration = 0.4;
  crossFade.fromValue = (id)[self.image CGImage];
  crossFade.toValue = (id)[image CGImage];
  [self.layer addAnimation:crossFade forKey:@"animateContents"];
  [super setImage:image];
}

- (void)dealloc {
  RELEASE_SAFELY(_loadingIndicator);
  RELEASE_SAFELY(_placeholderImage);
  
  [super dealloc];
}

@end
