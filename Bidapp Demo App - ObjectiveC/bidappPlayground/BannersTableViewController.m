//
//  BannersTableViewController.m
//  bidappPlayground
//
//  Created by Vasiliy Masnev on 30.03.2023.
//

#import "BannersTableViewController.h"

#import <bidapp/bidapp.h>

@interface BannersTableViewController () <BIDBannerViewDelegate>

@property (nonatomic,strong) NSMutableArray *pendingBanners;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSTimer *generateBannerTimer;
@property (nonatomic,strong) NSTimer *removeBannerTimer;
@property (nonatomic,strong) NSTimer *reloadTableDelayTimer;

@end

@implementation BannersTableViewController

- (void)dealloc
{
	NSLog(@"App - DEALLOC - BannerTablewVC");
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.pendingBanners = [NSMutableArray array];
	self.dataSource = [NSMutableArray array];
	
	 self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self schedulAddOneMoreBanner];
	[self addOneMoreBanner];
	
	self.removeBannerTimer = [NSTimer scheduledTimerWithTimeInterval:30
																														target:self
																													selector:@selector(removeOneBanner)
																													userInfo:nil
																													 repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self.generateBannerTimer invalidate];
	[self.reloadTableDelayTimer invalidate];
	[self.removeBannerTimer invalidate];
}

- (void)schedulAddOneMoreBanner
{
	[self.generateBannerTimer invalidate];
	self.generateBannerTimer = [NSTimer scheduledTimerWithTimeInterval:10
																															target:self
																														selector:@selector(addOneMoreBanner)
																														userInfo:nil
																														 repeats:YES];
}

- (void)addOneMoreBanner
{
	if (self.pendingBanners.count < 2) {
		BIDBannerView *banner = nil;
		if (arc4random_uniform(2)==0) {
			banner = [BIDBannerView bannerWithFormat:[BIDAdFormat banner_300x250] delegate:self];
		}
		else {
			banner = [BIDBannerView bannerWithFormat:[BIDAdFormat banner_320x50] delegate:self];
		}
		banner.backgroundColor = [UIColor greenColor];
		[self.pendingBanners addObject:banner];
	}
}

- (void)removeOneBanner
{
	BOOL removedTheLastOne = NO;
	for (UIView *view in self.dataSource.reverseObjectEnumerator)
	{
		if (view.subviews.count > 0)
		{
			[view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
			view.backgroundColor = [UIColor redColor];
			
			removedTheLastOne = (view == self.dataSource.firstObject);
			break;
		}
	}
	
	if (removedTheLastOne)
	{
		[self.dataSource makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[self.dataSource removeAllObjects];
		
		[self schedulAddOneMoreBanner];
	}

	[self schedulUpdateTableView];
}

- (void)schedulUpdateTableView
{
	[self.reloadTableDelayTimer invalidate];
	self.reloadTableDelayTimer = [NSTimer scheduledTimerWithTimeInterval:1
																																target:self.tableView
																															selector:@selector(reloadData)
																															userInfo:nil
																															 repeats:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.dataSource.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"LOADING...";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Banner"];
	if (nil==cell) {
		cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"Banner"];
	}
	[cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	UIView *view = self.dataSource[indexPath.row];
	view.center = CGPointMake(CGRectGetMidX(cell.contentView.bounds), CGRectGetMidY(cell.contentView.bounds));
	view.frame = cell.contentView.bounds;
	view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	[cell.contentView addSubview:view];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIView *view = self.dataSource[indexPath.row];
	UIView *bannerView = view.subviews.firstObject;
	return bannerView.frame.size.height + 10;
}

#pragma mark - BIDBannerViewDelegate

-(void)addAdToSuperviewIfNeeded:(BIDBannerView*)adView
{
	if (adView.superview)
	{
		return;
	}
	
	UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
	containerView.backgroundColor = [UIColor greenColor];
	
	adView.backgroundColor = [UIColor orangeColor];
	adView.center = CGPointMake(CGRectGetMidX(containerView.bounds), CGRectGetMidY(containerView.bounds));
	adView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
														 UIViewAutoresizingFlexibleBottomMargin |
														 UIViewAutoresizingFlexibleLeftMargin |
														 UIViewAutoresizingFlexibleRightMargin);
	[containerView addSubview:adView];
	
	[self.pendingBanners removeObject:adView];
	[self.dataSource insertObject:containerView atIndex:0];
	
	if (self.dataSource.count > 5) {
		[self.generateBannerTimer invalidate];
		self.generateBannerTimer = nil;
	}
	
	[self schedulUpdateTableView];
}

- (void)adView:(BIDBannerView *)adView didLoadAd:(BIDAdInfo *)adInfo
{
	NSLog(@"App - didLoadAd. AdView: %@, AdInfo: %@", adView, adInfo);
	
	if (!adView.isAdDisplayed)
	{
		[self addAdToSuperviewIfNeeded:adView];
		
		[adView refreshAd];
	}
}

- (void)adView:(BIDBannerView *)adView didDisplayAd:(BIDAdInfo *)adInfo
{
	NSLog(@"App - didDisplayAd. AdView: %@, AdInfo: %@", adView, adInfo);
	
	[self addAdToSuperviewIfNeeded:adView];
}

- (void)adView:(BIDBannerView *)adView didFailToDisplayAd:(nonnull BIDAdInfo *)adInfo error:(nonnull NSError *)error
{
	NSLog(@"App - didFailToDisplayAd. AdView: %@, Error: %@", adView, error);
	
	[self.pendingBanners removeObject:adView];
}

- (void)adView:(BIDBannerView *)adView didClicked:(BIDAdInfo *)adInfo
{
	NSLog(@"App - didClicked. AdView: %@, AdInfo: %@", adView, adInfo);
}

@end
