//
//  BIDTestFullscreen.m
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 19/4/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDTestFullscreen.h"

#import "BIDNetworkSettings.h"
#import "BIDTestBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"
#import "TestFullscreen.h"
#import "NSError+Categories.h"

@interface BIDTestFullscreen()<TestAdLoadDelegate,TestAdShowDelegate>
{
	id<BIDNetworkFullscreen> __weak networkFullscreen;
    
    id _fullscreen;
    TestAd* loadedAd;
}

@property (nonatomic,readonly) NSString* placementId;
@property (nonatomic,readonly) BOOL rewarded;

@end

@implementation BIDTestFullscreen

+ (NSString *)logPrefix { return @"TestFull"; }
- (NSString *)logPrefix { return [NSString stringWithFormat:@"%@ TestFull",_rewarded ? @"rewarded" : @"interstitial"]; }

-(id)initWithNetworkFullscreen:(id<BIDNetworkFullscreen>)ntFull SDK:(id)networkSDK adTag:(NSString *)tag isRewarded:(BOOL)isRewarded
{
	if (self = [super init])
	{
		networkFullscreen = ntFull;
		
        _rewarded = isRewarded;
        _placementId = tag;
    }
    
    return self;
}

#pragma mark - Load ad

-(void)load
{
	BIDLog(self, @"_load %@", _placementId);
    
    _fullscreen = _rewarded ? [TestRewarded new] : [TestInterstitial new];
    [_fullscreen loadWithDelegate:self];
}

#pragma mark - TestFullscreenDelegate

-(void)onFullscreen:(id)fullscreen didLoadAd:(TestAd*)ad
{
    if (fullscreen == _fullscreen)
    {
        [networkFullscreen onAdLoaded];
        loadedAd = ad;
        _fullscreen = nil;
    }
}

-(void)onFullscreenDidFailedToLoadAd:(id)fullscreen error:(NSError*)error
{
    if (fullscreen == _fullscreen)
    {
        [networkFullscreen onAdFailedToLoadWithError:error];
        _fullscreen = nil;
    }
}

#pragma mark - show ad

-(BOOL)readyToShow
{
    return nil != loadedAd;
}

-(BOOL)showWithViewController:(UIViewController *)vc error:(NSError *__autoreleasing  _Nullable *)error
{
    BIDLog(self,@"_showWithViewController: %@ placementId: %@", vc, _placementId);

    [loadedAd showWithDelegate:self fromViewController:vc];
    
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

#pragma mark - TestViewControllerShowDelegate

-(void)onAdWillAppear:(TestAd*)ad
{
}

-(void)onAdDidAppear:(TestAd*)ad
{
    [networkFullscreen onDisplay];
}

-(void)onAdDidFailedToAppear:(TestAd*)ad error:(NSError*)error
{
    [networkFullscreen onFailedToDisplay:error];
    loadedAd = nil;
}

-(void)onAdDidClick:(TestAd*)ad
{
    [networkFullscreen onClick];
}

-(void)onAdDidDisappear:(TestAd*)ad
{
    [networkFullscreen onHide];
    loadedAd = nil;
}

-(void)onReward
{
    [networkFullscreen onReward];
}

@end
