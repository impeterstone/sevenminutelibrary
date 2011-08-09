//
//  UIBarButtonItem+SML.m
//  PhotoTime
//
//  Created by Peter Shih on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIBarButtonItem+SML.h"

@implementation UIBarButtonItem (SML)

+ (UIBarButtonItem *)navButtonWithTitle:(NSString *)title withTarget:(id)target action:(SEL)action buttonType:(NavButtonType)buttonType {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.frame = CGRectMake(0, 0, 60, 30);
  [button setTitle:title forState:UIControlStateNormal];
  button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
  button.titleLabel.shadowColor = [UIColor blackColor];
  button.titleLabel.shadowOffset = CGSizeMake(0, 1);
  
  UIImage *bg = nil;
  UIImage *bgHighlighted = nil;
  switch (buttonType) {
    case NavButtonTypeNormal:
      bg = [[UIImage imageNamed:@"navbar_normal_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_normal_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case NavButtonTypeBlue:
      bg = [[UIImage imageNamed:@"navbar_blue_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_blue_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case NavButtonTypeRed:
      bg = [[UIImage imageNamed:@"navbar_red_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_red_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case NavButtonTypeGreen:
      bg = [[UIImage imageNamed:@"navbar_green_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_green_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case NavButtonTypeSilver:
      bg = [[UIImage imageNamed:@"navbar_focus_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_focus_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    default:
      bg = [[UIImage imageNamed:@"navbar_normal_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_normal_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
  }
  
  [button setBackgroundImage:bg forState:UIControlStateNormal];
  [button setBackgroundImage:bgHighlighted forState:UIControlStateHighlighted];
  [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];  
  UIBarButtonItem *navButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
  return navButton;
}

+ (UIBarButtonItem *)navButtonWithImage:(UIImage *)image withTarget:(id)target action:(SEL)action buttonType:(NavButtonType)buttonType {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.frame = CGRectMake(0, 0, 60, 30);
  [button setImage:image forState:UIControlStateNormal];
  [button setImage:image forState:UIControlStateHighlighted];
  
  UIImage *bg = nil;
  UIImage *bgHighlighted = nil;
  switch (buttonType) {
    case NavButtonTypeNormal:
      bg = [[UIImage imageNamed:@"navbar_normal_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_normal_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case NavButtonTypeBlue:
      bg = [[UIImage imageNamed:@"navbar_blue_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_blue_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case NavButtonTypeRed:
      bg = [[UIImage imageNamed:@"navbar_red_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_red_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case NavButtonTypeGreen:
      bg = [[UIImage imageNamed:@"navbar_green_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_green_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case NavButtonTypeSilver:
      bg = [[UIImage imageNamed:@"navbar_focus_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_focus_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    default:
      bg = [[UIImage imageNamed:@"navbar_normal_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_normal_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
  }
  
  [button setBackgroundImage:bg forState:UIControlStateNormal];
  [button setBackgroundImage:bgHighlighted forState:UIControlStateHighlighted];
  [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];  
  UIBarButtonItem *navButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
  return navButton;
}

@end
