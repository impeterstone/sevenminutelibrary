//
//  PSScrapeCenter.m
//  MealTime
//
//  Created by Peter Shih on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSScrapeCenter.h"
//#import "TFHpple.h"
#import "RegexKitLite.h"
#import "HTMLParser.h"
#import "JSONKit.h"
#import <math.h>

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
- (NSDictionary *)scrapePhotosFromProxyWithHTMLString:(NSString *)htmlString {
  // HTML Scraping
  NSError *parserError = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
  HTMLNode *doc = [parser body];
  
  NSString *numphotos = [[doc rawContents] stringByMatching:@"\\d+ Photos from"];
  if (numphotos) {
    numphotos = [numphotos stringByReplacingOccurrencesOfString:@" Photos from" withString:@""];
  } else {
    numphotos = @"0";
  }
  
  NSArray *photoNodes = [doc findChildrenWithAttribute:@"src" matchingName:@"yelpcdn" allowPartial:YES];
  
  // Parse page
  NSMutableArray *photos = [NSMutableArray array];
  for (HTMLNode *node in photoNodes) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *rawSrc = [node getAttributeNamed:@"src"];
    rawSrc = [rawSrc stringByMatching:@"http[^&]+"]; // strip gwt
    rawSrc = [rawSrc stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; // replace percent escapes
    rawSrc = [rawSrc stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"l.jpg"];
    
    NSString *src = rawSrc;
    NSString *caption = [node getAttributeNamed:@"alt"];
    
    // Create payload
    NSMutableDictionary *photo = [[NSMutableDictionary alloc] initWithCapacity:2];
    src ? [photo setObject:src forKey:@"src"] : [photo setObject:[NSNull null] forKey:@"src"];
    caption ? [photo setObject:caption forKey:@"caption"] : [photo setObject:[NSNull null] forKey:@"caption"];
    
    [photos addObject:photo];
    [photo release];
    
    [pool drain];
  }
  
  [parser release];
  
  NSDictionary *photoDict = [NSDictionary dictionaryWithObjectsAndKeys:numphotos, @"numphotos", photos, @"photos", nil];
  
  VLog(@"Photos: %@", photoDict);
  
  return photoDict;
}

- (NSDictionary *)scrapePhotosWithHTMLString:(NSString *)htmlString {
  // Prepare response container
  NSMutableDictionary *response = [NSMutableDictionary dictionary];
  
  // HTML Scraping
  NSError *parserError = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
  HTMLNode *doc = [parser body];
  

  // Scrape the scripts
  NSArray *scriptNodes = [doc findChildrenWithAttribute:@"type" matchingName:@"text/javascript" allowPartial:NO];
  
  // Photos
  NSMutableArray *photos = [NSMutableArray array];
  for (HTMLNode *scriptNode in scriptNodes) {
    if ([scriptNode contents] && [[scriptNode contents] rangeOfString:@"yConfig = "].location != NSNotFound) {
      NSString *yConfigJSON = [[scriptNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      yConfigJSON = [yConfigJSON substringWithRange:NSMakeRange(10, [yConfigJSON length] - 11)];
      
      NSDictionary *pageData = [[yConfigJSON objectFromJSONString] objectForKey:@"pageData"];
      
      NSNumber *numPhotos = [pageData objectForKey:@"total_photos"];
      NSArray *rawPhotos = [pageData objectForKey:@"photos"];
      [response setObject:numPhotos forKey:@"numPhotos"];
      for (NSDictionary *rawPhoto in rawPhotos) {
        NSString *src = [[rawPhoto objectForKey:@"src"] stringByReplacingOccurrencesOfString:@"//" withString:@"http://"];
        NSString *caption = [[rawPhoto objectForKey:@"caption"] notNil] ? [rawPhoto objectForKey:@"caption"] : @"";
        NSString *user = [rawPhoto objectForKey:@"user"];
        NSDictionary *photoDict = [[NSDictionary alloc] initWithObjectsAndKeys:src, @"src", caption, @"caption", user, @"user",nil];
        [photos addObject:photoDict];
        [photoDict release];
      }
      [response setObject:photos forKey:@"photos"];
    }
  }
  
  [parser release];
  
  return response;
;
}

- (NSDictionary *)scrapePlacesWithHTMLString:(NSString *)htmlString {
  // Prepare response container
  NSMutableDictionary *response = [NSMutableDictionary dictionary];
  
  // Array of places
  NSMutableArray *placeArray = [NSMutableArray array];
  
  // HTML Scraping
  NSError *parserError = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
  HTMLNode *doc = [parser body];
  
  HTMLNode *searchResults = [doc findChildWithAttribute:@"class" matchingName:@"search-results" allowPartial:YES];
  
  NSArray *placeNodes = [searchResults findChildrenWithAttribute:@"class" matchingName:@"biz-listing" allowPartial:YES];
  for (HTMLNode *placeNode in placeNodes) {
    NSMutableDictionary *placeDict = [[NSMutableDictionary alloc] initWithCapacity:8];
    
    // Biz alias
    NSString *alias = [[placeNode getAttributeNamed:@"data-url"] stringByReplacingOccurrencesOfString:@"/biz/" withString:@""];
    [placeDict setObject:alias forKey:@"alias"];
    
    // Name
    NSString *name = [[[[[placeNode findChildTag:@"h3"] contents] componentsMatchedByRegex:@"(?ms)(\\d+\\.)(.+)" capture:2] firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [placeDict setObject:name forKey:@"name"];
    
    // Cover Photo
    NSString *coverPhoto = [[[placeNode findChildTag:@"img"] getAttributeNamed:@"src"] stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"l.jpg"];
    [placeDict setObject:coverPhoto forKey:@"coverPhoto"];
    
    // Category
    NSString *category = [[placeNode findChildTag:@"dd"] contents];
    [placeDict setObject:category forKey:@"category"];
    
    // Price and Distance
    HTMLNode *priceDistance = [placeNode findChildWithAttribute:@"class" matchingName:@"price-distance" allowPartial:YES];
    NSString *distance = [[[[[priceDistance findChildTags:@"li"] firstObject] contents] stringByReplacingOccurrencesOfString:@"mi" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *price = [[[[priceDistance findChildTags:@"li"] lastObject] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [placeDict setObject:distance forKey:@"distance"];
    [placeDict setObject:price forKey:@"price"];
    
    // Rating
    NSString *ratingString = [[placeNode findChildWithAttribute:@"class" matchingName:@"stars" allowPartial:YES] getAttributeNamed:@"class"];
    ratingString = [[ratingString componentsMatchedByRegex:@"(stars-)([^ ]+)" capture:2] firstObject];
    ratingString = [ratingString stringByReplacingOccurrencesOfString:@"_half" withString:@".5"];
    [placeDict setObject:ratingString forKey:@"rating"];
    
    // Score
    double score = ([ratingString doubleValue] / 5.0) * 100.0;
    [placeDict setObject:[NSNumber numberWithDouble:score] forKey:@"score"];
    
    // Number of Reviews
    NSString *numReviews = [[[placeNode findChildWithAttribute:@"class" matchingName:@"review-count" allowPartial:YES] contents] stringByReplacingOccurrencesOfString:@" Reviews" withString:@""];
    [placeDict setObject:numReviews forKey:@"numReviews"];
    
    [placeArray addObject:placeDict];
    [placeDict release];
  }
  
  // Scrape the scripts
  NSArray *scriptNodes = [doc findChildrenWithAttribute:@"type" matchingName:@"text/javascript" allowPartial:NO];
  
  for (HTMLNode *scriptNode in scriptNodes) {
    if ([scriptNode contents] && [[scriptNode contents] rangeOfString:@"yConfig = "].location != NSNotFound) {
      NSString *yConfigJSON = [[scriptNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      yConfigJSON = [yConfigJSON substringWithRange:NSMakeRange(10, [yConfigJSON length] - 11)];
      
      NSDictionary *pageData = [[yConfigJSON objectFromJSONString] objectForKey:@"pageData"];
      
      if (![pageData objectForKey:@"pager"]) break;
      
      // Total results
      NSNumber *numResults = [[pageData objectForKey:@"pager"] objectForKey:@"total"];
      [response setObject:numResults forKey:@"numResults"];
      
      // Paging
      // Num pages
      NSNumber *currentPage = [[pageData objectForKey:@"pager"] objectForKey:@"current_page"];
      
      NSNumber *numPages = [[pageData objectForKey:@"pager"] objectForKey:@"num_pages"];
      
      NSDictionary *pagingDict = [NSDictionary dictionaryWithObjectsAndKeys:currentPage, @"currentPage", numPages, @"numPages", nil];
      [response setObject:pagingDict forKey:@"paging"];
      
      // Process markers
      int i = 0;
      for (NSDictionary *marker in [pageData objectForKey:@"markers"]) {
        NSMutableDictionary *placeDict = [placeArray objectAtIndex:i];
        
        // Lat
        NSNumber *lat = [[[pageData objectForKey:@"markers"] firstObject] objectForKey:@"lat"];
        [placeDict setObject:lat forKey:@"latitude"];
        
        // Lng
        NSNumber *lng = [[[pageData objectForKey:@"markers"] firstObject] objectForKey:@"lng"];
        [placeDict setObject:lng forKey:@"longitude"];
        
        // Biz
        // Stuff scraped here will override previous scraped data if it exists because it's more accurate
        NSDictionary *bizMarker = [marker objectForKey:@"biz"];
        
        // Raw Rating
        NSNumber *rating = [bizMarker objectForKey:@"rating"];
        [placeDict setObject:rating forKey:@"rating"];
        
        // Score
        double score = ([rating doubleValue] / 5.0) * 100.0;
        [placeDict setObject:[NSNumber numberWithDouble:score] forKey:@"score"];
        
        // Alias
        NSString *alias = [bizMarker objectForKey:@"alias"];
        [placeDict setObject:alias forKey:@"alias"];
        
        // Categories
        NSString *category = [bizMarker objectForKey:@"categories"];
        [placeDict setObject:category forKey:@"category"];
        
        // Name
        NSString *name = [bizMarker objectForKey:@"name"];
        [placeDict setObject:name forKey:@"name"];
        
        // Num Reviews
        NSNumber *numReviews = [bizMarker objectForKey:@"review_count"];
        [placeDict setObject:numReviews forKey:@"numReviews"];
        
        i++;
      }
    }
  }
  
  
  // Prepare Response
  [response setObject:placeArray forKey:@"places"];
  
  [parser release];
  
  return response;
}

- (NSDictionary *)scrapeBizWithHTMLString:(NSString *)htmlString {
  // Prepare response container
  NSMutableDictionary *response = [NSMutableDictionary dictionary];
  
  // HTML Scraping
  NSError *parserError = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
  HTMLNode *doc = [parser body];
  
  // Get Biz
  HTMLNode *bizNode = [doc findChildWithAttribute:@"href" matchingName:@"src_bizid" allowPartial:YES];
  if (!bizNode) {
    return nil;
  }
  NSString *biz = [[[bizNode getAttributeNamed:@"href"] stringByMatching:@"(src_bizid=)([^&]+)"] stringByReplacingOccurrencesOfString:@"src_bizid=" withString:@""];
  [response setObject:biz forKey:@"biz"];

  // Hours
  NSArray *hoursNodes = [doc findChildrenWithAttribute:@"class" matchingName:@"hours" allowPartial:NO];
  NSMutableArray *hours = [NSMutableArray array];
  for (HTMLNode *hoursNode in hoursNodes) {
    if (hoursNode.nodetype == HTMLPNode) {
      // Hours
      [hours addObject:[hoursNode contents]];
    } else if (hoursNode.nodetype == HTMLSpanNode) {
      // Open/Closed
    }
  }
  [response setObject:hours forKey:@"hours"];
  
  // Address
  NSString *rawAddress = [[doc findChildTag:@"address"] rawContents];
  rawAddress = [rawAddress stringByReplacingOccurrencesOfString:@"<address class=\"flex-box\">" withString:@""];
  rawAddress = [rawAddress stringByReplacingOccurrencesOfString:@"</address>" withString:@""];
  rawAddress = [rawAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  NSArray *addressArray = [rawAddress componentsSeparatedByString:@"<br>"];
  NSString *address = [rawAddress stringByReplacingOccurrencesOfString:@"<br>" withString:@" "];
  [response setObject:addressArray forKey:@"address"];
  [response setObject:address forKey:@"formattedAddress"];
  
  // Phone
  HTMLNode *phoneNode = [doc findChildWithAttribute:@"href" matchingName:@"tel:" allowPartial:YES];
  NSString *phone = [phoneNode getAttributeNamed:@"href"];
  NSString *phoneString = [phoneNode contents];
  [response setObject:phone forKey:@"phone"];
  [response setObject:phoneString forKey:@"phoneString"];
  
  // Photo
    
  [parser release];
  
  return response;
}

- (NSDictionary *)scrapeReviewsWithHTMLString:(NSString *)htmlString {
  // HTML Scraping
  NSError *parserError = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
  HTMLNode *doc = [parser body];
  
  // Reviews
  NSArray *reviewNodes = [doc findChildrenWithAttribute:@"class" matchingName:@"review-content" allowPartial:YES];
  NSMutableArray *reviews = [NSMutableArray array];
  for (HTMLNode *reviewNode in reviewNodes) {
    NSMutableDictionary *reviewDict = [NSMutableDictionary dictionaryWithCapacity:3];
    // Review ID
    NSString *srid = [[[reviewNode findChildWithAttribute:@"class" matchingName:@"rateReview" allowPartial:NO] getAttributeNamed:@"id"] stringByReplacingOccurrencesOfString:@"ufc_" withString:@""];
    [reviewDict setObject:srid forKey:@"srid"];
    
    // Review Rating
    NSString *rating = [[[reviewNode findChildWithAttribute:@"alt" matchingName:@"star rating" allowPartial:YES] getAttributeNamed:@"alt"] stringByReplacingOccurrencesOfString:@" star rating" withString:@""];
    [reviewDict setObject:rating forKey:@"rating"];
    
    // Review Date
    NSString *date = [[[reviewNode findChildWithAttribute:@"class" matchingName:@"dtreviewed" allowPartial:YES] allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [reviewDict setObject:date forKey:@"date"];
    
    // Review Comment
    NSString *comment = [[reviewNode findChildWithAttribute:@"class" matchingName:@"review_comment" allowPartial:YES] allContents];
    comment ? [reviewDict setObject:comment forKey:@"comment"] : [reviewDict setObject:[NSNull null] forKey:@"comment"];
    
    [reviews addObject:reviewDict];
  }
  
  // Create payload
  NSMutableDictionary *reviewsDict = [NSMutableDictionary dictionary];
  ([reviews count] > 0) ? [reviewsDict setObject:reviews forKey:@"reviews"] : [reviewsDict setObject:[NSNull null] forKey:@"reviews"];
  
  [parser release];
  
  return reviewsDict;
}

@end
