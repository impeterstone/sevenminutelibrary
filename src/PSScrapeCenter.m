//
//  PSScrapeCenter.m
//  Spotlight
//
//  Created by Peter Shih on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSScrapeCenter.h"
#import "TFHpple.h"

@implementation PSScrapeCenter

+ (id)defaultCenter {
  static id defaultCenter = nil;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

#pragma mark - Public Methods
- (NSArray *)scrapePhotosWithHTMLString:(NSString *)htmlString {
  // HTML Scraping
  NSString *strippedString = [htmlString stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
  NSData *strippedData = [strippedString dataUsingEncoding:NSUTF8StringEncoding];
  
  TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:strippedData];
  NSArray *elements  = [xpathParser searchWithXPathQuery:@"//div[@id=\"mainContent\"]//img"];
  
  NSMutableArray *photoArray = [NSMutableArray array];
  for (TFHppleElement *element in elements) {
    // Get the photo src url
    NSString *src = [[element objectForKey:@"src"] stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"l.jpg"];
    
    // Get the photo caption
    NSString *alt = [element objectForKey:@"alt"];
    
    NSDictionary *photoDict = [NSDictionary dictionaryWithObjectsAndKeys:src, @"src", alt, @"alt", nil];
    [photoArray addObject:photoDict];
  }
  
  NSLog(@"Photos: %@", photoArray);
  
  [xpathParser release];
  
  return photoArray;
}

- (NSArray *)scrapePlacesWithHTMLString:(NSString *)htmlString {
  // HTML Scraping
  NSString *strippedString = [htmlString stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
  NSData *strippedData = [strippedString dataUsingEncoding:NSUTF8StringEncoding];
  
  TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:strippedData];
  NSArray *elements  = [xpathParser searchWithXPathQuery:@"//span[@class=\"address\"]"];
  
  NSMutableArray *placeArray = [NSMutableArray array];
  for (TFHppleElement *element in elements) {
    // Get the business id string that is used to identify this place
    NSString *biz = [[[[[element firstChild] firstChild] attributes] objectForKey:@"href"] stringByReplacingOccurrencesOfString:@"/biz/" withString:@""];
    
    // Get the business name
    NSString *name = [[[element firstChild] firstChild] content];
    
    // Find Distance in Miles
    NSRange milesRange = [[element content] rangeOfString:@"miles"];
    NSString *distance = nil;
    if (NSEqualRanges(NSMakeRange(NSNotFound, 0), milesRange)) {
      distance = @"0.00";
    } else {
      distance = [[element content] substringToIndex:(milesRange.location-1)];
    }
    
    // Find Price in $
    NSRange priceRange = [[element content] rangeOfString:@"Price: "];
    NSString *price = nil;
    if (NSEqualRanges(NSMakeRange(NSNotFound, 0), priceRange)) {
      price = @"";
    } else {
      price = [[element content] substringFromIndex:(priceRange.location + priceRange.length)];
    }
    
    // Find Phone Number
    NSString *phone = [[[element children] lastObject] content];
    
    // Create payload, add to array
    NSDictionary *placeDict = [NSDictionary dictionaryWithObjectsAndKeys:biz, @"biz", name, @"name", distance, @"distance", price, @"price", phone, @"phone", nil];
    [placeArray addObject:placeDict];
  }
  
  NSLog(@"Places: %@", placeArray);
  
  [xpathParser release];
  
  return placeArray;
}

@end
