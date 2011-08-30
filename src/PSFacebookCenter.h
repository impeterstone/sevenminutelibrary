//
//  PSFacebookCenter.h
//  MealTime
//
//  Created by Peter Shih on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSObject.h"
#import "Facebook.h"

@interface PSFacebookCenter : PSObject <FBDialogDelegate, FBSessionDelegate, UIAlertViewDelegate> {
  Facebook *_facebook;
  NSArray *_newPermissions;
}

+ (id)defaultCenter;

- (BOOL)handleOpenURL:(NSURL *)url;

// Permissions
- (BOOL)hasPublishStreamPermission;
- (void)requestPublishStream;
- (NSArray *)availableExtendedPermissions;
- (void)addExtendedPermission:(NSString *)permission;

// Dialog
- (void)showDialog:(NSString *)dialog andParams:(NSMutableDictionary *)params;

@end
