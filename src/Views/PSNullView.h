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
  
  UIView *_loadingView;
  UIView *_emptyView;
}

@property (nonatomic, assign) PSNullViewState state;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UIView *emptyView;

- (void)showNullView;
- (void)hideNullView;

@end
