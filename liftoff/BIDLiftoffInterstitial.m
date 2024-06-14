//
//  BIDLiftoffInterstitial.m
//  bidapp
//
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDLiftoffInterstitial.h"

#import "BIDNetworkSettings.h"
#import "BIDLiftoffBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"
#import "BidappBid.h"
#import "BIDOpenRTBRequester.h"

#import <VungleAdsSDK/VungleAdsSDK.h>

@interface BIDLiftoffInterstitial()<VungleInterstitialDelegate>
{
	id<BIDNetworkFullscreen> __weak networkFullscreen;

	BOOL isRewarded;
}

@property (nonatomic, strong) VungleInterstitial *interstitialAd;
@property (nonatomic,readonly) NSString* placementId;
@property (nonatomic,strong) NSString* loadedPlacementId;

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

-(void)loadWithBid:(id<BidappBid>)bid
{
	[_interstitialAd load:(NSString*)bid.nativeBid];
}

#pragma mark - VungleInterstitialDelegate - load

- (void)interstitialAdDidLoad:(VungleInterstitial * _Nonnull)interstitial
{
	_loadedPlacementId = _placementId;
	
	[networkFullscreen onAdLoaded];
}

- (void)interstitialAdDidFailToLoad:(VungleInterstitial * _Nonnull)interstitial withError:(NSError * _Nonnull)e
{
    NSString *message = (nil!=e.localizedDescription) ? e.localizedDescription : @"Unknown error";
    [networkFullscreen onAdFailedToLoadWithError:[NSError errorWithDomain:@"io.bidapp.liftoff"
                                                                     code:e.code ? e.code : 395822
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
	[_interstitialAd presentWith:vc];

	return YES;
}

+(NSPointerArray*)delegateMethodsToValidate
{
    NSPointerArray *selectors = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsOpaqueMemory];

    [selectors addPointer:@selector(interstitialAdDidLoad:)];
    [selectors addPointer:@selector(interstitialAdDidFailToLoad:withError:)];
    [selectors addPointer:@selector(interstitialAdDidFailToPresent:withError:)];
    [selectors addPointer:@selector(interstitialAdDidClose:)];
    [selectors addPointer:@selector(interstitialAdDidClick:)];
    
    return selectors;
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

#pragma mark - bidding

static NSString* publisherId_ = nil;
static NSString* appId_ = nil;
+(void)setAppId:(NSString*)appId publisherId:(NSString*)publisherId
{
    appId_ = appId;
    publisherId_ = publisherId;
}

+ (void)bidWithRequester:(id<BIDOpenRTBRequester>)requester
                   adTag:(NSString*)adTag
                  format:(id<BIDAdFormat>)format
                testMode:(BOOL)testMode
                 timeout:(NSTimeInterval)timeout
              completion:(bidding_complete_t)completion
{
    if (nil == appId_ ||
        nil == publisherId_)
    {
        return completion(nil, adTag, [NSError errorWithDomain:@"io.bidapp.liftoff"
                                                          code:399122
                                                      userInfo:@{NSLocalizedDescriptionKey:@"Vungle publisherId or appId is absent. They are required to perform bid request."}]);
    }
    
    [requester bidWithToken:VungleAds.getBiddingToken
                publisherId:publisherId_
                      appId:appId_
                      adTag:adTag
                     format:format
                       test:testMode
                 completion:completion];
}

@end
