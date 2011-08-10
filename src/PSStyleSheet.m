//
//  PSStyleSheet.m
//  Spotlight
//
//  Created by Peter Shih on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSStyleSheet.h"
#import "UIColor+SML.h"

static NSDictionary *_styles = nil;

@implementation PSStyleSheet

+ (void)initialize {
  NSString *styleSheetPath = [[NSBundle mainBundle] pathForResource:@"PSStyleSheet" ofType:@"plist"];
  assert(styleSheetPath != nil);
  
  NSDictionary *styleSheet = [NSDictionary dictionaryWithContentsOfFile:styleSheetPath];
  assert(styleSheet != nil);
  _styles = [styleSheet retain];
}

#pragma mark - Fonts
+ (UIFont *)fontForStyle:(NSString *)style {
  UIFont *font = nil;
  font = [UIFont fontWithName:[[_styles objectForKey:style] objectForKey:@"fontName"] size:[[[_styles objectForKey:style] objectForKey:@"fontSize"] integerValue]];
  return font;
}

#pragma mark - Colors
+ (UIColor *)textColorForStyle:(NSString *)style {
  UIColor *color = nil;
  color = [UIColor colorWithHexString:[[_styles objectForKey:style] objectForKey:@"textColor"]];
  return color;
}

+ (UIColor *)shadowColorForStyle:(NSString *)style {
  UIColor *color = nil;
  color = [UIColor colorWithHexString:[[_styles objectForKey:style] objectForKey:@"shadowColor"]];
  return color;
}

#pragma mark - Offsets
+ (CGSize)shadowOffsetForStyle:(NSString *)style {
  CGSize offset = CGSizeZero;
  offset = CGSizeFromString([[_styles objectForKey:style] objectForKey:@"shadowOffset"]);
  return offset;
}

@end
