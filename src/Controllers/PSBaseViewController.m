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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _activeScrollView = nil;
    _loadingLabel = [@"Loading..." retain];
    _emptyLabel = [@"No Results" retain];
  }
  return self;
}

- (void)loadView
{
  [super loadView];  
  
  // NullView
  _nullView = [[PSNullView alloc] initWithFrame:self.view.bounds];
  _nullView.autoresizingMask = ~UIViewAutoresizingNone;
  [_nullView setState:PSNullViewStateDisabled];
  [self.view addSubview:_nullView];
  
  // Configure Empty View
  // Configure Loading View
  
  // Setup Nav Bar
  UIView *navTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, self.navigationController.navigationBar.height)];
  navTitleView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  _navTitleLabel = [[UILabel alloc] initWithFrame:navTitleView.bounds];
  _navTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  _navTitleLabel.textAlignment = UITextAlignmentCenter;
  _navTitleLabel.numberOfLines = 3;
  _navTitleLabel.font = [PSStyleSheet fontForStyle:@"navigationTitle"];
  _navTitleLabel.textColor = [PSStyleSheet textColorForStyle:@"navigationTitle"];
  _navTitleLabel.shadowColor = [PSStyleSheet shadowColorForStyle:@"navigationTitle"];
  _navTitleLabel.shadowOffset = CGSizeMake(0, 1);
  _navTitleLabel.backgroundColor = [UIColor clearColor];
  [navTitleView addSubview:_navTitleLabel];
  
  self.navigationItem.titleView = navTitleView;
  [navTitleView release];
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

#pragma mark PSStateMachine
- (BOOL)dataIsAvailable {
  return NO;
}

- (BOOL)dataIsLoading {
  return NO;
}

- (void)loadDataSource {
}

- (void)dataSourceDidLoad {
}

- (void)updateState {
  if ([self dataIsAvailable]) {
    // We have data to display
    _nullView.state = PSNullViewStateDisabled;
  } else {
    // We don't have data available to display
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

- (void)dealloc {
  RELEASE_SAFELY(_nullView);
  RELEASE_SAFELY(_navTitleLabel);
  RELEASE_SAFELY(_loadingLabel);
  RELEASE_SAFELY(_emptyLabel);
  [super dealloc];
}

@end