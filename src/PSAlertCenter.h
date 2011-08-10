//
//  PSAlertCenter.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/18/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSObject.h"

@interface PSAlertCenter : PSObject {
  UIAlertView *_alertView;
  NSTimer *_alertTimer;
}

+ (id)defaultCenter;

- (void)postAlertWithTitle:(NSString *)title andMessage:(NSString *)message andDelegate:(id)delegate;

- (void)dismissAlertFromTimer:(NSTimer*)theTimer;

@end
