//
//  PSCell.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 Seven Minute Labs, Inc.. All rights reserved.
//

#import "PSCell.h"

@implementation PSCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _separatorStyle = style;
    self.opaque = YES;
    self.contentMode = UIViewContentModeRedraw;
  }
  return self;
}

+ (NSString *)reuseIdentifier {
  return NSStringFromClass(self);
}

+ (PSCellType)cellType {
  return PSCellTypePlain;
}

+ (CGFloat)rowWidthForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
    if (isDeviceIPad()) {
      return 768.0;
    } else {
      return 320.0;
    }
  } else {
    if (isDeviceIPad()) {
      return 1024.0;
    } else {
      return 480.0;
    }
  }
}

+ (CGFloat)rowHeight {
  return 60.0;
}

// This is a class method because it is called before the cell has finished its layout
+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // subclass must override
  return 0.0;
}

- (void)fillCellWithObject:(id)object {
  // Subclasses must override
  [self fillCellWithObject:object shouldLoadImages:NO];
}

- (void)fillCellWithObject:(id)object shouldLoadImages:(BOOL)shouldLoadImages {
  // Subclasses must override
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)dealloc {
  [super dealloc];
}

@end
