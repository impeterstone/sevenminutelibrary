//
//  PSSearchField.m
//  MealTime
//
//  Created by Peter Shih on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSSearchField.h"
#import "PSStyleSheet.h"

@implementation PSSearchField

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.background = [[UIImage imageNamed:@"bg_searchfield.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:15];
    self.returnKeyType = UIReturnKeySearch;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.font = [PSStyleSheet fontForStyle:@"searchField"];
    self.textColor = [PSStyleSheet textColorForStyle:@"searchField"];
    self.keyboardAppearance = UIKeyboardAppearanceAlert;
  }
  return self;
}

// This overrides the default image for a clear button
- (UIButton *)clearButton {
  UIButton *clearButton = [super clearButton];
  [clearButton setImage:[UIImage imageNamed:@"icon_clear.png"] forState:UIControlStateNormal];
  return clearButton;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, 30, 0);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, 30, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, 30, 0);
}

//- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
//  return bounds;
//}
//
- (CGRect)leftViewRectForBounds:(CGRect)bounds {
  return CGRectMake(5, 5, 20, 20);
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
  return CGRectMake(bounds.size.width - 25, 5, 20, 20);
}

@end
