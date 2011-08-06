//
//  PSImageCell.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSImageCell.h"

static UIImage *_frameImage = nil;

@implementation PSImageCell

+ (void)initialize {
  _frameImage = [[[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] retain];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    _psImageView = [[PSURLCacheImageView alloc] initWithFrame:CGRectMake(10 + MARGIN_X, 10, IMAGE_WIDTH_PLAIN, IMAGE_HEIGHT_PLAIN)];
    _psFrameView = [[UIImageView alloc] initWithImage:_frameImage];
    _psFrameView.frame = CGRectMake(MARGIN_X, 0, IMAGE_OFFSET, IMAGE_OFFSET);
    
    [self.contentView addSubview:_psFrameView];
    [self.contentView addSubview:_psImageView];
    
    // Override default text labels
    self.textLabel.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _psImageView.image = nil;
}

- (void)loadImage {
  [_psImageView loadImageAndDownload:YES];
}

- (void)dealloc {
  RELEASE_SAFELY(_psImageView);
  RELEASE_SAFELY(_psFrameView);
  [super dealloc];
}

@end
