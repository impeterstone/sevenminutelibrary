//
//  PSLocationCenter.m
//  Spotlight
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
- (void)start {
#if TARGET_IPHONE_SIMULATOR
  [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
#else
  [self startStandardUpdates];
#endif
}

- (void)stop {
#if TARGET_IPHONE_SIMULATOR
  
#else
  [self stopStandardUpdates];
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
  self.oldLocation = nil;
  self.currentLocation = nil;
}

- (void)startSignificantChangeUpdates {
  // Create the location manager if this object does not
  // already have one.
  if (nil == _locationManager)
    self.locationManager = [[CLLocationManager alloc] init];
  
  self.locationManager.delegate = self;
  [self.locationManager startMonitoringSignificantLocationChanges];
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
  // If it's a relatively recent event, turn off updates to save power
  NSDate* eventDate = newLocation.timestamp;
  
  NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
  if (abs(howRecent) < 15.0)
  {
    self.oldLocation = self.currentLocation;
    self.currentLocation = newLocation;
    
    NSLog(@"latitude %+.6f, longitude %+.6f\n",
          newLocation.coordinate.latitude,
          newLocation.coordinate.longitude);
    
    if (!self.oldLocation) {
      [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
    }
  }
  // else skip the event and process the next one.
}

@end
