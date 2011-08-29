//
//  PSLocationCenter.m
//  MealTime
//
//  Created by Peter Shih on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSLocationCenter.h"

static NSInteger _distanceFilter = 100;

@implementation PSLocationCenter

@synthesize locationManager = _locationManager;

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
  [super dealloc];
}

#pragma mark - Location Methods
- (void)getMyLocation {
  if (_isUpdating) {
    [self stopUpdates];
  }
  
  [self startUpdates];
}

- (void)startUpdates {
#if TARGET_IPHONE_SIMULATOR
  [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
#else
  if (!_isUpdating) {
    _isUpdating = YES;
    [self startSignificantChangeUpdates];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSignificantChangeUpdates) name:kApplicationResumed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSignificantChangeUpdates) name:kApplicationSuspended object:nil];
  }
#endif
}

- (void)stopUpdates {
#if TARGET_IPHONE_SIMULATOR
  
#else
  _isUpdating = NO;
  [self stopSignificantChangeUpdates];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationResumed object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationSuspended object:nil];
#endif
}

- (void)startStandardUpdates {
  // Create the location manager if this object does not
  // already have one.
  if (!_locationManager) {
    _locationManager = [[CLLocationManager alloc] init];
    
    _locationManager.purpose = nil; // Displayed to user
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    // Set a movement threshold for new events.
    _locationManager.distanceFilter = _distanceFilter;
  }
  
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
  if ([self location]) return YES;
  else return NO;
}

- (CLLocation *)location {
  return self.locationManager.location;
}

- (CGFloat)latitude {
#if TARGET_IPHONE_SIMULATOR
  return 37.32798;
#else
  return self.locationManager.location.coordinate.latitude;
#endif
}

- (CGFloat)longitude {
#if TARGET_IPHONE_SIMULATOR
  return -122.01382;
#else
  return self.locationManager.location.coordinate.longitude;
#endif
}

#pragma mark CLLocationManagerDelegate
// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  
  // If no previous location, always set new location
  if (!oldLocation) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
    return;
  }
  
  if (oldLocation && newLocation) {
    // Check distance and timestamp
    if (fabs([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp]) > 60) {
      [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
    }
    return;
  }

}

@end
