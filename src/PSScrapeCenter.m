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
- (NSDictionary *)scrapePhotosWithHTMLString:(NSString *)htmlString {
  // HTML Scraping
  NSError *parserError = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
  HTMLNode *doc = [parser body];
  
  HTMLNode *mainContentNode = [doc findChildWithAttribute:@"id" matchingName:@"mainContent" allowPartial:YES];
  
  NSString *numPhotos = [[mainContentNode rawContents] stringByMatching:@"\\d+ Photos from"];
  if (numPhotos) numPhotos = [numPhotos stringByReplacingOccurrencesOfString:@" Photos from" withString:@""];
  
  NSArray *photoNodes = [mainContentNode findChildTags:@"img"];
  
  NSMutableArray *photos = [NSMutableArray array];
  for (HTMLNode *node in photoNodes) {
    NSString *src = [[node getAttributeNamed:@"src"] stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"l.jpg"];
    
    NSString *alt = [node getAttributeNamed:@"alt"];
    
    NSDictionary *photoDict = [NSDictionary dictionaryWithObjectsAndKeys:src, @"src", alt, @"alt", nil];
    [photos addObject:photoDict];
  }
  
  [parser release];
  
  NSDictionary *photoDict = [NSDictionary dictionaryWithObjectsAndKeys:numPhotos, @"numPhotos", photos, @"photos", nil];
  
  VLog(@"Photos: %@", photoDict);
  
  return photoDict;
}

- (NSDictionary *)scrapePlacesWithHTMLString:(NSString *)htmlString {
  // HTML Scraping
  NSError *parserError = nil;
  HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&parserError];
  HTMLNode *doc = [parser body];
  
  HTMLNode *mainContentNode = [doc findChildWithAttribute:@"id" matchingName:@"mainContent" allowPartial:YES];
//  NSString *mainContent = [mainContentNode rawContents];
  
  NSArray *addressNodes = [mainContentNode findChildrenWithAttribute:@"class" matchingName:@"address" allowPartial:YES];
  
  NSMutableArray *placeArray = [NSMutableArray array];
  int i = 0;
  for (HTMLNode *node in addressNodes) {
    NSNumber *index = [NSNumber numberWithInt:i]; // Popularity index
    HTMLNode *bizNode = [node findChildWithAttribute:@"href" matchingName:@"/biz/" allowPartial:YES];
    NSString *biz = [[bizNode getAttributeNamed:@"href"] stringByReplacingOccurrencesOfString:@"/biz/" withString:@""];
    NSString *name = [bizNode contents];
    NSString *rating = [[[node findChildWithAttribute:@"alt" matchingName:@"star rating" allowPartial:YES] getAttributeNamed:@"alt"] stringByReplacingOccurrencesOfString:@" star rating" withString:@""];
    NSString *phone = [[node findChildWithAttribute:@"title" matchingName:@"Call" allowPartial:YES] contents];
    NSString *reviews = [[node rawContents] stringByMatching:@"\\d+ reviews"];
    if (reviews) reviews = [reviews stringByReplacingOccurrencesOfString:@" reviews" withString:@""];
    NSString *price = [[node rawContents] stringByMatching:@"Price: [$]+"];
    if (price) price = [price stringByReplacingOccurrencesOfString:@"Price: " withString:@""];
    NSString *category = [[node rawContents] stringByMatching:@"Category: .+"];
    if (category) category = [category stringByReplacingOccurrencesOfString:@"Category: " withString:@""];
    NSString *distance = [[node rawContents] stringByMatching:@"\\d+\\.\\d+ miles"];
    if (distance) distance = [distance stringByReplacingOccurrencesOfString:@" miles" withString:@""];
    NSString *city = [[node rawContents] stringByMatching:@"(?m)^\\w+, \\w{2}"];
    
    // Create payload, add to array
    NSMutableDictionary *placeDict = [NSMutableDictionary dictionary];
    if (index) [placeDict setObject:index forKey:@"index"];
    if (biz) [placeDict setObject:biz forKey:@"biz"];
    if (name) [placeDict setObject:name forKey:@"name"];
    if (rating) [placeDict setObject:rating forKey:@"rating"];
    if (phone) [placeDict setObject:phone forKey:@"phone"];
    if (reviews) [placeDict setObject:reviews forKey:@"reviews"];
    if (price) [placeDict setObject:price forKey:@"price"];
    if (category) [placeDict setObject:category forKey:@"category"];
    if (distance) [placeDict setObject:distance forKey:@"distance"];
    if (city) [placeDict setObject:city forKey:@"city"];
     
    [placeArray addObject:placeDict];
    
    i++;
  }
  
  NSDictionary *placeDict = [NSDictionary dictionaryWithObject:placeArray forKey:@"places"];
  
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
  
  NSDictionary *mapDict = [NSDictionary dictionaryWithObjectsAndKeys:address, @"address", coordinates, @"coordinates", nil];
  
  return mapDict;
}

@end
