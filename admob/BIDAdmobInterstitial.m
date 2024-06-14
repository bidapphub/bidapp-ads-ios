//
//  BIDAdmobInterstitial.m
//  bidapp
//
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDAdmobInterstitial.h"

#import "BIDNetworkSettings.h"
#import "BIDAdmobSDK.h"
#import "BIDAdmobBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"

#import <GoogleMobileAds/GoogleMobileAds.h>

@interface BIDAdmobInterstitial()<GADFullScreenContentDelegate>

@property (nonatomic,readonly) NSString* adUnitId;
@property (nonatomic) GADInterstitialAd* loadedAd;
@property (nonatomic,readonly, weak) id<BIDNetworkFullscreen> networkFullscreen;

@end

@implementation BIDAdmobInterstitial

+ (NSString *)logPrefix { return @"AdmobInterstitial"; }
- (NSString *)logPrefix { return @"interstitial Admob"; }

-(id)initWithNetworkFullscreen:(id<BIDNetworkFullscreen>)ntFull SDK:(id)networkSDK adTag:(NSString *)tag isRewarded:(BOOL)isRewarded
{
	if (self = [super init])
	{
		_networkFullscreen = ntFull;
		
        _adUnitId = tag;
    }
    
    return self;
}

#pragma mark - Load ad

-(void)loadWithBid:(id<BidappBid>)bid
{
	BIDLog(self, @"_load %@", _adUnitId);
    
    GADRequest* request = [GADRequest request];
    
    if (BIDAdmobSDK.GDPR)
    {
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = @{ @"npa": @( !BIDAdmobSDK.GDPR.boolValue ) };
        [request registerAdNetworkExtras:extras];
    }
    
    __weak typeof(self)weakSelf = self;
    [GADInterstitialAd loadWithAdUnitID:_adUnitId
                                request:request
                      completionHandler:^(GADInterstitialAd * _Nullable ad, NSError * _Nullable error) {
        
        if (nil!=ad && nil==error)
        {
            BIDLog(weakSelf,@"Ad loaded at AdUnitID %@", weakSelf.adUnitId);
            
            ad.fullScreenContentDelegate = weakSelf;
            
            [weakSelf.networkFullscreen onAdLoaded];
            weakSelf.loadedAd = ad;
        }
        else
        {
            BIDLog(weakSelf,@"Failed to load ad for AdUnitID %@. Error: %@", weakSelf.adUnitId,error);
            
            [weakSelf.networkFullscreen onAdFailedToLoadWithError:error];
        }
    }];
}

#pragma mark - show ad

-(BOOL)readyToShow
{
    return nil != _loadedAd;
}

-(BOOL)showWithViewController:(UIViewController *)vc error:(NSError *__autoreleasing  _Nullable *)error
{
    BIDLog(self,@"_showWithViewController: %@ adUnitId: %@", vc, _adUnitId);

    [_loadedAd presentFromRootViewController:vc];
    
    return YES;
}

-(BOOL)viewControllerNeededForDisplay
{
    return YES;
}

-(BOOL)shouldWaitForAdToDisplay
{
    return YES;
}

+(NSPointerArray*)delegateMethodsToValidate
{
    NSPointerArray *selectors = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsOpaqueMemory];

    [selectors addPointer:@selector(adWillPresentFullScreenContent:)];
    [selectors addPointer:@selector(ad:didFailToPresentFullScreenContentWithError:)];
    [selectors addPointer:@selector(adDidDismissFullScreenContent:)];
    [selectors addPointer:@selector(adDidRecordClick:)];
    
    return selectors;
}

#pragma mark - GADFullScreenContentDelegate

- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad
{
    BIDLog(self, @"adWillPresentFullScreenContent: %@", ad);
    
    [_networkFullscreen onDisplay];
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error
{
    BIDLog(self, @"ad: %@ didFailToPresentFullScreenContentWithError: %@", ad, error);
    
    _loadedAd = nil;
    [_networkFullscreen onFailedToDisplay:error];
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad
{
    BIDLog(self, @"adDidDismissFullScreenContent: %@", ad);
    
    _loadedAd = nil;
    [_networkFullscreen onHide];
}

- (void)adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>)ad
{
    [_networkFullscreen onClick];
}

@end
