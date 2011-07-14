//
//  PSProgressCenter.h
//  Moogle
//
//  Created by Peter Shih on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSObject.h"

@class DDProgressView;

@interface PSProgressCenter : PSObject {
  UIView *_containerView;
  DDProgressView *_progressView;
  UILabel *_progressLabel;
}

+ (PSProgressCenter *)defaultCenter;

- (void)showProgress;
- (void)hideProgress;

- (void)updateLoginProgress:(NSNotification *)notification;
- (void)updateLoginProgressOnMainThread:(NSDictionary *)userInfo;

@end
