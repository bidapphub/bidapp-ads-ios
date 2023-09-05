//
//  BIDLiftoffInterstitial.m
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 19/4/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDLiftoffInterstitial.h"

#import "BIDNetworkSettings.h"
#import "BIDLiftoffBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"
#import "NSError+Categories.h"

#import <VungleAdsSDK/VungleAdsSDK.h>

@interface BIDLiftoffInterstitial()<VungleInterstitialDelegate>
{
	id<BIDNetworkFullscreen> __weak networkFullscreen;

	BOOL isRewarded;
}

@property (nonatomic, strong) VungleInterstitial *interstitialAd;
@property (nonatomic,readonly) NSString* placementId;
@property (nonatomic,strong) NSString *loadedPlacementId;

@end

@implementation BIDLiftoffInterstitial

-(id)initWithNetworkFullscreen:(id<BIDNetworkFullscreen>)ntFull SDK:(id)networkSDK adTag:(NSString *)adTag_ isRewarded:(BOOL)isRewarded_
{
	if (self = [super init])
	{
		networkFullscreen = ntFull;
		
		_placementId = adTag_;
		isRewarded = isRewarded_;
		
		_interstitialAd = [[VungleInterstitial alloc]initWithPlacementId:adTag_];
		_interstitialAd.delegate = self;
    }
    
    return self;
}

-(BOOL)readyToShow
{
    return nil != _loadedPlacementId;
}

#pragma mark - Load ad

-(void)load
{
	[_interstitialAd load:nil];
}

#pragma mark - VungleInterstitialDelegate - load

- (void)interstitialAdDidLoad:(VungleInterstitial * _Nonnull)interstitial
{
	_loadedPlacementId = _placementId;
	
	[networkFullscreen onAdLoaded];
}

- (void)interstitialAdDidFailToLoad:(VungleInterstitial * _Nonnull)interstitial withError:(NSError * _Nonnull)withError
{
	[networkFullscreen onAdFailedToLoadWithError:[NSError bidappError:withError forNetworkId:LIFTOFF_ADAPTER_UID]];
}

#pragma mark - Display ad

-(BOOL)viewControllerNeededForDisplay
{
	return YES;
}

-(BOOL)shouldWaitForAdToDisplay
{
	return YES;
}

-(BOOL)showWithViewController:(UIViewController *)vc
						 error:(NSError *__autoreleasing  _Nullable *)error
{
	[_interstitialAd presentWith:vc];

	return YES;
}

#pragma mark - VungleSDKDelegate - show

- (void)interstitialAdDidPresent:(VungleInterstitial * _Nonnull)interstitial
{
	[networkFullscreen onDisplay];
}

- (void)interstitialAdDidFailToPresent:(VungleInterstitial * _Nonnull)interstitial withError:(NSError * _Nonnull)withError
{
	[networkFullscreen onFailedToDisplay:withError];
}

- (void)interstitialAdDidClose:(VungleInterstitial * _Nonnull)interstitial
{
	[networkFullscreen onHide];
}

- (void)interstitialAdDidClick:(VungleInterstitial * _Nonnull)interstitial
{
	[networkFullscreen onClick];
}

@end
