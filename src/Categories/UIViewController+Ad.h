//
//  UIViewController+Ad.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 8/25/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <iAd/ADBannerView.h>

@interface UIViewController (Ad)

- (ADBannerView *)newAdBannerViewWithDelegate:(id)delegate;

@end
