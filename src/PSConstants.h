//
//  PSConstants.h
//  Spotlight
//
//  Created by Peter Shih on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// Import any project-specific constants here
#import "Constants.h"

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

/**
 Locale/Language
 */
#define USER_LANGUAGE [[NSLocale preferredLanguages] objectAtIndex:0]
#define USER_LOCALE [[NSLocale autoupdatingCurrentLocale] localeIdentifier]

/**
 Core Data (FILL THIS IN LOCAL CONSTANTS)
 */
//#define CORE_DATA_SQL_FILE
//#define CORE_DATA_MOM

/**
 Font Defines
 */
#define PS_CAPTION_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]
#define PS_TITLE_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]
#define PS_LARGE_FONT [UIFont fontWithName:@"HelveticaNeue" size:16.0]
#define PS_NORMAL_FONT [UIFont fontWithName:@"HelveticaNeue" size:14.0]
#define PS_BOLD_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]
#define PS_SUBTITLE_FONT [UIFont fontWithName:@"HelveticaNeue" size:12.0]
#define PS_TIMESTAMP_FONT [UIFont fontWithName:@"HelveticaNeue" size:10.0]
#define PS_NAV_BUTTON_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]

/**
 Notifications
 */
#define kCoreDataDidReset @"CoreDataDidReset"
#define kPSImageCacheDidCacheImage @"PSImageCacheDidCacheImage"


/**
 Logging Macros
 */
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

//#define VERBOSE_DEBUG
#ifdef VERBOSE_DEBUG
#define VLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define VLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

/**
 Safe Releases
 */
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

// Release a CoreFoundation object safely.
#define RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }



/**
 Detect iPad
 */
static BOOL isDeviceIPad() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    return YES; 
  }
#endif
  return NO;
}