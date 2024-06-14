//
//  BIDFacebookInterstitial.m
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 19/4/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDFacebookInterstitial.h"

#import "BIDNetworkSettings.h"
#import "BIDTestBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"
#import "TestFullscreen.h"
#import "BIDFacebookSDK.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface BIDFacebookInterstitial()<FBInterstitialAdDelegate>
{
    BOOL waitingOnReward;
    id<BIDNetworkFullscreen> __weak networkFullscreen;
    NSString* adTag;
    BOOL rewarded;
}

@property(nonatomic,readonly) FBInterstitialAd* interstitial;
@property(nonatomic,readonly) BOOL readyToShow;

@end

@implementation BIDFacebookInterstitial

+ (NSString *)logPrefix { return @"FacebookInterstitial"; }
- (NSString *)logPrefix { return @"FacebookInterstitial"; }

-(id)initWithNetworkFullscreen:(id<BIDNetworkFullscreen>)ntFull SDK:(id)networkSDK adTag:(NSString *)tag isRewarded:(BOOL)isRewarded
{
	if (self = [super init])
	{
		networkFullscreen = ntFull;
		
        rewarded = isRewarded;
        adTag = tag;
        
        _interstitial = [[FBInterstitialAd alloc] initWithPlacementID:tag];
        _interstitial.delegate = self;
    }
    
    return self;
}

#pragma mark - Load ad

-(void)loadWithBid:(id<BidappBid>)bid
{
	BIDLog(self, @"load %@", adTag);
    
    [_interstitial loadAd];
}

#pragma mark - show ad

-(BOOL)showWithViewController:(UIViewController *)vc error:(NSError *__autoreleasing  _Nullable *)error
{
    BIDLog(self,@"showWithViewController: %@ adTag: %@", vc, adTag);

    [_interstitial showAdFromRootViewController:vc];
    
    return YES;
}

+(NSPointerArray*)delegateMethodsToValidate
{
    NSPointerArray *selectors = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsOpaqueMemory];
    
    [selectors addPointer:@selector(interstitialAdDidLoad:)];
    [selectors addPointer:@selector(interstitialAd:didFailWithError:)];
    [selectors addPointer:@selector(interstitialAdDidClose:)];
    [selectors addPointer:@selector(interstitialAdDidClick:)];

    return selectors;
}

#pragma mark - FBInterstitialAdDelegate

-(void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd
{
    if (!interstitialAd ||
        !interstitialAd.isAdValid)
    {
        return [networkFullscreen onAdFailedToLoadWithError:[NSError errorWithDomain:@"com.facebook"
                                                                   code:389555
                                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Ad is nil or invalid",NSLocalizedDescriptionKey, nil]]];
    }
    
    _readyToShow = YES;
    [networkFullscreen onAdLoaded];
}

-(void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    if (!_readyToShow)
    {
        [networkFullscreen onAdFailedToLoadWithError:error];
    }
    else
    {
        _interstitial.delegate = nil;
        [networkFullscreen onFailedToDisplay:error];
    }
}

-(void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd
{
    _interstitial.delegate = nil;
    
    [networkFullscreen onHide];
}

-(void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd
{
    [networkFullscreen onClick];
}

@end
