//
//  UIButton+SML.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/21/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "UIButton+SML.h"


@implementation UIButton (SML)

+ (UIButton *)buttonWithFrame:(CGRect)frame {
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
  btn.frame = frame;
	return btn;
}

@end
