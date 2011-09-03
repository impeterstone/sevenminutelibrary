//
//  PSLocationCenter.m
//  MealTime
//
//  Created by Peter Shih on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSLocationCenter.h"
#import "PSToastCenter.h"

static NSInteger _distanceFilter = 300; // meters
static NSInteger _ageFilter = 300; // seconds

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
    
    _lastLocation = nil;
    
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
  RELEASE_SAFELY(_lastLocation);
  RELEASE_SAFELY(_locationManager);
  [super dealloc];
}

#pragma mark - Location Methods
- (void)getMyLocation {
  // Force acquiring a new location
  [self stopUpdates];  
  [self startUpdates];
//  [[PSToastCenter defaultCenter] showToastWithMessage:@"Finding Your Current Location" toastType:PSToastTypeAlert toastDuration:0.0];
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
   _lastLocation stores the last accepted acquired location whereas oldLocation may contain an unaccepted location
   
   Reasons to discard location
   1. Accuracy is bad (greater than threshold)
   2. Location is stale (older than 300 seconds)
   
   Reasons to reload interface
   1. Location distance change from last known location is less than threshold
   */
  CLLocationAccuracy accuracy = newLocation.horizontalAccuracy;
  NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:newLocation.timestamp];
  CLLocationDistance distanceChanged = _lastLocation ? [newLocation distanceFromLocation:_lastLocation] : _distanceFilter;
  
  if ((accuracy > _distanceFilter) || (age > _ageFilter)) {
    // Bad Location Discarded
    DLog(@"Location discarded: %@, oldLocation: %@, accuracy: %g, age: %g, distanceChanged: %g", newLocation, oldLocation, accuracy, age, distanceChanged);
  } else {
    // Good Location Acquired
    DLog(@"Location updated: %@, oldLocation: %@, accuracy: %g, age: %g, distanceChanged: %g", newLocation, oldLocation, accuracy, age, distanceChanged);
    
//    [[PSToastCenter defaultCenter] hideToast];
    
    if (_shouldDisableAfterLocationFix) {
      [self stopUpdates];
    }
    
    // Set last known acquired location
    RELEASE_SAFELY(_lastLocation);
    _lastLocation = [newLocation copy];
    
    // Post Notification to reload interface
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
//    if (distanceChanged >= _distanceFilter) {
//      [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
//    } else {
//      [[NSNotificationCenter defaultCenter] postNotificationName:kLocationUnchanged object:nil];
//    }
  }
}

@end
