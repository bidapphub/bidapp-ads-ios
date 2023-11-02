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

@end
