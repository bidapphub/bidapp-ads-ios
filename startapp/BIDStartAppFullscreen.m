//
//  BIDStartAppFullscreen.m
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 19/4/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDStartAppFullscreen.h"

#import "BIDNetworkSettings.h"
#import "BIDTestBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"
#import "TestFullscreen.h"
#import "BIDStartAppSDK.h"
#import <StartApp/StartApp.h>

@interface BIDStartAppFullscreen()<STADelegateProtocol>
{
    STAStartAppAd* startAppAd;
    BOOL waitingOnReward;
    id<BIDNetworkFullscreen> __weak networkFullscreen;
    NSString* adTag;
    BOOL rewarded;
}

@end

@implementation BIDStartAppFullscreen

+ (NSString *)logPrefix { return @"StartAppFull"; }
- (NSString *)logPrefix { return [NSString stringWithFormat:@"%@ StartAppFull",rewarded ? @"rewarded" : @"interstitial"]; }

-(id)initWithNetworkFullscreen:(id<BIDNetworkFullscreen>)ntFull SDK:(id)networkSDK adTag:(NSString *)tag isRewarded:(BOOL)isRewarded
{
	if (self = [super init])
	{
		networkFullscreen = ntFull;
		
        rewarded = isRewarded;
        adTag = tag;
        
        startAppAd = [[STAStartAppAd alloc] init];
    }
    
    return self;
}

#pragma mark - Load ad

-(void)loadWithBid:(id<BidappBid>)bid
{
	BIDLog(self, @"load %@", adTag);
        
    STAAdPreferences *adPref = [STAAdPreferences preferencesWithMinCPM:0.0];
    if (adTag)
    {
        adPref.adTag = adTag;
    }
    
    if (rewarded)
    {
        [startAppAd loadRewardedVideoAdWithDelegate:self withAdPreferences:adPref];
    }
    else
    {
        [startAppAd loadAdWithDelegate:self withAdPreferences:adPref];
    }
}

#pragma mark - show ad

-(BOOL)readyToShow
{
    return startAppAd.isReady;
}

-(BOOL)showWithViewController:(UIViewController *)vc error:(NSError *__autoreleasing  _Nullable *)error
{
    BIDLog(self,@"showWithViewController: %@ adTag: %@", vc, adTag);

    [startAppAd showAd];
    
    return YES;
}

+(NSPointerArray*)delegateMethodsToValidate
{
    NSPointerArray *selectors = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsOpaqueMemory];
    
    [selectors addPointer:@selector(didShowAd:)];
    [selectors addPointer:@selector(failedShowAd:withError:)];
    [selectors addPointer:@selector(didCloseAd:)];
    [selectors addPointer:@selector(didClickAd:)];
    [selectors addPointer:@selector(didLoadAd:)];
    [selectors addPointer:@selector(failedLoadAd:withError:)];
    [selectors addPointer:@selector(didCloseInAppStore:)];
    [selectors addPointer:@selector(didCompleteVideo:)];
    
    return selectors;
}

#pragma mark - STADelegateProtocol

- (void)didShowAd:(STAAbstractAd*)ad
{
    BIDLog(self,@"didShowAd");
           
    [networkFullscreen onDisplay];
    
    waitingOnReward = rewarded;
}

- (void)failedShowAd:(STAAbstractAd *)ad withError:(NSError *)error
{
    BIDLog(self,@"failedShowAd %@", error);
    
    [networkFullscreen onFailedToDisplay:error];
}

- (void)didCloseAd:(STAAbstractAd*)ad
{
    BIDLog(self,@"didCloseAd");
    
    [networkFullscreen  onHide];
}

- (void)didClickAd:(STAAbstractAd*)ad
{
    [networkFullscreen onClick];
}

- (void)didLoadAd:(STAAbstractAd*)ad
{
    BIDLog(self,@"didLoadAd");
    
    [networkFullscreen onAdLoaded];
}

- (void)failedLoadAd:(STAAbstractAd*)ad withError:(NSError *)error
{
    BIDLog(self,@"failedLoadAd %@", error);
    
    [networkFullscreen onAdFailedToLoadWithError:error];
}

- (void)didCloseInAppStore:(STAAbstractAd*)ad
{
}

- (void)didCompleteVideo:(STAAbstractAd*)ad
{
    if (![NSThread isMainThread])
    {
        __weak typeof(self) weakSelf = self;
        return dispatch_async(dispatch_get_main_queue(), ^(){
            
            [weakSelf didCompleteVideo:ad];
        });
    }
    
    if (waitingOnReward)
    {
        waitingOnReward = NO;
        
        [networkFullscreen onReward];
    }
}

@end
