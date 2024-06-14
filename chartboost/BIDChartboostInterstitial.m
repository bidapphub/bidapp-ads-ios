//
//  BIDChartboostInterstitial.m
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 19/4/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDChartboostInterstitial.h"

#import "BIDNetworkSettings.h"
#import "BIDTestBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"

#import <ChartboostSDK/ChartboostSDK.h>

@interface BIDChartboostInterstitial()<CHBInterstitialDelegate>
{
	id<BIDNetworkFullscreen> __weak networkFullscreen;
    
    CHBInterstitial* interstitial;
    CHBInterstitial* loadedAd;
}

@property (nonatomic,readonly) NSString* location;

@end

@implementation BIDChartboostInterstitial

+ (NSString *)logPrefix { return @"ChartboostInterstitial"; }
- (NSString *)logPrefix { return @"interstitial Chartboost"; }

-(id)initWithNetworkFullscreen:(id<BIDNetworkFullscreen>)ntFull SDK:(id)networkSDK adTag:(NSString *)tag isRewarded:(BOOL)isRewarded
{
	if (self = [super init])
	{
		networkFullscreen = ntFull;
        _location = tag;
    }
    
    return self;
}

#pragma mark - Load ad

-(void)loadWithBid:(id<BidappBid>)bid
{
	BIDLog(self, @"_load %@", _location);
    
    interstitial = [[CHBInterstitial alloc] initWithLocation:_location delegate:self];
    [interstitial cache];
}

#pragma mark - show ad

-(BOOL)readyToShow
{
    return nil != loadedAd;
}

-(BOOL)showWithViewController:(UIViewController *)vc error:(NSError *__autoreleasing  _Nullable *)error
{
    BIDLog(self,@"_showWithViewController: %@ location: %@", vc, _location);

    [loadedAd showFromViewController:vc];
    
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

    [selectors addPointer:@selector(didCacheAd:error:)];
    [selectors addPointer:@selector(didShowAd:error:)];
    [selectors addPointer:@selector(didDismissAd:)];
    [selectors addPointer:@selector(didClickAd:error:)];
    
    return selectors;
}

#pragma mark - CHBAdDelegate

-(void)didCacheAd:(CHBCacheEvent *)event error:(CHBCacheError *)error
{
    BIDLog(self, @"didCacheAd: %@ error: %@", event.ad.location, error);
    
    if (!error)
    {
        loadedAd = interstitial;
        
        [networkFullscreen onAdLoaded];
    }
    else
    {
        [networkFullscreen onAdFailedToLoadWithError:error];
    }
    
    interstitial = nil;
}

-(void)didShowAd:(CHBShowEvent *)event error:(CHBShowError *)error
{
    BIDLog(self, @"didShowAd: %@ error: %@", event.ad.location, error);
    
    if (!error)
    {
        [networkFullscreen onDisplay];
    }
    else
    {
        [networkFullscreen onFailedToDisplay:error];
        loadedAd = nil;
    }
}

-(void)didDismissAd:(CHBDismissEvent *)event
{
    BIDLog(self, @"didDismissAd: %@", event.ad.location);
    
    [networkFullscreen onHide];
    loadedAd = nil;
}

-(void)didClickAd:(CHBClickEvent *)event error:(CHBClickError *)error
{
    [networkFullscreen onClick];
}

@end
