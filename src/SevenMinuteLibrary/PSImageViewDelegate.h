//
//  PSImageViewDelegate.h
//  PhotoFeed
//
//  Created by Peter Shih on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PSImageViewDelegate <NSObject>
@optional
- (void)imageDidLoad:(UIImage *)image;
@end
