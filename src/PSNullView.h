//
//  PSNullView.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 4/9/11.
//  Copyright 2011 Seven Minute Labs, Inc.. All rights reserved.
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
  
  // Loading
  UIView *_loadingView;
  UILabel *_loadingLabel;
  
  // Empty
  UIView *_emptyView;
  UILabel *_emptyLabel;
}

@property (nonatomic, assign) PSNullViewState state;

- (void)setupLoadingView;
- (void)setupEmptyView;

- (void)setLoadingLabel:(NSString *)loadingLabel;
- (void)setEmptyLabel:(NSString *)emptyLabel;

- (void)showNullView;
- (void)hideNullView;

@end
