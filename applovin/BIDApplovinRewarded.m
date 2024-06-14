//
//  BIDApplovinRewarded.m
//  bidapp
//
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDApplovinRewarded.h"

#import "BIDNetworkSettings.h"
#import "BIDApplovinBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"
#import "NSError+AppLovin.h"

#import <AppLovinSDK/AppLovinSDK.h>

@interface BIDApplovinRewarded()<ALAdLoadDelegate,ALAdDisplayDelegate,ALAdRewardDelegate>
{
	BOOL rewardLegitimated;
}

@property (nonatomic,strong) ALIncentivizedInterstitialAd *rewardedAd;
@property (nonatomic,strong) ALAd *ad;
@property (nonatomic,readonly) ALSdk *sdk;

@end

@implementation BIDApplovinRewarded
{
	id<BIDNetworkFullscreen> __weak adapter;
	
	NSString* adTag;
	BOOL isRewarded;
}

-(id)initWithNetworkFullscreen:(id<BIDNetworkFullscreen>)ntFull SDK:(id)nativeSDK adTag:(NSString *)adTag_ isRewarded:(BOOL)isRewarded_
{
	if (self = [super init])
	{
		adapter = ntFull;
		
		adTag = adTag_;
		isRewarded = isRewarded_;
		
		_rewardedAd = [[ALIncentivizedInterstitialAd alloc] initWithSdk:nativeSDK];
		_sdk = nativeSDK;
	}
	
	return self;
}

-(void)dealloc
{
    [_rewardedAd setAdDisplayDelegate:nil];
}

-(BOOL)readyToShow
{
    return nil != _ad;
}

#pragma mark - Load ad

-(void)loadWithBid:(id<BidappBid>)bid
{
	[_rewardedAd preloadAndNotify:self];
}

#pragma mark - ALAdLoadDelegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    _ad = ad;
    
	[adapter onAdLoaded];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
	BOOL isLoadError = NO;
	NSError* error = [NSError applovinErrorWithCode:code isLoadError:&isLoadError];
	if (isLoadError)
	{
		[adapter onAdFailedToLoadWithError:error];
	}
	else
	{
		[adapter onFailedToDisplay:error];
	}
}
	
#pragma mark - Display ad

-(BOOL)showWithViewController:(UIViewController *)vc
						 error:(NSError *__autoreleasing  _Nullable *)error
{
	[_rewardedAd setAdDisplayDelegate:self];
	[_rewardedAd showAd:_ad andNotify:self/* ALAdRewardDelegate */];
    
    return YES;
}

#pragma mark - ALAdDisplayDelegate protocol

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view
{
	[adapter onDisplay];
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view;
{
	[adapter onClick];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view
{
    [_rewardedAd setAdDisplayDelegate:nil];
    
    if (rewardLegitimated)
    {
		[adapter onReward];
        rewardLegitimated = NO;
    }

	[adapter onHide];
}

+(NSPointerArray*)delegateMethodsToValidate
{
    NSPointerArray *selectors = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsOpaqueMemory];
    
    [selectors addPointer:@selector(adService:didLoadAd:)];
    [selectors addPointer:@selector(adService:didFailToLoadAdWithError:)];
    [selectors addPointer:@selector(ad:wasDisplayedIn:)];
    [selectors addPointer:@selector(ad:wasClickedIn:)];
    [selectors addPointer:@selector(ad:wasHiddenIn:)];
    [selectors addPointer:@selector(rewardValidationRequestForAd:didSucceedWithResponse:)];
    [selectors addPointer:@selector(rewardValidationRequestForAd:didExceedQuotaWithResponse:)];
    [selectors addPointer:@selector(rewardValidationRequestForAd:wasRejectedWithResponse:)];
    [selectors addPointer:@selector(rewardValidationRequestForAd:didFailWithError:)];
    
    return selectors;
}

#pragma mark - ALAdRewardDelegate Protocol

- (void)rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response
{
    rewardLegitimated = YES;
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didExceedQuotaWithResponse:(NSDictionary *)response
{
}

- (void)rewardValidationRequestForAd:(ALAd *)ad wasRejectedWithResponse:(NSDictionary *)response
{
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didFailWithError:(NSInteger)responseCode
{
}

@end
