//
//  PSLocationCenter.h
//  MealTime
//
//  Created by Peter Shih on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "PSObject.h"

@interface PSLocationCenter : PSObject <CLLocationManagerDelegate> {
  CLLocationManager *_locationManager;
  CLLocation *_oldLocation;
  CLLocation *_currentLocation;
  
  BOOL _isUpdating;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *oldLocation;
@property (nonatomic, retain) CLLocation *currentLocation;

+ (id)defaultCenter;

// Public Methods
- (void)getMyLocation;
- (BOOL)hasAcquiredLocation;
- (CGFloat)latitude;
- (CGFloat)longitude;

// Private Methods
- (void)startUpdates;
- (void)stopUpdates;

- (void)startStandardUpdates;
- (void)stopStandardUpdates;

- (void)startSignificantChangeUpdates;
- (void)stopSignificantChangeUpdates;

@end
