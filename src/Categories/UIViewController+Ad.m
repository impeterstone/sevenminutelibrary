//
//  UIViewController+Ad.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 8/25/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "UIViewController+Ad.h"

@implementation UIViewController (Ad)

- (ADBannerView *)newAdBannerViewWithDelegate:(id)delegate {
  ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
  adView.delegate = delegate;
  
  if (&ADBannerContentSizeIdentifierPortrait != nil) {
    adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];;
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
  } else {
    adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifier320x50];
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
  }
  return adView;
}

@end
