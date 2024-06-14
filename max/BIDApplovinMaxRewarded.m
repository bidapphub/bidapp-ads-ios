//
//  BIDApplovinMaxInterstitial.m
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 19/4/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDApplovinMaxRewarded.h"

#import "BIDNetworkSettings.h"
#import "BIDApplovinMaxBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"

#import <AppLovinSDK/AppLovinSDK.h>

@interface BIDApplovinMaxRewarded()<MARewardedAdDelegate>
{
	id<BIDNetworkFullscreen> __weak adapter;
	
	NSString* adTag;
	BOOL isRewarded;
}

@property (nonatomic,strong) MARewardedInterstitialAd *interstitialAd;
@property (nonatomic,strong) MAAd *ad;
@property (nonatomic,readonly) ALSdk *sdk;

@end

@implementation BIDApplovinMaxRewarded

-(id)initWithNetworkFullscreen:(id<BIDNetworkFullscreen>)adapter_ SDK:(id)networkSDK adTag:(NSString *)adTag_ isRewarded:(BOOL)isRewarded_
{
	if (self = [super init])
	{
		adapter = adapter_;
		
		adTag = adTag_;
		isRewarded = isRewarded_;

        //if sdk == nil, Applovin will throw exception
        _interstitialAd = [[MARewardedInterstitialAd alloc] initWithAdUnitIdentifier:adTag sdk:networkSDK];
        _interstitialAd.delegate = self;
		_sdk = networkSDK;
    }
    
    return self;
}

-(void)dealloc
{
    _interstitialAd.delegate = nil;
}

-(BOOL)readyToShow
{
    return nil != _ad;
}

#pragma mark - Load ad

- (void)loadWithBid:(id<BidappBid>)bid
{
	[_interstitialAd loadAd];
}

#pragma mark - MAAdDelegate - load ad

- (void)didLoadAd:(MAAd *)ad
{
    _ad = ad;
    
	[adapter onAdLoaded];
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)e
{
    NSString *message = (nil!=e.message) ? e.message : @"Unknown error";
	[adapter onAdFailedToLoadWithError:[NSError errorWithDomain:@"io.bidapp.applovin-max"
                                                           code:e.code
                                                       userInfo:@{NSLocalizedDescriptionKey:message}]];
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
    [_interstitialAd showAdForPlacement:nil customData:nil viewController:vc];
    
    return YES;
}

+(NSPointerArray*)delegateMethodsToValidate
{
    NSPointerArray *selectors = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsOpaqueMemory];
    
    [selectors addPointer:@selector(didLoadAd:)];
    [selectors addPointer:@selector(didFailToLoadAdForAdUnitIdentifier:withError:)];
    [selectors addPointer:@selector(didDisplayAd:)];
    [selectors addPointer:@selector(didFailToDisplayAd:withError:)];
    [selectors addPointer:@selector(didClickAd:)];
    [selectors addPointer:@selector(didHideAd:)];
    [selectors addPointer:@selector(didRewardUserForAd:withReward:)];
    
    return selectors;
}

#pragma mark - MAAdDelegate - display ad

- (void)didDisplayAd:(MAAd *)ad
{
	[adapter onDisplay];
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)e
{
    NSString *message = (nil!=e.message) ? e.message : @"Unknown error";
    [adapter onFailedToDisplay:[NSError errorWithDomain:@"io.bidapp.applovin-max"
                                                                     code:e.code
                                                                 userInfo:@{NSLocalizedDescriptionKey:message}]];
}

- (void)didClickAd:(MAAd *)ad
{
	[adapter onClick];
}

- (void)didHideAd:(MAAd *)ad
{
	[adapter onHide];
}

#pragma mark -

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward
{
	[adapter onReward];
}

#pragma mark - revenue

-(NSNumber*)revenue
{
    if (!_ad)
    {
        return nil;
    }
    
    return @(_ad.revenue);
}

@end
