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
  CLLocation *_lastLocation;
  
  NSDate *_startDate;
  
  BOOL _isUpdating;
  BOOL _shouldDisableAfterLocationFix;
  BOOL _shouldMonitorSignificantChange;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL shouldDisableAfterLocationFix;
@property (nonatomic, assign) BOOL shouldMonitorSignificantChange;

+ (id)defaultCenter;

// Public Methods
- (void)getMyLocation;
- (BOOL)hasAcquiredLocation;
- (CLLocation *)location;
- (CLLocationCoordinate2D)locationCoordinate;
- (CGFloat)latitude;
- (CGFloat)longitude;

// Private Methods
- (void)startUpdates;
- (void)stopUpdates;

@end
