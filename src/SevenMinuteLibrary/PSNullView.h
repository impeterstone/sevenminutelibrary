//
//  PSNullView.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
  
  // Empty
  UIView *_emptyView;
}

@property (nonatomic, assign) PSNullViewState state;

- (void)setupLoadingView;
- (void)setupEmptyView;

- (void)showNullView;
- (void)hideNullView;

@end
