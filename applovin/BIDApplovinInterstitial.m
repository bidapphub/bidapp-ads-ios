//
//  BIDApplovinInterstitial.m
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 19/4/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDApplovinInterstitial.h"

#import "BIDNetworkSettings.h"
#import "BIDApplovinBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"
#import "NSError+AppLovin.h"

#import <AppLovinSDK/AppLovinSDK.h>

@interface BIDApplovinInterstitial()<ALAdLoadDelegate,ALAdDisplayDelegate>

@property (nonatomic,strong) ALInterstitialAd *interstitialAd;
@property (nonatomic,strong) ALAd *ad;
@property (nonatomic,readonly) ALSdk *sdk;

@end

@implementation BIDApplovinInterstitial
{
	id<BIDNetworkFullscreen> __weak networkFullscreen;
	
	NSString* adTag;
	BOOL isRewarded;
}

-(id)initWithNetworkFullscreen:(id<BIDNetworkFullscreen>)ntFull SDK:(id)networkSDK adTag:(NSString *)adTag_ isRewarded:(BOOL)isRewarded_
{
	if (self = [super init])
    {
		networkFullscreen = ntFull;
		
		adTag = adTag_;
		isRewarded = isRewarded_;
		
        _interstitialAd = [[ALInterstitialAd alloc] initWithSdk:networkSDK];
		_sdk = networkSDK;
    }
    
    return self;
}

-(void)dealloc
{
    [_interstitialAd setAdDisplayDelegate:nil];
}

-(BOOL)readyToShow
{
    return nil != _ad;
}

#pragma mark - Load ad

-(void)load
{
	[_sdk.adService loadNextAd:[ALAdSize interstitial] andNotify:self];
}

#pragma mark - ALAdLoadDelegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    _ad = ad;
    
	[networkFullscreen onAdLoaded];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
	BOOL isLoadError = NO;
	NSError* error = [NSError applovinErrorWithCode:code isLoadError:&isLoadError];
	if (isLoadError)
	{
		[networkFullscreen onAdFailedToLoadWithError:error];
	}
	else
	{
		[networkFullscreen onFailedToDisplay:error];
	}
}

#pragma mark - Display ad

-(BOOL)showWithViewController:(UIViewController *)vc
						 error:(NSError *__autoreleasing  _Nullable *)error
{
	[_interstitialAd setAdDisplayDelegate:self];
	[_interstitialAd showAd:_ad];
    
    return YES;
}

#pragma mark - ALAdDisplayDelegate protocol

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view
{
	[networkFullscreen onDisplay];
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view;
{
	[networkFullscreen onClick];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view
{
    [_interstitialAd setAdDisplayDelegate:nil];
	
	[networkFullscreen onHide];
}

@end
