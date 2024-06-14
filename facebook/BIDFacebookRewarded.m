//
//  BIDFacebookRewarded.m
//  bidapp
//
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDFacebookRewarded.h"

#import "BIDNetworkSettings.h"
#import "BIDTestBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"
#import "TestFullscreen.h"
#import "BIDFacebookSDK.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface BIDFacebookRewarded()<FBRewardedVideoAdDelegate>
{
    BOOL waitingOnReward;
    id<BIDNetworkFullscreen> __weak networkFullscreen;
    NSString* adTag;
}

@property(nonatomic,readonly) FBRewardedVideoAd* rewarded;
@property(nonatomic,readonly) BOOL readyToShow;

@end

@implementation BIDFacebookRewarded

+ (NSString *)logPrefix { return @"FacebookRewarded"; }
- (NSString *)logPrefix { return @"FacebookRewarded"; }

-(id)initWithNetworkFullscreen:(id<BIDNetworkFullscreen>)ntFull SDK:(id)networkSDK adTag:(NSString *)tag isRewarded:(BOOL)isRewarded
{
	if (self = [super init])
	{
		networkFullscreen = ntFull;
    
        adTag = tag;
        
        _rewarded = [[FBRewardedVideoAd alloc] initWithPlacementID:tag];
        _rewarded.delegate = self;
    }
    
    return self;
}

#pragma mark - Load ad

-(void)loadWithBid:(id<BidappBid>)bid
{
	BIDLog(self, @"load %@", adTag);
    
    [_rewarded loadAd];
}

#pragma mark - show ad

-(BOOL)showWithViewController:(UIViewController *)vc error:(NSError *__autoreleasing  _Nullable *)error
{
    BIDLog(self,@"showWithViewController: %@ adTag: %@", vc, adTag);

    [_rewarded showAdFromRootViewController:vc];
    
    return YES;
}

+(NSPointerArray*)delegateMethodsToValidate
{
    NSPointerArray *selectors = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsOpaqueMemory];
    
    [selectors addPointer:@selector(rewardedVideoAdDidLoad:)];
    [selectors addPointer:@selector(rewardedVideoAd:didFailWithError:)];
    [selectors addPointer:@selector(rewardedVideoAdDidClose:)];
    [selectors addPointer:@selector(rewardedVideoAdDidClick:)];
    [selectors addPointer:@selector(rewardedVideoAdVideoComplete:)];
    
    return selectors;
}

#pragma mark - STADelegateProtocol

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd
{
    if (!rewardedVideoAd ||
        !rewardedVideoAd.isAdValid)
    {
        return [networkFullscreen onAdFailedToLoadWithError:[NSError errorWithDomain:@"com.facebook"
                                                                   code:389555
                                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Ad is nil or invalid",NSLocalizedDescriptionKey, nil]]];
    }
    
    _readyToShow = YES;
    [networkFullscreen onAdLoaded];
}

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    if (!_readyToShow)
    {
        [networkFullscreen onAdFailedToLoadWithError:error];
    }
    else
    {
        _rewarded.delegate = nil;
        [networkFullscreen onFailedToDisplay:error];
    }
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    _rewarded.delegate = nil;
    
    [networkFullscreen onHide];
}

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd
{
    [networkFullscreen onClick];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd
{
    [networkFullscreen onReward];
}

@end
