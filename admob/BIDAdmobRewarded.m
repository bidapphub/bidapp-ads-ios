//
//  BIDAdmobRewarded.m
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 19/4/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDAdmobRewarded.h"

#import "BIDNetworkSettings.h"
#import "BIDAdmobSDK.h"
#import "BIDAdmobBanner.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"
#import "NSError+Categories.h"

#import <GoogleMobileAds/GoogleMobileAds.h>

@interface BIDAdmobRewarded()<GADFullScreenContentDelegate>

@property (nonatomic,readonly) NSString* adUnitId;
@property (nonatomic) GADRewardedAd* loadedAd;
@property (nonatomic,readonly, weak) id<BIDNetworkFullscreen> networkFullscreen;
@property (nonatomic, readonly) NSString* userId;
@property (nonatomic, readonly) BOOL userIdWasSet;

@end

@implementation BIDAdmobRewarded

+ (NSString *)logPrefix { return @"AdmobRewarded"; }
- (NSString *)logPrefix { return @"rewarded Admob"; }

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

-(void)load
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
    [GADRewardedAd loadWithAdUnitID:_adUnitId
                            request:request
                  completionHandler:^(GADRewardedAd * _Nullable ad, NSError * _Nullable error) {
        
        if (nil!=ad && nil==error)
        {
            BIDLog(weakSelf,@"Ad loaded at AdUnitID %@", weakSelf.adUnitId);
            
            GADServerSideVerificationOptions *options = [[GADServerSideVerificationOptions alloc] init];

            if (weakSelf.userIdWasSet)
            {
                options.userIdentifier = weakSelf.userId;
            }
            
            ad.serverSideVerificationOptions = options;
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

    __weak typeof(self)weakSelf = self;
    [_loadedAd presentFromRootViewController:vc userDidEarnRewardHandler:^{
        
        [weakSelf.networkFullscreen onReward];
    }];
    
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

-(void)setUserId:(NSString*)userIdentifier
{
    _userId = userIdentifier;
    _userIdWasSet = YES;
    
    GADServerSideVerificationOptions *options = [[GADServerSideVerificationOptions alloc] init];
    options.userIdentifier = userIdentifier;
    _loadedAd.serverSideVerificationOptions = options;
}

@end
