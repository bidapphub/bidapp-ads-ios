//
//  BIDChartboostRewarded.m
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 19/4/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDChartboostRewarded.h"

#import "BIDNetworkSettings.h"
#import "BIDTestBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"
#import "TestFullscreen.h"
#import "NSError+Categories.h"

#import <ChartboostSDK/ChartboostSDK.h>

@interface BIDChartboostRewarded()<CHBRewardedDelegate>
{
    id<BIDNetworkFullscreen> __weak networkFullscreen;
    
    CHBRewarded* rewarded;
    CHBRewarded* loadedAd;
}

@property (nonatomic,readonly) NSString* location;

@end

@implementation BIDChartboostRewarded

+ (NSString *)logPrefix { return @"ChartboostRewarded"; }
- (NSString *)logPrefix { return @"rewarded Chartboost"; }

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

-(void)load
{
    BIDLog(self, @"_load %@", _location);
    
    rewarded = [[CHBRewarded alloc] initWithLocation:_location delegate:self];
    [rewarded cache];
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

-(void)didCacheAd:(CHBCacheEvent *)event error:(CHBCacheError *)error
{
    BIDLog(self, @"didCacheAd: %@ error: %@", event.ad.location, error);
    
    if (!error)
    {
        loadedAd = rewarded;
        
        [networkFullscreen onAdLoaded];
    }
    else
    {
        [networkFullscreen onAdFailedToLoadWithError:error];
    }
    
    rewarded = nil;
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

- (void)didEarnReward:(CHBRewardEvent *)event
{
    [networkFullscreen onReward];
}

@end
