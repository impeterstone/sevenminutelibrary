//
//  PSTableViewController.m
//  PhotoTime
//
//  Created by Peter Shih on 2/14/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSTableViewController.h"
#import "PSCell.h"
#import "PSImageCell.h"

@interface PSTableViewController (Private)

@end

@implementation PSTableViewController

@synthesize tableView = _tableView;
@synthesize items = _items;
@synthesize searchItems = _searchItems;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {    
    _items = [[NSMutableArray alloc] initWithCapacity:1];
    _sectionTitles = [[NSMutableArray alloc] initWithCapacity:1];
    _selectedIndexes = [[NSMutableDictionary alloc] initWithCapacity:1];
    _cellCache = [[NSMutableArray alloc] initWithCapacity:1];
    _reloading = NO;
    _hasMore = YES;
//    _adShowing = NO;
    _pagingStart = 0;
    _pagingCount = 0;
    _pagingTotal = 0;
    
    // View State
    _contentOffset = CGPointZero;
  }
  return self;
}

- (void)viewDidUnload {
  [super viewDidUnload];
  
  // Save view state
  _contentOffset = _tableView.contentOffset;
  
//  _adShowing = NO;
//  _adView.delegate = nil;
//  RELEASE_SAFELY(_adView);
  RELEASE_SAFELY(_tableView);
  RELEASE_SAFELY(_searchBar);
  RELEASE_SAFELY(_refreshHeaderView);
  RELEASE_SAFELY(_loadMoreView);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  // Remove scrolling observer
  //  [_tableView removeObserver:self forKeyPath:@"contentOffset"];
  
  // Views
//  _adView.delegate = nil;
//  RELEASE_SAFELY(_adView);
  RELEASE_SAFELY(_tableView);
  RELEASE_SAFELY(_searchBar);
  RELEASE_SAFELY(_refreshHeaderView);
  RELEASE_SAFELY(_loadMoreView);
  
  // Non-Views
  RELEASE_SAFELY(_sectionTitles);
  RELEASE_SAFELY(_selectedIndexes);
  RELEASE_SAFELY(_items);
  RELEASE_SAFELY(_searchItems);
  RELEASE_SAFELY(_visibleCells);
  RELEASE_SAFELY(_visibleIndexPaths);
  RELEASE_SAFELY(_cellCache);

  [super dealloc];
}

#pragma mark - View Config
- (UIView *)rowBackgroundView {
  return nil;
}

- (UIView *)rowSelectedBackgroundView {
  return nil;
}

#pragma mark - View
// SUBCLASS CAN OPTIONALLY IMPLEMENT IF THEY WANT A SEARCH BAR
- (void)setupSearchDisplayControllerWithScopeButtonTitles:(NSArray *)scopeButtonTitles {
  [self setupSearchDisplayControllerWithScopeButtonTitles:scopeButtonTitles andPlaceholder:nil];
}

- (void)setupSearchDisplayControllerWithScopeButtonTitles:(NSArray *)scopeButtonTitles andPlaceholder:(NSString *)placeholder {
  _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
  _searchBar.delegate = self;
  //  _searchBar.tintColor = [UIColor darkGrayColor];
  _searchBar.placeholder = placeholder;
  _searchBar.barStyle = UIBarStyleBlackOpaque;
  //  _searchBar.backgroundColor = [UIColor clearColor];
  
  if (scopeButtonTitles) {
    _searchBar.scopeButtonTitles = scopeButtonTitles;
  }
  
  _tableView.tableHeaderView = _searchBar;
  
  UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
  [searchController setDelegate:self];
  [searchController setSearchResultsDelegate:self];
  [searchController setSearchResultsDataSource:self];
  
  // SUBCLASSES MUST IMPLEMENT THE DELEGATE METHODS
  _searchItems = [[NSMutableArray alloc] initWithCapacity:1];
}

// SUBCLASS SHOULD CALL THIS
- (void)setupTableViewWithFrame:(CGRect)frame andStyle:(UITableViewStyle)style andSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle {
  _tableView = [[UITableView alloc] initWithFrame:frame style:style];
  _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  _tableView.separatorStyle = separatorStyle;
  _tableView.delegate = self;
  _tableView.dataSource = self;
  if (style == UITableViewStylePlain) {
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = SEPARATOR_COLOR;
  }
  
  //  [self.view insertSubview:_tableView atIndex:0];
  [self.view addSubview:_tableView];
  
  // Setup optional header/footer
  [self setupTableHeader];
  [self setupTableFooter];
  
  if ([self shouldLoadMore]) [self setupLoadMoreView];
  
  // Set the active scrollView
  _activeScrollView = _tableView;
  
//  [_tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

// SUBCLASS CAN OPTIONALLY CALL
- (void)setupPullRefresh {
  if (_refreshHeaderView == nil) {
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
		[_tableView addSubview:_refreshHeaderView];		
	}
	
  //  update the last update date
  [_refreshHeaderView refreshLastUpdatedDate];
}

// Optional table header
- (void)setupTableHeader {
  // subclass should implement
}

// Optional table footer
- (void)setupTableFooter {
  // subclass should implement
}

// Optional Header View
- (void)setupHeaderWithView:(UIView *)headerView {
  _nullView.frame = CGRectMake(_nullView.left, _nullView.top + headerView.height, _nullView.width, _nullView.height - headerView.height);
  _tableView.frame = CGRectMake(_tableView.left, _tableView.top + headerView.height, _tableView.width, _tableView.height - headerView.height);  
  headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
  [self.view addSubview:headerView];
}

// Optional footer view
- (void)setupFooterWithView:(UIView *)footerView {
  _nullView.frame = CGRectMake(_nullView.left, _nullView.top, _nullView.width, _nullView.height - footerView.height);
  _tableView.frame = CGRectMake(_tableView.left, _tableView.top, _tableView.width, _tableView.height - footerView.height);
  footerView.top = self.view.height - footerView.height; // 44 navbar
  footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  [self.view addSubview:footerView];
}

// This is the automatic load more style
- (void)setupLoadMoreView {
  _loadMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
  _loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _loadMoreView.backgroundColor = [UIColor clearColor];
  
  UIImageView *bg = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow_lastcell.png"]] autorelease];
  bg.autoresizingMask = ~UIViewAutoresizingNone;
  
  UILabel *l = [[[UILabel alloc] initWithFrame:_loadMoreView.bounds] autorelease];
  l.backgroundColor = [UIColor clearColor];
  l.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  l.text = @"Loading More...";
  l.textAlignment = UITextAlignmentCenter;
  l.font = [PSStyleSheet fontForStyle:@"loadMoreLabel"];
  l.textColor = [PSStyleSheet textColorForStyle:@"loadMoreLabel"];
  l.shadowColor = [PSStyleSheet shadowColorForStyle:@"loadMoreLabel"];
  l.shadowOffset = [PSStyleSheet shadowOffsetForStyle:@"loadMoreLabel"];
  
  // Activity
  UIActivityIndicatorView *av = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
  av.frame = CGRectMake(12, 12, 20, 20);
  av.hidesWhenStopped = YES;
  [av startAnimating];
  
  // Add to subview
  [_loadMoreView addSubview:bg];
  [_loadMoreView addSubview:l];
  [_loadMoreView addSubview:av];
}

#pragma mark PSStateMachine
- (BOOL)dataIsAvailable {
  // Is this a searchResultsTable or just Table?
  NSArray *items = (_tableView == self.searchDisplayController.searchResultsTableView) ? _searchItems : _items;
  
  // Check numSections
  if ([items count] > 0) {
    // Has more than 1 section, now check each section for numRows
    for (NSArray *section in items) {
      if ([section count] > 0) {
        // Found a non-empty section
        return YES;
      }
    }
    // All sections are empty
    return NO;
  } else {
    // Has no sections
    return NO;
  }
}

- (BOOL)dataIsLoading {
  return _reloading;
}

- (void)updateState {
  [super updateState];
  
  // Show/hide loadMore footer
  if (_hasMore && [self shouldLoadMore] && [self dataIsAvailable]) {
    self.tableView.tableFooterView = _loadMoreView;
  } else if (!_hasMore && [self shouldLoadMore]) {
    self.tableView.tableFooterView = nil;
  }
}

- (void)restoreDataSource {
  [super restoreDataSource];
  [_tableView reloadData];
  _tableView.contentOffset = _contentOffset;
}

- (void)loadDataSource {
  _reloading = YES;
  if (_refreshHeaderView) {
    [_refreshHeaderView setState:EGOOPullRefreshLoading];
  }
  [self updateState];
}

- (void)dataSourceDidLoad {
  _reloading = NO;
  if (_refreshHeaderView) {
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
  }
  [self updateState];
}

- (BOOL)shouldLoadMore {
  return NO;
}

- (void)loadMore {
  _reloading = YES;
  [self updateState];
}

- (void)dataSourceDidLoadMore {
  _reloading = NO;
  [self updateState];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath {
	// Return whether the cell at the specified index path is selected or not
	NSNumber *selectedIndex = [_selectedIndexes objectForKey:indexPath];
	return selectedIndex == nil ? NO : [selectedIndex boolValue];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    return [_searchItems count];
  } else {
    return [_items count];
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    return [[_searchItems objectAtIndex:section] count];
  } else {
    return [[_items objectAtIndex:section] count];
  }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  cell.backgroundView = [self rowBackgroundView];
  cell.selectedBackgroundView = [self rowSelectedBackgroundView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *reuseIdentifier = [NSString stringWithFormat:@"%@_TableViewCell", [self class]];
  UITableViewCell *cell = nil;
  cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier] autorelease];
  }
  
  cell.textLabel.text = @"Oops! Forgot to override this method?";
  cell.detailTextLabel.text = reuseIdentifier;
  return cell;
}

#pragma mark UISearchDisplayDelegate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
  // SUBCLASS MUST IMPLEMENT
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
  
  // Return YES to cause the search result table view to be reloaded.
  return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
  [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
  
  // Return YES to cause the search result table view to be reloaded.
  return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
//  [tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
  tableView.rowHeight = _tableView.rowHeight;
  tableView.backgroundColor = [UIColor whiteColor];
  tableView.separatorColor = _tableView.separatorColor;
  tableView.separatorStyle = _tableView.separatorStyle;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
//  [tableView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
  // Subclass may implement
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
  // Subclass may implement
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
//    [self scrollEndedTrigger];
  }
  if (!self.searchDisplayController.active) {
    if (_refreshHeaderView) {
      [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//  [self scrollEndedTrigger];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (_refreshHeaderView) {
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
  }
  
  if ([self shouldLoadMore]) {
    if ([scrollView isKindOfClass:[UITableView class]]) {
      UITableView *tableView = (UITableView *)scrollView;
      if (!_reloading && _hasMore && [[tableView visibleCells] count] > 0) {
        CGFloat tableOffset = tableView.contentOffset.y + tableView.height;
        CGFloat tableBottom = tableView.contentSize.height - tableView.rowHeight;
        
        if (tableOffset >= tableBottom) {
          VLog(@"### loadMore");
          [self loadMore];
        }
      }
    }
  }
}

- (void)scrollEndedTrigger {
}

#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
  [self loadDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - ADBannerViewDelegate
//- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
//  if (_adShowing) {
//    return;
//  } else {
//    _adShowing = YES;
//  }
//  
//  banner.top = self.view.bottom;
//  [self.view addSubview:banner];
//  [UIView animateWithDuration:0.4
//                   animations:^{
//                     banner.top -= banner.height;
//                     _tableView.height -= banner.height;
//                   }
//                   completion:^(BOOL finished) {
//                   }];
//}
//
//- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
//  DLog(@"iAd failed to load with error: %@", error);
//  if (!_adShowing) return;
//  
//  [UIView animateWithDuration:0.4
//                   animations:^{
//                     banner.top += banner.height;
//                     _tableView.height += banner.height;
//                   }
//                   completion:^(BOOL finished) {
//                     _adShowing = NO;
//                     [banner removeFromSuperview];
//                   }];
//}
//
//- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
//  return YES;
//}
//
//- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
//  
//}

@end