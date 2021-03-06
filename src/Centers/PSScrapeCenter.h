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

- (NSDictionary *)scrapePhotosFromProxyWithHTMLString:(NSString *)htmlString;
- (NSDictionary *)scrapePhotosWithHTMLString:(NSString *)htmlString;
- (NSDictionary *)scrapePhotosWithMobileHTMLString:(NSString *)htmlString;
- (NSDictionary *)scrapePlacesWithHTMLString:(NSString *)htmlString;
- (NSDictionary *)scrapeBizWithHTMLString:(NSString *)htmlString;
- (NSDictionary *)scrapeReviewsWithHTMLString:(NSString *)htmlString;

@end
