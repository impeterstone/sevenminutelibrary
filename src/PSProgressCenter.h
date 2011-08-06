//
//  PSProgressCenter.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 7/14/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSObject.h"

@class DDProgressView;

@interface PSProgressCenter : PSObject {
  UIView *_containerView;
  DDProgressView *_progressView;
  UILabel *_progressLabel;
  
  BOOL _isShowing;
}

@property (nonatomic, readonly) DDProgressView *progressView;

+ (PSProgressCenter *)defaultCenter;

// Override UIProgressView's default set
- (void)setProgress:(float)newProgress;

- (void)setMessage:(NSString *)message;

- (void)showProgress;
- (void)hideProgress;

@end
