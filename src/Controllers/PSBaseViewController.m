//
//  PSBaseViewController.m
//  PhotoTime
//
//  Created by Peter Shih on 2/10/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSBaseViewController.h"
#import "PSNullView.h"

@interface PSBaseViewController (Private)

@end

@implementation PSBaseViewController

@synthesize navTitleLabel = _navTitleLabel;

- (id)init {
  self = [super init];
  if (self) {
    _activeScrollView = nil;
    _loadingLabel = [@"Loading..." retain];
    _emptyLabel = [@"No Results" retain];
  }
  return self;
}

- (void)loadView {
  [super loadView];
  
  if (isDeviceIPad()) {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_weave-pad.png"]];
  } else {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_weave.png"]];
  }
  
  // Background View
  //  UIImageView *backgroundView = [[UIImageView alloc] initWithImage:_backgroundImage];
  //  backgroundView.frame = self.view.bounds;
  //  [self.view addSubview:backgroundView];
  //  [backgroundView release];
  
  _nullView = [[PSNullView alloc] initWithFrame:self.view.bounds];
  [_nullView setLoadingLabel:_loadingLabel];
  [_nullView setEmptyLabel:_emptyLabel];
  [_nullView setState:PSNullViewStateDisabled];
  [self.view addSubview:_nullView];
  
  //  self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
  
  // Setup Nav Bar
  UIView *navTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, self.navigationController.navigationBar.height)];
  navTitleView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  _navTitleLabel = [[UILabel alloc] initWithFrame:navTitleView.bounds];
  _navTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  _navTitleLabel.textAlignment = UITextAlignmentCenter;
  _navTitleLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
  _navTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
  _navTitleLabel.numberOfLines = 3;
  _navTitleLabel.shadowColor = [UIColor blackColor];
  _navTitleLabel.shadowOffset = CGSizeMake(0, 1);
  _navTitleLabel.backgroundColor = [UIColor clearColor];
  [navTitleView addSubview:_navTitleLabel];
  
  self.navigationItem.titleView = navTitleView;
  [navTitleView release];
  
//  self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
  
  //  self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-logo.png"]] autorelease];
}

//- (void)viewDidAppear:(BOOL)animated {
//  [super viewDidAppear:animated];
//  [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChangedFromNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//  [super viewDidDisappear:animated];
//  [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
//  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
//}

- (void)orientationChangedFromNotification:(NSNotification *)notification {
  // may should implement
}

- (void)back {
  [self.navigationController popViewControllerAnimated:YES];
}

// Optional Implementation
- (void)addBackButton {
  UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
  back.frame = CGRectMake(0, 0, 60, self.navigationController.navigationBar.height - 14);
  [back setTitle:@"Back" forState:UIControlStateNormal];
  [back setTitleEdgeInsets:UIEdgeInsetsMake(0, 9, 0, 0)];
  back.titleLabel.font = NAV_BUTTON_FONT;
  back.titleLabel.shadowColor = [UIColor blackColor];
  back.titleLabel.shadowOffset = CGSizeMake(0, 1);
  UIImage *backImage = [[UIImage imageNamed:@"navbar_back_button.png"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];
  UIImage *backHighlightedImage = [[UIImage imageNamed:@"navbar_back_highlighted_button.png"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];  
  [back setBackgroundImage:backImage forState:UIControlStateNormal];
  [back setBackgroundImage:backHighlightedImage forState:UIControlStateHighlighted];
  [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];  
  UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithCustomView:back] autorelease];
  self.navigationItem.leftBarButtonItem = backButton;
}

// Subclasses may implement
- (void)setupNullView {
  
}

// Called when the user logs out and we need to clear all cached data
// Subclasses should override this method
- (void)clearCachedData {
}

// Called when this card controller leaves active view
// Subclasses should override this method
- (void)unloadCardController {
  DLog(@"Called by class: %@", [self class]);
}

// Called when this card controller comes into active view
// Subclasses should override this method
- (void)reloadCardController {
  DLog(@"Called by class: %@", [self class]);
  [self updateState];
}

- (void)resetCardController {
  DLog(@"Called by class: %@", [self class]);
  [self updateState];  
}

// Subclass
- (void)dataSourceDidLoad {
}

#pragma mark PSStateMachine
/**
 If dataIsAvailable and !dataIsLoading and dataSourceIsReady, remove empty/loading screens
 If !dataIsAvailable and !dataIsLoading and dataSourceIsReady, show empty screen
 If dataIsLoading and !dataSourceIsReady, show loading screen
 If !dataIsLoading and !dataSourceIsReady, show empty/error screen
 */
//- (BOOL)dataIsAvailable;
//- (BOOL)dataIsLoading;
//- (BOOL)dataSourceIsReady;
//- (void)updateState;

- (BOOL)dataSourceIsReady {
  return YES;
}

- (BOOL)dataIsAvailable {
  return YES;
}

- (BOOL)dataIsLoading {
  return NO;
}

- (void)updateState {
  if ([self dataIsAvailable]) {
    // We have real data to display
    _nullView.state = PSNullViewStateDisabled;
  } else {
    if ([self dataIsLoading]) {
      // We are loading for the first time
      _nullView.state = PSNullViewStateLoading;
    } else {
      // We have no data to display, show the empty screen
      _nullView.state = PSNullViewStateEmpty;
    }
  }
}

- (void)updateScrollsToTop:(BOOL)isEnabled {
  if (_activeScrollView) {
    _activeScrollView.scrollsToTop = isEnabled;
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)dealloc {
  RELEASE_SAFELY(_nullView);
  RELEASE_SAFELY(_navTitleLabel);
  RELEASE_SAFELY(_loadingLabel);
  RELEASE_SAFELY(_emptyLabel);
  [super dealloc];
}


@end
