//
//  PSSearchCenter.h
//  Moogle
//
//  Created by Peter Shih on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSObject.h"

@interface PSSearchCenter : PSObject {
  NSMutableDictionary *_terms;
}

+ (PSSearchCenter *)defaultCenter;

- (NSDictionary *)sessionTerms;
- (NSDictionary *)savedTerms;
- (NSArray *)searchResultsForTerm:(NSString *)term;

- (BOOL)addTerm:(NSString *)term;

@end
