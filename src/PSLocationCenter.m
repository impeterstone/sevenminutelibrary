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
@synthesize shouldDisableAfterLocationFix = _shouldDisableAfterLocationFix;
@synthesize shouldMonitorSignificantChange = _shouldMonitorSignificantChange;

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
    _shouldDisableAfterLocationFix = NO;
    _shouldMonitorSignificantChange = NO;
    
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
  }
  return self;
}

- (void)dealloc {  
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
    if ([CLLocationManager significantLocationChangeMonitoringAvailable] && _shouldMonitorSignificantChange) {
      [self.locationManager startUpdatingLocation];
      [self.locationManager startMonitoringSignificantLocationChanges];
      
      [[NSNotificationCenter defaultCenter] addObserver:self.locationManager selector:@selector(startMonitoringSignificantLocationChanges) name:kApplicationResumed object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self.locationManager selector:@selector(stopMonitoringSignificantLocationChanges) name:kApplicationSuspended object:nil];
    } else {
      [self.locationManager startUpdatingLocation];
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
    if ([CLLocationManager significantLocationChangeMonitoringAvailable] && _shouldMonitorSignificantChange) {
      [self.locationManager stopUpdatingLocation];
      [self.locationManager stopMonitoringSignificantLocationChanges];
      
      [[NSNotificationCenter defaultCenter] removeObserver:self.locationManager name:kApplicationResumed object:nil];
      [[NSNotificationCenter defaultCenter] removeObserver:self.locationManager name:kApplicationSuspended object:nil];
    } else {
      [self.locationManager stopUpdatingLocation];
    }
  }
#endif
}

#pragma mark - Public Accessors
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
  /**
   Reasons to discard location
   1. Accuracy is bad (greater than threshold)
   2. Location is stale (older than 300 seconds)
   3. Location distance change is less than threshold
   */
  CLLocationAccuracy accuracy = newLocation.horizontalAccuracy;
  NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:newLocation.timestamp];
  CLLocationDistance distance = [newLocation distanceFromLocation:oldLocation];
  
  if ((accuracy >= _distanceFilter) || (age >= 300) || (distance < _distanceFilter)) {
    // Location Discarded
    DLog(@"Location discarded: %@, oldLocation: %@, accuracy: %g, age: %g, distanceChanged: %g", newLocation, oldLocation, accuracy, age, distance);
  } else {
    // Location Acquired
    DLog(@"Location updated: %@, oldLocation: %@, accuracy: %g, age: %g, distanceChanged: %g", newLocation, oldLocation, accuracy, age, distance);
    
    if (_shouldDisableAfterLocationFix) {
      [self stopUpdates];
    }
    
    // Post Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
  }
}

@end
