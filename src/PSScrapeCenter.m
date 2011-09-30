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
  
  // Parse page
  NSMutableArray *photos = [NSMutableArray array];
  for (HTMLNode *node in photoNodes) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *src = [[node getAttributeNamed:@"src"] stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"l.jpg"];
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
    
    // Biz
    NSString *biz = [[placeNode getAttributeNamed:@"data-url"] stringByReplacingOccurrencesOfString:@"/biz/" withString:@""];
    [placeDict setObject:biz forKey:@"biz"];
    
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
    NSString *distance = [[[[priceDistance findChildTags:@"li"] firstObject] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *price = [[[[priceDistance findChildTags:@"li"] lastObject] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [placeDict setObject:distance forKey:@"distance"];
    [placeDict setObject:price forKey:@"price"];
    
    // Rating
    NSString *ratingString = [[placeNode findChildWithAttribute:@"class" matchingName:@"stars" allowPartial:YES] getAttributeNamed:@"class"];
    ratingString = [[ratingString componentsMatchedByRegex:@"(stars-)([^ ]+)" capture:2] firstObject];
    ratingString = [ratingString stringByReplacingOccurrencesOfString:@"_half" withString:@".5"];
    [placeDict setObject:ratingString forKey:@"rating"];
    
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
      NSString *yConfigJSON = [scriptNode contents];
      yConfigJSON = [[yConfigJSON componentsMatchedByRegex:@"(yConfig = )([^;]+)" capture:2] firstObject];
      
      NSDictionary *pageData = [[yConfigJSON objectFromJSONString] objectForKey:@"pageData"];
      
      // Total results
      NSString *numResults = [[pageData objectForKey:@"pager"] objectForKey:@"total"];
      [response setObject:numResults forKey:@"numResults"];
      
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
        
        // Alias
        NSString *alias = [bizMarker objectForKey:@"alias"];
        [placeDict setObject:alias forKey:@"alias"];
        
        // Categories
        NSString *categories = [bizMarker objectForKey:@"categories"];
        [placeDict setObject:categories forKey:@"categories"];
        
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
  
  return response;
}

- (NSDictionary *)oldscrapePlacesWithHTMLString:(NSString *)htmlString {
  // Prepare response container
  NSMutableDictionary *placeDict = [NSMutableDictionary dictionary];
  
  // HTML Scraping
  NSError *parserError = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
  HTMLNode *doc = [parser body];
  
  HTMLNode *mainContentNode = [doc findChildWithAttribute:@"id" matchingName:@"mainContent" allowPartial:YES];
//  NSString *mainContent = [mainContentNode rawContents];
  
  // Num Results
  NSString *numResults = [[[mainContentNode rawContents] componentsMatchedByRegex:@"(\\d+) results" capture:1] firstObject];
  numResults ? [placeDict setObject:numResults forKey:@"numResults"] : [placeDict setObject:@"0" forKey:@"numResults"];
  
  // Num Pages
  NSString *pager = [[mainContentNode findChildWithAttribute:@"class" matchingName:@"pager_current" allowPartial:YES] contents];
  NSString *currentPage = [[pager componentsMatchedByRegex:@"(?:Page )(\\d+)(?: of )(\\d+)" capture:1] lastObject];
  NSString *numPages = [[pager componentsMatchedByRegex:@"(?:Page )(\\d+)(?: of )(\\d+)" capture:2] lastObject];
  NSDictionary *pagingDict = [NSDictionary dictionaryWithObjectsAndKeys:currentPage, @"currentPage", numPages, @"numPages", nil];
  [placeDict setObject:pagingDict forKey:@"paging"];
  
  
  NSArray *addressNodes = [mainContentNode findChildrenWithAttribute:@"class" matchingName:@"address" allowPartial:YES];
  
  NSMutableArray *placeArray = [NSMutableArray array];
  int i = 0;
  for (HTMLNode *node in addressNodes) {
    // Check number of reviews
    NSString *numreviews = [[node rawContents] stringByMatching:@"\\d+ reviews"];
    if (numreviews) numreviews = [numreviews stringByReplacingOccurrencesOfString:@" reviews" withString:@""];
    if (!numreviews || [numreviews isEqualToString:@"0"]) {
      continue;
    }
    
    NSNumber *index = [NSNumber numberWithInt:i]; // Popularity index
    HTMLNode *bizNode = [node findChildWithAttribute:@"href" matchingName:@"/biz/" allowPartial:YES];
    NSString *biz = [[bizNode getAttributeNamed:@"href"] stringByReplacingOccurrencesOfString:@"/biz/" withString:@""];
    NSString *name = [[[bizNode contents] stringByUnescapingHTML] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *rating = [[[node findChildWithAttribute:@"alt" matchingName:@"star rating" allowPartial:YES] getAttributeNamed:@"alt"] stringByReplacingOccurrencesOfString:@" star rating" withString:@""];
    NSString *phone = [[node findChildWithAttribute:@"title" matchingName:@"Call" allowPartial:YES] contents];
    NSString *price = [[node rawContents] stringByMatching:@"Price: [$]+"];
    if (price) price = [price stringByReplacingOccurrencesOfString:@"Price: " withString:@""];
    NSString *category = [[node rawContents] stringByMatching:@"Category: [^<]+"];
    if (category) category = [[category stringByReplacingOccurrencesOfString:@"Category: " withString:@""] stringByUnescapingHTML];
    NSString *distance = [[node rawContents] stringByMatching:@"\\d+\\.\\d+ miles"];
    if (distance) distance = [distance stringByReplacingOccurrencesOfString:@" miles" withString:@""];
    else distance = @"0.0";
    
    // Calculate composite rating
    NSString *score = nil;
    if (rating && numreviews) {
      CGFloat rawRating = [rating floatValue];
      CGFloat rawNumReviews = [numreviews floatValue];
      CGFloat baseRating = (rawRating / 5.0) * 100.0;
      
      CGFloat reviewModifier = MIN(fabsf(logf(rawNumReviews - 200)), 10);
      
      reviewModifier *= (rawNumReviews - 200 > 0) ? 1 : -1;
      
      CGFloat adjustedRating = MIN(roundf(baseRating + reviewModifier), 100);
      
      score = [NSString stringWithFormat:@"%.0f", adjustedRating];
    } else {
      score = @"0";
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
//  http://www.yelp.com/biz/alexanders-steakhouse-cupertino?rpp=9999&sort_by=relevance_desc
  // HTML Scraping
  NSError *parserError = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
  HTMLNode *doc = [parser body];
  
//  HTMLNode *mainContentNode = [doc findChildWithAttribute:@"id" matchingName:@"mainContent" allowPartial:YES];
  //  NSString *mainContent = [mainContentNode rawContents];
  
//  <dd class="attr-BusinessHours"><p class="hours">Mon-Thu 5:30 pm - 9:30 pm</p>
//  <p class="hours">Tue-Fri 11:30 am - 2 pm</p>
//  <p class="hours">Fri-Sat 5:30 pm - 10:30 pm</p>
//  <p class="hours">Sun 5:30 pm - 9 pm</p></dd>
  
  // Create output payload
  NSMutableDictionary *bizDict = [NSMutableDictionary dictionary];
  
  // Review Summary Snippets
  HTMLNode *summaryNode = [doc findChildWithAttribute:@"id" matchingName:@"review_summaries" allowPartial:NO];
  NSArray *snippetsNodes = [summaryNode findChildrenWithAttribute:@"class" matchingName:@"snippet" allowPartial:NO];
  NSMutableArray *snippets = [NSMutableArray arrayWithCapacity:3];
  for (HTMLNode *snippetNode in snippetsNodes) {
    NSString *snippet = [[[snippetNode allContents] componentsMatchedByRegex:@"\"(.+)\"" capture:1] lastObject];
    [snippets addObject:snippet];
  }
  ([snippets count] > 0) ? [bizDict setObject:snippets forKey:@"snippets"] : [bizDict setObject:[NSNull null] forKey:@"snippets"];
  
  // Hours
  NSArray *hourNodes = [doc findChildrenWithAttribute:@"class" matchingName:@"hours" allowPartial:NO];
  NSMutableArray *hours = [NSMutableArray array];
  for (HTMLNode *hourNode in hourNodes) {
    [hours addObject:[hourNode contents]];
  }
  ([hours count] > 0) ? [bizDict setObject:hours forKey:@"hours"] : [bizDict setObject:[NSNull null] forKey:@"hours"];
  
  // Scrape bizdetails json
  NSDictionary *bizDetails = nil;
  NSArray *scriptNodes = [doc findChildrenWithAttribute:@"type" matchingName:@"text/javascript" allowPartial:NO];
  for (HTMLNode *scriptNode in scriptNodes) {
    if ([[scriptNode allContents] rangeOfString:@"yelp.init.bizDetails"].location != NSNotFound) {
      NSString *bizDetailsJSON = [[[scriptNode allContents] componentsMatchedByRegex:@"(yelp\\.init\\.wrapper\\(\"yelp\\.init\\.bizDetails\\.page\", )(.+)(\\);)" capture:2] lastObject];
      bizDetails = [bizDetailsJSON objectFromJSONString];
      NSDictionary *bizSafe = [bizDetails objectForKey:@"bizSafe"];
      if (bizSafe) {
        [bizDict setObject:[bizSafe objectForKey:@"formatted_address"] forKey:@"address"];
        [bizDict setObject:[bizSafe objectForKey:@"city"] forKey:@"city"];
        [bizDict setObject:[bizSafe objectForKey:@"state"] forKey:@"state"];
        [bizDict setObject:[bizSafe objectForKey:@"zip"] forKey:@"zip"];
        [bizDict setObject:[bizSafe objectForKey:@"country"] forKey:@"country"];
        [bizDict setObject:[bizSafe objectForKey:@"latitude"] forKey:@"latitude"];
        [bizDict setObject:[bizSafe objectForKey:@"longitude"] forKey:@"longitude"];
        
//        NSArray *bizPhotos = [bizSafe objectForKey:@"photos"];
//        [bizDict setObject:bizPhotos forKey:@"photos"];
//        DLog(@"bizPhotos: %@", bizPhotos);
        
//        NSArray *bizCategories = [bizSafe objectForKey:@"category_yelp_ids"];
//        [bizDict setObject:bizCategories forKey:@"bizcategories"];
      } else {
        [bizDict setObject:[NSNull null] forKey:@"address"];
        [bizDict setObject:[NSNull null] forKey:@"latitude"];
        [bizDict setObject:[NSNull null] forKey:@"longitude"];
        [bizDict setObject:[NSNull null] forKey:@"photos"];
      }
    }
  }
  (bizDetails) ? [bizDict setObject:bizDetails forKey:@"bizDetails"] : [bizDict setObject:[NSNull null] forKey:@"bizDetails"];
  
  [parser release];
  
  return bizDict;
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

//- (NSDictionary *)scrapeBizWithHTMLString:(NSString *)htmlString {
//  // HTML Scraping
//  NSError *parserError = nil;
//  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
//  HTMLNode *doc = [parser body];
//  
//  HTMLNode *mainContentNode = [doc findChildWithAttribute:@"id" matchingName:@"mainContent" allowPartial:YES];
//  //  NSString *mainContent = [mainContentNode rawContents];
//
//  NSString *hours = [[[mainContentNode rawContents] stringByMatching:@"(?ms)Hours:[^<]+.*View Photos</a>"] stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
//  hours = [hours stringByMatching:@"Hours:[^<]+"];
//  hours = [hours stringByReplacingOccurrencesOfRegex:@"\\s+" withString:@" "];
//  hours = [hours stringByReplacingOccurrencesOfRegex:@"Hours: " withString:@""];
//  NSArray *reviews = [NSArray array];
//  
//  // Create payload
//  NSMutableDictionary *bizDict = [NSMutableDictionary dictionary];
//  hours ? [bizDict setObject:hours forKey:@"hours"] : [bizDict setObject:[NSNull null] forKey:@"hours"];
//  reviews ? [bizDict setObject:reviews forKey:@"reviews"] : [bizDict setObject:[NSNull null] forKey:@"reviews"];
//  
//  [parser release];
//  
//  // Hours:[^<]+.*View Photos</a>
//  return bizDict;
//}

@end
