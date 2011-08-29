//
//  PSScrapeCenter.m
//  MealTime
//
//  Created by Peter Shih on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSScrapeCenter.h"
#import "TFHpple.h"
#import "RegexKitLite.h"
#import "HTMLParser.h"
#import <math.h>

static dispatch_queue_t _psScrapeQueue = nil;

@implementation PSScrapeCenter

+ (void)initialize {
  _psScrapeQueue = dispatch_queue_create("com.sevenminutelabs.psScrapeQueue", NULL);
}

+ (dispatch_queue_t)sharedQueue {
  return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//  return _psScrapeQueue;
}

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
- (NSDictionary *)scrapePhotosWithHTMLString:(NSString *)htmlString {
  // HTML Scraping
  NSError *parserError = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
  HTMLNode *doc = [parser body];
  
  HTMLNode *mainContentNode = [doc findChildWithAttribute:@"id" matchingName:@"mainContent" allowPartial:YES];
  
  NSString *numphotos = [[mainContentNode rawContents] stringByMatching:@"\\d+ Photos from"];
  if (numphotos) {
    numphotos = [numphotos stringByReplacingOccurrencesOfString:@" Photos from" withString:@""];
  } else {
    numphotos = @"0";
  }
  
  NSArray *photoNodes = [mainContentNode findChildTags:@"img"];
  
  NSMutableArray *photos = [NSMutableArray array];
  for (HTMLNode *node in photoNodes) {
    NSString *src = [[node getAttributeNamed:@"src"] stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"l.jpg"];
    NSString *caption = [node getAttributeNamed:@"alt"];
    
    // Create payload
    NSMutableDictionary *photoDict = [NSMutableDictionary dictionary];
    src ? [photoDict setObject:src forKey:@"src"] : [photoDict setObject:[NSNull null] forKey:@"src"];
    caption ? [photoDict setObject:caption forKey:@"caption"] : [photoDict setObject:[NSNull null] forKey:@"caption"];
    
    [photos addObject:photoDict];
  }
  
  [parser release];
  
  NSDictionary *photoDict = [NSDictionary dictionaryWithObjectsAndKeys:numphotos, @"numphotos", photos, @"photos", nil];
  
  VLog(@"Photos: %@", photoDict);
  
  return photoDict;
}

- (NSDictionary *)scrapePlacesWithHTMLString:(NSString *)htmlString {
  // Prepare response container
  NSMutableDictionary *placeDict = [NSMutableDictionary dictionary];
  
  // HTML Scraping
  NSError *parserError = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
  HTMLNode *doc = [parser body];
  
  HTMLNode *mainContentNode = [doc findChildWithAttribute:@"id" matchingName:@"mainContent" allowPartial:YES];
//  NSString *mainContent = [mainContentNode rawContents];
  
  NSString *pager = [[mainContentNode findChildWithAttribute:@"class" matchingName:@"pager_current" allowPartial:YES] contents];
  NSString *currentPage = [[pager componentsMatchedByRegex:@"(?:Page )(\\d+)(?: of )(\\d+)" capture:1] lastObject];
  NSString *numPages = [[pager componentsMatchedByRegex:@"(?:Page )(\\d+)(?: of )(\\d+)" capture:2] lastObject];
  NSDictionary *pagingDict = [NSDictionary dictionaryWithObjectsAndKeys:currentPage, @"currentPage", numPages, @"numPages", nil];
  [placeDict setObject:pagingDict forKey:@"paging"];
  
  
  NSArray *addressNodes = [mainContentNode findChildrenWithAttribute:@"class" matchingName:@"address" allowPartial:YES];
  
  NSMutableArray *placeArray = [NSMutableArray array];
  int i = 0;
  for (HTMLNode *node in addressNodes) {
    NSNumber *index = [NSNumber numberWithInt:i]; // Popularity index
    HTMLNode *bizNode = [node findChildWithAttribute:@"href" matchingName:@"/biz/" allowPartial:YES];
    NSString *biz = [[bizNode getAttributeNamed:@"href"] stringByReplacingOccurrencesOfString:@"/biz/" withString:@""];
    NSString *name = [[bizNode contents] stringByUnescapingHTML];
    NSString *rating = [[[node findChildWithAttribute:@"alt" matchingName:@"star rating" allowPartial:YES] getAttributeNamed:@"alt"] stringByReplacingOccurrencesOfString:@" star rating" withString:@""];
    NSString *phone = [[node findChildWithAttribute:@"title" matchingName:@"Call" allowPartial:YES] contents];
    NSString *numreviews = [[node rawContents] stringByMatching:@"\\d+ reviews"];
    if (numreviews) numreviews = [numreviews stringByReplacingOccurrencesOfString:@" reviews" withString:@""];
    NSString *price = [[node rawContents] stringByMatching:@"Price: [$]+"];
    if (price) price = [price stringByReplacingOccurrencesOfString:@"Price: " withString:@""];
    NSString *category = [[node rawContents] stringByMatching:@"Category: [^<]+"];
    if (category) category = [[category stringByReplacingOccurrencesOfString:@"Category: " withString:@""] stringByUnescapingHTML];
    NSString *distance = [[node rawContents] stringByMatching:@"\\d+\\.\\d+ miles"];
    if (distance) distance = [distance stringByReplacingOccurrencesOfString:@" miles" withString:@""];
    else distance = @"0.0";
    NSString *city = [[node rawContents] stringByMatching:@"(?m)^\\w+, \\w{2}"];
    
    // Calculate composite rating
    NSString *score = nil;
    if (rating && numreviews) {
      CGFloat rawRating = [rating floatValue];
      CGFloat rawNumReviews = [numreviews floatValue];
      CGFloat baseRating = (rawRating / 5.0) * 100.0;
      BOOL isPositive = (rawNumReviews >= 100);
      if (!isPositive) rawNumReviews += 100;
      
      CGFloat reviewModifier = logf(rawNumReviews);
      CGFloat adjustedRating = isPositive ? (baseRating + reviewModifier) : MIN((baseRating - reviewModifier), 100.0);
      
      score = [NSString stringWithFormat:@"%.1f", adjustedRating];
    } else {
      score = @"0.0";
    }
    
    // Create payload, add to array
    NSMutableDictionary *placeDict = [NSMutableDictionary dictionary];
    index ? [placeDict setObject:index forKey:@"index"] : [placeDict setObject:[NSNull null] forKey:@"index"];
    biz ? [placeDict setObject:biz forKey:@"biz"] : [placeDict setObject:[NSNull null] forKey:@"biz"];
    name ? [placeDict setObject:name forKey:@"name"] : [placeDict setObject:[NSNull null] forKey:@"name"];
    rating ? [placeDict setObject:rating forKey:@"rating"] : [placeDict setObject:[NSNull null] forKey:@"rating"];
    phone ? [placeDict setObject:phone forKey:@"phone"] : [placeDict setObject:[NSNull null] forKey:@"phone"];
    numreviews ? [placeDict setObject:numreviews forKey:@"numreviews"] : [placeDict setObject:[NSNull null] forKey:@"numreviews"];
    price ? [placeDict setObject:price forKey:@"price"] : [placeDict setObject:[NSNull null] forKey:@"price"];
    category ? [placeDict setObject:category forKey:@"category"] : [placeDict setObject:[NSNull null] forKey:@"category"];
    distance ? [placeDict setObject:distance forKey:@"distance"] : [placeDict setObject:[NSNull null] forKey:@"distance"];
    city ? [placeDict setObject:city forKey:@"city"] : [placeDict setObject:[NSNull null] forKey:@"city"];
    score ? [placeDict setObject:score forKey:@"score"] : [placeDict setObject:[NSNull null] forKey:@"score"];
     
    [placeArray addObject:placeDict];
    
    i++;
  }
  
  // Add array to response
  [placeDict setObject:placeArray forKey:@"places"];
  
  VLog(@"Places: %@", placeDict);
  
  [parser release];
  
  return placeDict;
}

- (NSDictionary *)scrapeMapWithHTMLString:(NSString *)htmlString {
  // HTML Scraping
  NSError *parserError = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
  HTMLNode *doc = [parser body];
  
  HTMLNode *mainContentNode = [doc findChildWithAttribute:@"id" matchingName:@"mainContent" allowPartial:YES];
  //  NSString *mainContent = [mainContentNode rawContents];
  
  NSString *dirURLString = [[mainContentNode findChildWithAttribute:@"class"matchingName:@"dir-link" allowPartial:YES] getAttributeNamed:@"href"];
  
  NSString *address = [[[[dirURLString stringByMatching:@"daddr=[^&]+"] stringByReplacingOccurrencesOfString:@"daddr=" withString:@""] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
  
  NSString *mapString = [[mainContentNode findChildWithAttribute:@"src" matchingName:@"maps.google.com" allowPartial:YES] getAttributeNamed:@"src"];
  
  NSString *coordinates = [[[mapString stringByMatching:@"center=[^&]+"] stringByReplacingOccurrencesOfString:@"center=" withString:@""] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  
  // Create payload
  NSMutableDictionary *mapDict = [NSMutableDictionary dictionary];
  address ? [mapDict setObject:address forKey:@"address"] : [mapDict setObject:[NSNull null] forKey:@"address"];
  coordinates ? [mapDict setObject:coordinates forKey:@"coordinates"] : [mapDict setObject:[NSNull null] forKey:@"coordinates"];
  
  [parser release];
  
  return mapDict;
}

- (NSDictionary *)scrapeBizWithHTMLString:(NSString *)htmlString {
  // HTML Scraping
  NSError *parserError = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
  HTMLNode *doc = [parser body];
  
  HTMLNode *mainContentNode = [doc findChildWithAttribute:@"id" matchingName:@"mainContent" allowPartial:YES];
  //  NSString *mainContent = [mainContentNode rawContents];

  NSString *hours = [[[mainContentNode rawContents] stringByMatching:@"(?ms)Hours:[^<]+.*View Photos</a>"] stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
  hours = [hours stringByMatching:@"Hours:[^<]+"];
  hours = [hours stringByReplacingOccurrencesOfRegex:@"\\s+" withString:@" "];
  hours = [hours stringByReplacingOccurrencesOfRegex:@"Hours: " withString:@""];
  NSArray *reviews = [NSArray array];
  
  // Create payload
  NSMutableDictionary *bizDict = [NSMutableDictionary dictionary];
  hours ? [bizDict setObject:hours forKey:@"hours"] : [bizDict setObject:[NSNull null] forKey:@"hours"];
  reviews ? [bizDict setObject:reviews forKey:@"reviews"] : [bizDict setObject:[NSNull null] forKey:@"reviews"];
  
  [parser release];
  
  // Hours:[^<]+.*View Photos</a>
  return bizDict;
}

@end
