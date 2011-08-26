//
//  PSScrapeCenter.h
//  MealTime
//
//  Created by Peter Shih on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSObject.h"

@interface PSScrapeCenter : PSObject {
  
}

+ (id)defaultCenter;

- (NSString *)scrapeNumberOfPhotosWithHTMLString:(NSString *)htmlString;
- (NSArray *)scrapePhotosWithHTMLString:(NSString *)htmlString;
- (NSArray *)scrapePlacesWithHTMLString:(NSString *)htmlString;

@end
