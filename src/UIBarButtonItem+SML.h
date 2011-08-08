//
//  UIBarButtonItem+SML.h
//  PhotoTime
//
//  Created by Peter Shih on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
  NavButtonTypeNormal = 0,
  NavButtonTypeBlue = 1,
  NavButtonTypeRed = 2,
  NavButtonTypeGreen = 3,
  NavButtonTypeSilver = 4
};
typedef uint32_t NavButtonType;

@interface UIBarButtonItem (SML)

+ (UIBarButtonItem *)navButtonWithTitle:(NSString *)title withTarget:(id)target action:(SEL)action buttonType:(NavButtonType)buttonType;
+ (UIBarButtonItem *)navButtonWithImage:(UIImage *)image withTarget:(id)target action:(SEL)action buttonType:(NavButtonType)buttonType;

@end
