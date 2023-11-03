//
//  ViewController.m
//  bidappPlayground
//
//  Created by Vasiliy Masnev on 30.01.2023.
//  Copyright 2023 bidapp. All rights reserved.
//

#import "ViewController.h"
#import "BannersTableViewController.h"
#import "FullscreenShowDelegate.h"
#import "BannerDelegate.h"
#import "FullscreenLoadDelegate.h"
#import "tools.h"
#import <bidapp/bidapp.h>

@implementation ViewController
{
    FullscreenLoadDelegate* loadDelegate;
    
    BIDInterstitial* interstitial;
    BIDRewarded* rewarded;
    
    BannerDelegate* bannerDelegate;
    BIDBannerView* bannerView;
    
    IBOutlet UIView* __weak bannerBaseView;
}

static NSMutableArray* delegates = nil;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    loadDelegate = [FullscreenLoadDelegate new];
    
    interstitial = [BIDInterstitial new];
    interstitial.loadDelegate = loadDelegate;
    
    rewarded = [BIDRewarded new];
    rewarded.loadDelegate = loadDelegate;
    
    bannerDelegate = [BannerDelegate new];
    
    bannerView = [BIDBannerView bannerWithFormat:BIDAdFormat.banner_320x50 delegate:bannerDelegate];
    [bannerBaseView addSubview:bannerView];
}

- (IBAction)onShowInterstitial:(id)sender
{
	if (!delegates)
	{
		delegates = [NSMutableArray new];
	}

	id interstitialDelegate = [[FullscreenShowDelegate alloc]initWithViewController:self];
	[delegates addObject:interstitialDelegate];
	
	[interstitial showWithDelegate:interstitialDelegate];
}

- (IBAction)onShowRewarded:(id)sender
{
	if (!delegates)
	{
		delegates = [NSMutableArray new];
	}

	id rewardedDelegate = [[FullscreenShowDelegate alloc]initWithViewController:self];
	[delegates addObject:rewardedDelegate];
	
	[rewarded showWithDelegate:rewardedDelegate];
}

- (IBAction)onShowBanners:(id)sender
{
	BannersTableViewController *bannersViewController = [[BannersTableViewController alloc] init];
	[self presentViewController:bannersViewController animated:YES completion:nil];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    
    [bannerView stopAutorefresh];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [super dismissViewControllerAnimated:flag completion:completion];
    
    [bannerView startAutorefresh:30.0];
}

@end
