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
 Helps determine if a loading/empty screen is shown
 Or if data has been loaded to display
 Subclasses should implement
 */
- (BOOL)dataIsAvailable;
- (BOOL)dataIsLoading;

/**
 Tell the state machine to either show a loading/empty view or show data
 */
- (void)updateState;

/**
 Used to update the currently active scrollview (for scrollsToTop fix)
 */
- (void)updateScrollsToTop:(BOOL)isEnabled;

@optional
/**
 Initiates loading of the dataSource
 */
- (void)setupDataSource;
- (void)restoreDataSource; // Restore view after it gets unloaded
- (void)reloadDataSource; // Refresh
- (void)loadDataSource; // Initial Load
- (void)dataSourceShouldLoadObjects:(id)objects;
- (void)dataSourceDidLoad;
- (void)dataSourceDidLoadMore;

/**
 Used by tableView to page in more data
 */
- (void)loadMore;
- (BOOL)shouldLoadMore;

/**
 Remotely fetch data
 */
- (void)fetchDataSource;

/**
 Local fetch data
 */
- (void)dataSourceDidFetch;

@end