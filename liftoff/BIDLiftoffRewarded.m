//
//  BIDLiftoffRewarded.m
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 19/4/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDLiftoffRewarded.h"

#import "BIDNetworkSettings.h"
#import "BIDLiftoffBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"
#import "NSError+Categories.h"

@interface BIDLiftoffRewarded()<VungleRewardedDelegate>
{
	id<BIDNetworkFullscreen> __weak networkFullscreen;
}

@property (nonatomic, strong) VungleRewarded *rewardedAd;
@property (nonatomic,readonly) NSString* placementId;
@property (nonatomic,strong) NSString *loadedPlacementId;

@end

@implementation BIDLiftoffRewarded

-(id)initWithNetworkFullscreen:(id<BIDNetworkFullscreen>)ntFull SDK:(id)networkSDK adTag:(NSString *)adTag_ isRewarded:(BOOL)isRewarded_
{
	if (self = [super init])
	{
		networkFullscreen = ntFull;
		
		_placementId = adTag_;

		_rewardedAd = [[VungleRewarded alloc]initWithPlacementId:adTag_];
		_rewardedAd.delegate = self;
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
	[_rewardedAd load:nil];
}

#pragma mark - VungleInterstitialDelegate - load

- (void)rewardedAdDidLoad:(VungleRewarded *)rewarded
{
	_loadedPlacementId = _placementId;
	
	[networkFullscreen onAdLoaded];
}

- (void)rewardedAdDidFailToLoad:(VungleRewarded *)rewarded withError:(NSError *)withError
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
	[_rewardedAd presentWith:vc];

	return YES;
}

#pragma mark - VungleSDKDelegate - show

- (void)rewardedAdDidPresent:(VungleRewarded *)rewarded
{
	[networkFullscreen onDisplay];
}

- (void)rewardedAdDidFailToPresent:(VungleRewarded *)rewarded withError:(NSError *)withError
{
	[networkFullscreen onFailedToDisplay:withError];
}

- (void)rewardedAdDidClose:(VungleRewarded *)interstitial
{
	[networkFullscreen onHide];
}

- (void)rewardedAdDidClick:(VungleRewarded *)interstitial
{
	[networkFullscreen onClick];
}

- (void)rewardedAdDidRewardUser:(VungleRewarded *)rewarded
{
	[networkFullscreen onReward];
}

-(void)setUserId:(NSString *)userId_
{
    [_rewardedAd setUserIdWithUserId:userId_];
}

@end
