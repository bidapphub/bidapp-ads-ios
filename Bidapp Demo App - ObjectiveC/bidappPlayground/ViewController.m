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
#import "tools.h"
#import <bidapp/bidapp.h>

@implementation ViewController

static NSMutableArray* delegates = nil;

- (IBAction)onShowInterstitial:(id)sender
{
	if (!delegates)
	{
		delegates = [NSMutableArray new];
	}

	id interstitialDelegate = [[FullscreenShowDelegate alloc]initWithViewController:self];
	[delegates addObject:interstitialDelegate];
	
	[BIDInterstitial showWithDelegate:interstitialDelegate];
}

- (IBAction)onShowRewarded:(id)sender
{
	if (!delegates)
	{
		delegates = [NSMutableArray new];
	}

	id rewardedDelegate = [[FullscreenShowDelegate alloc]initWithViewController:self];
	[delegates addObject:rewardedDelegate];
	
	[BIDRewarded showWithDelegate:rewardedDelegate];
}

- (IBAction)onShowBanners:(id)sender
{
	BannersTableViewController *bannersViewController = [[BannersTableViewController alloc] init];
	[self presentViewController:bannersViewController animated:YES completion:nil];
}

@end
