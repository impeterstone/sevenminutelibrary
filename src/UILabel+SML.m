//
//  UILabel+SML.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/21/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "UILabel+SML.h"


@implementation UILabel (SML)

#pragma mark - Variable Sizing
+ (CGSize)sizeForText:(NSString*)text width:(CGFloat)width font:(UIFont*)font numberOfLines:(NSInteger)numberOfLines lineBreakMode:(UILineBreakMode)lineBreakMode {
  
  if (numberOfLines == 0) numberOfLines = INT_MAX;
  
  CGFloat lineHeight = [@"A" sizeWithFont:font].height;
  return [text sizeWithFont:font constrainedToSize:CGSizeMake(width, numberOfLines*lineHeight) lineBreakMode:lineBreakMode];
}

@end
