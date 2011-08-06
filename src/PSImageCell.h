//
//  PSImageCell.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 Seven Minute Labs, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCell.h"
#import "PSURLCacheImageView.h"

#define IMAGE_WIDTH_PLAIN 40.0
#define IMAGE_HEIGHT_PLAIN 40.0
#define IMAGE_WIDTH_GROUPED 34.0
#define IMAGE_HEIGHT_GROUPED 34.0

#define IMAGE_OFFSET 60.0

@interface PSImageCell : PSCell {
  PSURLCacheImageView *_psImageView;
  UIImageView *_psFrameView;
}

- (void)loadImage;

@end
