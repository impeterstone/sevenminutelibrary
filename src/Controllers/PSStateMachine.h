//
//  PSStateMachine.h
//  PhotoTime
//
//  Created by Peter Shih on 2/27/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PSStateMachine <NSObject>

@required

/**
 If dataIsAvailable and !dataIsLoading and dataSourceIsReady, remove empty/loading screens
 If !dataIsAvailable and !dataIsLoading and dataSourceIsReady, show empty screen
 If dataIsLoading and !dataSourceIsReady, show loading screen
 If !dataIsLoading and !dataSourceIsReady, show empty/error screen
 */
- (BOOL)dataIsAvailable;
- (BOOL)dataIsLoading;
- (BOOL)dataSourceIsReady;
- (void)updateState;
- (void)updateScrollsToTop:(BOOL)isEnabled;

@end