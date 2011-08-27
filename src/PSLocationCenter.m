//
//  PSLocationCenter.m
//  MealTime
//
//  Created by Peter Shih on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSLocationCenter.h"

static NSInteger _distanceFilter = 1000;

@implementation PSLocationCenter

@synthesize locationManager = _locationManager;
@synthesize oldLocation = _oldLocation;
@synthesize currentLocation = _currentLocation;

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
    _isUpdating = NO;
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_locationManager);
  RELEASE_SAFELY(_oldLocation);
  RELEASE_SAFELY(_currentLocation);
  [super dealloc];
}

#pragma mark - Location Methods
- (void)getMyLocation {
  if (self.currentLocation && _isUpdating) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
  } else {
    [self startUpdates];
  }
}

- (void)startUpdates {
#if TARGET_IPHONE_SIMULATOR
  [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
#else
  if (!_isUpdating) {
    _isUpdating = YES;
    [self startSignificantChangeUpdates];
  }
#endif
}

- (void)stopUpdates {
#if TARGET_IPHONE_SIMULATOR
  
#else
  _isUpdating = NO;
  [self stopSignificantChangeUpdates];
#endif
}

- (void)startStandardUpdates {
  // Create the location manager if this object does not
  // already have one.
  if (nil == _locationManager)
    _locationManager = [[CLLocationManager alloc] init];
  
  self.locationManager.delegate = self;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
  
  // Set a movement threshold for new events.
  self.locationManager.distanceFilter = _distanceFilter;
  
  [self.locationManager startUpdatingLocation];
}

- (void)stopStandardUpdates {
  [self.locationManager stopUpdatingLocation];
}

- (void)startSignificantChangeUpdates {
  // Create the location manager if this object does not
  // already have one.
  if (nil == _locationManager)
    _locationManager = [[CLLocationManager alloc] init];
  
  self.locationManager.delegate = self;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
  [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopSignificantChangeUpdates {
  [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (BOOL)hasAcquiredLocation {
  if (self.currentLocation) return YES;
  else return NO;
}

- (CGFloat)latitude {
#if TARGET_IPHONE_SIMULATOR
  return 37.32798;
#else
  return self.currentLocation.coordinate.latitude;
#endif
}

- (CGFloat)longitude {
#if TARGET_IPHONE_SIMULATOR
  return -122.01382;
#else
  return self.currentLocation.coordinate.longitude;
#endif
}

#pragma mark CLLocationManagerDelegate
// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  
  self.currentLocation = newLocation;
  [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
  
  // Check Timestamp to determine if this was cached
//  NSDate *locTimestamp = newLocation.timestamp;
//  if (fabs([locTimestamp timeIntervalSinceDate:[NSDate date]]) <= 60) {
//    self.currentLocation = newLocation;
//    self.oldLocation = oldLocation;
//    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
//  }
}

@end
