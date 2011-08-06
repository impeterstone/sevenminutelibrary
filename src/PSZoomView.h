//
//  PSZoomView.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 5/19/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSView.h"
#import "PSImageView.h"

@interface PSZoomView : PSView <UIScrollViewDelegate> {
  
  UIScrollView *_containerView;
  PSImageView *_zoomImageView;
  UIView *_shadeView;
  UILabel *_captionLabel;
  NSString *_caption;
  CGRect _oldImageFrame;
  CGRect _oldCaptionFrame;
  CGFloat _lastScale;
}

@property (nonatomic, retain) UIScrollView *containerView;
@property (nonatomic, retain) PSImageView *zoomImageView;
@property (nonatomic, retain) UIView *shadeView;
@property (nonatomic, retain) UILabel *captionLabel;
@property (nonatomic, retain) NSString *caption;
@property (nonatomic, assign) CGRect oldImageFrame;
@property (nonatomic, assign) CGRect oldCaptionFrame;

- (void)showZoom;
- (void)removeZoom;

@end
