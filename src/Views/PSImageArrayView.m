//
//  PSImageArrayView.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 5/17/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSImageArrayView.h"
#import "PSImageCache.h"
#import "UIImage+SML.h"

@implementation PSImageArrayView

@synthesize urlPathArray = _urlPathArray;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _animateIndex = 0;
    _shouldScale = NO;
    _images = [[NSMutableDictionary alloc] init];

    self.backgroundColor = [UIColor blackColor];
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_urlPathArray);
  RELEASE_SAFELY(_images);
  INVALIDATE_TIMER(_animateTimer);
  
  [super dealloc];
}

#pragma mark Array of Images
- (void)loadImageArray {
  // Download all images
  for (NSString *urlPath in _urlPathArray) {
    [_images setObject:[NSNull null] forKey:urlPath];
    UIImage *image = [[PSImageCache sharedCache] imageForURLPath:urlPath shouldDownload:YES withDelegate:self];
    if (image) {
      [_images setObject:image forKey:urlPath];
      [self prepareImageArray];
    }
  }
}

- (void)unloadImageArray {
  INVALIDATE_TIMER(_animateTimer);
  _animateIndex = 0;
  [_images removeAllObjects];
}

- (void)prepareImageArray {
  if ([_images count] == [_urlPathArray count] && ![[_images allValues] containsObject:[NSNull null]] && !_animateTimer) {
    _animateTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.0] interval:8.0 target:self selector:@selector(animateImages) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_animateTimer forMode:NSDefaultRunLoopMode];
  }
}

- (void)animateImages {
  NSArray *imageArray = [_images allValues];
  if ([imageArray count] < [_urlPathArray count]) return;
  
  self.image = [imageArray objectAtIndex:_animateIndex];
  
  CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
  crossFade.duration = 4.0;
  crossFade.fromValue = (id)[[imageArray objectAtIndex:_animateIndex] CGImage];
  
  _animateIndex++;
  if (_animateIndex == [_images count]) {
    _animateIndex = 0;
  }
  
  crossFade.toValue = (id)[[imageArray objectAtIndex:(_animateIndex)] CGImage];
  [self.layer addAnimation:crossFade forKey:@"animateContents"];
  
  self.image = [imageArray objectAtIndex:_animateIndex];
}


#pragma mark - PSImageCacheDelegate
- (void)imageCacheDidLoad:(NSData *)imageData forURLPath:(NSString *)urlPath {
  if (imageData) {
    if ([_images objectForKey:urlPath] == [NSNull null]) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
          [_images setObject:image forKey:urlPath];
          [self prepareImageArray];
        });
      });
    }
  }
}


@end
