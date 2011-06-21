//
//  UILabel+SML.h
//  PhotoFeed
//
//  Created by Peter Shih on 6/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UILabel (SML)

#pragma mark - Variable Sizing
+ (CGSize)sizeForText:(NSString*)text width:(CGFloat)width font:(UIFont*)font numberOfLines:(NSInteger)numberOfLines lineBreakMode:(UILineBreakMode)lineBreakMode;

@end
