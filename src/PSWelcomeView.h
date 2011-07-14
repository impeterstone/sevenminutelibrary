//
//  PSWelcomeView.h
//  Moogle
//
//  Created by Peter Shih on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSView.h"

@interface PSWelcomeView : PSView <UIScrollViewDelegate> {
  UIScrollView *_scrollView;
  UIPageControl *_pageControl;
  
  NSArray *_viewArray;
}

@property (nonatomic, retain) NSArray *viewArray;

@end
