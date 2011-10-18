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

static NSSet *_categories = nil;

@implementation PSScrapeCenter

+ (void)initialize {
  _categories = [[NSSet setWithArray:[CATEGORIES componentsSeparatedByString:@"|"]] retain];
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
    
    [placeDict setObject:[NSNumber numberWithBool:YES] forKey:@"valid"];
    
    // Category (Primary)
    NSArray *nc = [placeNode findChildTags:@"dd"];
    NSString *category = [[nc lastObject] contents];
    if (category) {
      // IMPORTANT
      // If category is not a food category, discard it
      NSSet *filteredSet = [_categories filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", category]];
      if ([filteredSet count] > 0) {
        [placeDict setObject:category forKey:@"category"];
      } else {
        NSLog(@"discarding category: %@", category);
        [placeDict setObject:[NSNull null] forKey:@"category"];
        [placeDict setObject:[NSNumber numberWithBool:NO] forKey:@"valid"];
      }
    }
    
    // IMPORTANT
    // Cover Photo
    NSString *coverPhoto = [[[placeNode findChildTag:@"img"] getAttributeNamed:@"src"] stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"l.jpg"];
    
    // IF coverphoto is a placeholder, discard it
    if ([coverPhoto rangeOfString:@"blank"].location == NSNotFound) {
      [placeDict setObject:coverPhoto forKey:@"coverPhoto"];
    } else {
      [placeDict setObject:[NSNull null] forKey:@"coverPhoto"];
      [placeDict setObject:[NSNumber numberWithBool:NO] forKey:@"valid"];
    }
    
    // Biz alias
    NSString *alias = [[placeNode getAttributeNamed:@"data-url"] stringByReplacingOccurrencesOfString:@"/biz/" withString:@""];
    [placeDict setObject:alias forKey:@"alias"];
    
    // Name
    NSString *name = [[[[[placeNode findChildTag:@"h3"] contents] componentsMatchedByRegex:@"(?ms)(\\d+\\.)(.+)" capture:2] firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [placeDict setObject:name forKey:@"name"];
    

    
    // Price and Distance
    HTMLNode *priceDistance = [placeNode findChildWithAttribute:@"class" matchingName:@"price-distance" allowPartial:YES];
    NSArray *pdChildren = [priceDistance findChildTags:@"li"];
    if ([pdChildren count] > 0) {
      NSString *distance = [[[[[priceDistance findChildTags:@"li"] firstObject] contents] stringByReplacingOccurrencesOfString:@"mi" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      [placeDict setObject:distance forKey:@"distance"];
      
      if ([pdChildren count] > 1) {
        NSString *price = [[[[priceDistance findChildTags:@"li"] lastObject] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [placeDict setObject:price forKey:@"price"];
      }
    }
    
    // Rating
    HTMLNode *ratingNode = [placeNode findChildWithAttribute:@"class" matchingName:@"stars" allowPartial:YES];
    if (ratingNode) {
      NSString *ratingString = [ratingNode getAttributeNamed:@"class"];
      ratingString = [[ratingString componentsMatchedByRegex:@"(stars-)([^ ]+)" capture:2] firstObject];
      ratingString = [ratingString stringByReplacingOccurrencesOfString:@"_half" withString:@".5"];
      [placeDict setObject:ratingString forKey:@"rating"];
      
      // Score
      double score = ([ratingString doubleValue] / 5.0) * 100.0;
      [placeDict setObject:[NSNumber numberWithDouble:score] forKey:@"score"];
    } else {
      [placeDict setObject:@"0" forKey:@"rating"];
      [placeDict setObject:[NSNumber numberWithDouble:0] forKey:@"score"];
    }
    
    // Number of Reviews
    HTMLNode *numReviewsNode = [placeNode findChildWithAttribute:@"class" matchingName:@"review-count" allowPartial:YES];
    if (numReviewsNode) {
      NSString *numReviews = [[numReviewsNode contents] stringByReplacingOccurrencesOfString:@" Reviews" withString:@""];
      [placeDict setObject:numReviews forKey:@"numReviews"];
    } else {
      [placeDict setObject:@"0" forKey:@"numReviews"];
    }
    
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
        NSNumber *lat = [marker objectForKey:@"lat"];
        [placeDict setObject:lat forKey:@"latitude"];
        
        // Lng
        NSNumber *lng = [marker objectForKey:@"lng"];
        [placeDict setObject:lng forKey:@"longitude"];
        
        // Biz
        // Stuff scraped here will override previous scraped data if it exists because it's more accurate
        NSDictionary *bizMarker = [marker objectForKey:@"biz"];
        
        // Raw Rating
        NSNumber *rating = [bizMarker objectForKey:@"rating"];
        [placeDict setObject:rating forKey:@"rating"];
        
        // Score
        if ([rating notNil]) {
          double score = ([rating doubleValue] / 5.0) * 100.0;
          [placeDict setObject:[NSNumber numberWithDouble:score] forKey:@"score"];
        } else {
          [placeDict setObject:[NSNumber numberWithInt:0] forKey:@"score"];
        }
        
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
  
  [placeArray filterUsingPredicate:[NSPredicate predicateWithFormat:@"valid == 1"]];
  
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
  NSString *biz = nil;
  HTMLNode *bizPhotos = [doc findChildWithAttribute:@"class" matchingName:@"biz-photos" allowPartial:YES];
  if (bizPhotos) {
    NSArray *pageLinks = [doc findChildrenWithAttribute:@"data-url" matchingName:@"biz_photos" allowPartial:YES];
    if ([pageLinks count] > 0) {
      NSString *dataUrl = [[pageLinks firstObject] getAttributeNamed:@"data-url"];
      biz = [[dataUrl componentsMatchedByRegex:@"(/biz_photos/)([^?]+)" capture:2] firstObject];
      if (biz) {
        [response setObject:biz forKey:@"biz"];
      }
    }
  }
  
  // Biz wasn't found, try fallback #1
//  if (!biz) {
//    HTMLNode *bizNode = [doc findChildWithAttribute:@"href" matchingName:@"src_bizid" allowPartial:YES];
//    if (bizNode) {
//      biz = [[[bizNode getAttributeNamed:@"href"] stringByMatching:@"(src_bizid=)([^&]+)"] stringByReplacingOccurrencesOfString:@"src_bizid=" withString:@""];
//      if (biz) {
//        [response setObject:biz forKey:@"biz"];
//      }
//    }
//  }
  
  // No Biz means no photos
  // respond accordingly

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
  
  NSString *doubleTrimmed = [rawAddress stringByReplacingOccurrencesOfString:@"[ \r\n\t]+" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, rawAddress.length)];
  NSString *foundationTrimmed = [doubleTrimmed stringByReplacingOccurrencesOfString:@"^[ \r\n\t]+(.*)[ \r\n\t]+$" withString:@"$1" options:NSRegularExpressionSearch range:NSMakeRange(0, doubleTrimmed.length)];
  
  NSString *cleanAddress = nil;
  cleanAddress = [foundationTrimmed stringByReplacingOccurrencesOfString:@"<address class=\"flex-box\">" withString:@""];
  cleanAddress = [cleanAddress stringByReplacingOccurrencesOfString:@"</address>" withString:@""];
  
  NSArray *rawAddressArray = [cleanAddress componentsSeparatedByString:@"<br>"];
  NSMutableArray *addressArray = [NSMutableArray arrayWithCapacity:1];
  for (NSString *a in rawAddressArray) {
    [addressArray addObject:[[a stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByUnescapingHTML]];
  }
  NSString *formattedAddress = [addressArray componentsJoinedByString:@", "];
  
  [response setObject:addressArray forKey:@"address"];
  [response setObject:formattedAddress forKey:@"formattedAddress"];
  
  // Phone
  HTMLNode *phoneNode = [doc findChildWithAttribute:@"href" matchingName:@"tel:" allowPartial:YES];
  if (phoneNode) {
    NSString *phone = [phoneNode getAttributeNamed:@"href"];
    NSString *formattedPhone = [phoneNode contents];
    [response setObject:phone forKey:@"phone"];
    [response setObject:formattedPhone forKey:@"formattedPhone"];
  }
  
  // Scrape the scripts
  NSArray *scriptNodes = [doc findChildrenWithAttribute:@"type" matchingName:@"text/javascript" allowPartial:NO];
  
  for (HTMLNode *scriptNode in scriptNodes) {
    if ([scriptNode contents] && [[scriptNode contents] rangeOfString:@"yConfig = "].location != NSNotFound) {
      NSString *yConfigJSON = [[scriptNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      yConfigJSON = [yConfigJSON substringWithRange:NSMakeRange(10, [yConfigJSON length] - 11)];
      
      NSDictionary *pageData = [[yConfigJSON objectFromJSONString] objectForKey:@"pageData"];
      NSDictionary *attrs = [pageData objectForKey:@"googlead_attrs"];
      if (attrs) {
        [response setObject:attrs forKey:@"attrs"];
      }
    }
  }
  
  [parser release];
  
  return response;
}

- (NSDictionary *)scrapeReviewsWithHTMLString:(NSString *)htmlString {
  // Prepare response container
  NSMutableDictionary *response = [NSMutableDictionary dictionary];
  
  // HTML Scraping
  NSError *parserError = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
  HTMLNode *doc = [parser body];
  
  // Reviews
  NSArray *fullReviewNodes = [doc findChildrenWithAttribute:@"class" matchingName:@"review-full" allowPartial:YES];
  NSMutableArray *reviews = [NSMutableArray array];
  for (HTMLNode *fullReviewNode in fullReviewNodes) {
    NSString *reviewString = [[fullReviewNode allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [reviews addObject:reviewString];
  }
  [response setObject:reviews forKey:@"reviews"];
  
//  NSArray *reviewNodes = [doc findChildrenWithAttribute:@"class" matchingName:@"review-content" allowPartial:YES];
//  NSMutableArray *reviews = [NSMutableArray array];
//  for (HTMLNode *reviewNode in reviewNodes) {
//    NSMutableDictionary *reviewDict = [NSMutableDictionary dictionaryWithCapacity:3];
//    // Review ID
//    NSString *srid = [[[reviewNode findChildWithAttribute:@"class" matchingName:@"rateReview" allowPartial:NO] getAttributeNamed:@"id"] stringByReplacingOccurrencesOfString:@"ufc_" withString:@""];
//    [reviewDict setObject:srid forKey:@"srid"];
//    
//    // Review Rating
//    NSString *rating = [[[reviewNode findChildWithAttribute:@"alt" matchingName:@"star rating" allowPartial:YES] getAttributeNamed:@"alt"] stringByReplacingOccurrencesOfString:@" star rating" withString:@""];
//    [reviewDict setObject:rating forKey:@"rating"];
//    
//    // Review Date
//    NSString *date = [[[reviewNode findChildWithAttribute:@"class" matchingName:@"dtreviewed" allowPartial:YES] allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    [reviewDict setObject:date forKey:@"date"];
//    
//    // Review Comment
//    NSString *comment = [[reviewNode findChildWithAttribute:@"class" matchingName:@"review_comment" allowPartial:YES] allContents];
//    comment ? [reviewDict setObject:comment forKey:@"comment"] : [reviewDict setObject:[NSNull null] forKey:@"comment"];
//    
//    [reviews addObject:reviewDict];
//  }
//  
//  // Create payload
//  NSMutableDictionary *reviewsDict = [NSMutableDictionary dictionary];
//  ([reviews count] > 0) ? [reviewsDict setObject:reviews forKey:@"reviews"] : [reviewsDict setObject:[NSNull null] forKey:@"reviews"];
  
  [parser release];
  
  return response;
}

@end
