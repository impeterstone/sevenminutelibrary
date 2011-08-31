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
    
    // Create the location manager if this object does not
    // already have one.
    if (!_locationManager) {
      _locationManager = [[CLLocationManager alloc] init];
      
      //    _locationManager.purpose = nil; // Displayed to user
      
      _locationManager.delegate = self;
      _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
      
      // Set a movement threshold for new events.
      _locationManager.distanceFilter = _distanceFilter;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUpdates) name:kApplicationResumed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopUpdates) name:kApplicationSuspended object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationResumed object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationSuspended object:nil];
  
  RELEASE_SAFELY(_locationManager);
  [super dealloc];
}

#pragma mark - Location Methods
- (void)getMyLocation {
  // Force acquiring a new location
  [self stopUpdates];  
  [self startUpdates];
}

- (void)startUpdates {
#if TARGET_IPHONE_SIMULATOR
  [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
#else
  if (!_isUpdating) {
    _isUpdating = YES;
    
    // Check location capabilities
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
      [self startStandardUpdates];
      [self startSignificantChangeUpdates];
    } else {
      [self startStandardUpdates];
    }
  }
#endif
}

- (void)stopUpdates {
#if TARGET_IPHONE_SIMULATOR
  
#else
  if (_isUpdating) {
    _isUpdating = NO;
  
    // Check location capabilities
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
      [self stopStandardUpdates];
      [self stopSignificantChangeUpdates];
    } else {
      [self stopStandardUpdates];
    }
  }
#endif
}

- (void)startStandardUpdates {
  [self.locationManager startUpdatingLocation];
}

- (void)stopStandardUpdates {
  [self.locationManager stopUpdatingLocation];
}

- (void)startSignificantChangeUpdates {
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

- (CLLocationCoordinate2D)locationCoordinate {
  return [self.locationManager.location coordinate];
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
  
  // Check distance and timestamp
  //    if (fabs([newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp]) > 60) {
  //    }
  
  CLLocationAccuracy accuracy = newLocation.horizontalAccuracy;
  if (accuracy >= _distanceFilter) {
    // Too much uncertainty
    DLog(@"Location discarded due to accuracy: %@, oldLocation: %@, accuracy: %g", newLocation, oldLocation, accuracy);
  } else if (!oldLocation) {
    // If no previous location, always set new location
    if ([[NSDate date] timeIntervalSinceDate:newLocation.timestamp] < 300) {
      [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
      DLog(@"Location updated: %@, oldLocation: %@, accuracy: %g", newLocation, oldLocation, accuracy);
    } else {
      DLog(@"Location discarded due to age: %@, oldLocation: %@, accuracy: %g", newLocation, oldLocation, accuracy);
    }
  } else if (oldLocation && newLocation && [oldLocation distanceFromLocation:newLocation] > 0) {
    // Check if distance changed
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];

    DLog(@"Location updated: %@, oldLocation: %@, accuracy: %g", newLocation, oldLocation, accuracy);
  } else {
    // Location unchanged
    DLog(@"Location discarded: %@, oldLocation: %@, accuracy: %g", newLocation, oldLocation, accuracy);
  }

}

@end
