//
//  PSNullView.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 4/9/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSView.h"

typedef enum {
  PSNullViewStateDisabled = -1,
  PSNullViewStateEmpty = 0,
  PSNullViewStateLoading = 1
} PSNullViewState;

@interface PSNullView : PSView {
  PSNullViewState _state;
  UILabel *_titleLabel;
  UILabel *_subtitleLabel;
  UIImageView *_imageView;
  NSString *_loadingTitle;
  NSString *_loadingSubtitle;
  NSString *_emptyTitle;
  NSString *_emptySubtitle;
}

@property (nonatomic, assign) PSNullViewState state;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic, retain) UIImageView *imageView;

- (void)setLoadingTitle:(NSString *)loadingTitle loadingSubtitle:(NSString *)loadingSubtitle emptyTitle:(NSString *)emptyTitle emptySubtitle:(NSString *)emptySubtitle image:(UIImage *)image;

@end
