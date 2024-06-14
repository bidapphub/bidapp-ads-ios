//
//  BannerDelegate.m
//  bidappPlayground
//
//  Copyright 2023 bidapp. All rights reserved.
//

#import "BannerDelegate.h"
#import "tools.h"
#import <bidapp/BIDAdInfo.h>

@implementation BannerDelegate

- (void)bannerDidLoad:(BIDBannerView *)banner adInfo:(BIDAdInfo *)adInfo
{
    NSLog(@"[%@][%@] bannerDidLoad: %d", sessionIdShort(adInfo.showSessionId), adInfo.waterfallId, adInfo.networkId);
    
    if (!banner.isAdDisplayed)
    {
        [banner refreshAd];
    }
}

- (void)bannerDidDisplay:(BIDBannerView *)banner adInfo:(BIDAdInfo *)adInfo
{
	NSLog(@"[%@][%@] bannerDidDisplay: %d", sessionIdShort(adInfo.showSessionId), adInfo.waterfallId, adInfo.networkId);
}

- (void)bannerDidFailToDisplay:(BIDBannerView *)banner adInfo:(BIDAdInfo *)adInfo error:(NSError *)error
{
	NSLog(@"[%@][%@] bannerDidFailToDisplay: %d ERROR: %@", sessionIdShort(adInfo.showSessionId), adInfo.waterfallId, adInfo.networkId, error.localizedDescription ? error.localizedDescription : error);
}

- (void)bannerDidClick:(BIDBannerView *)banner adInfo:(BIDAdInfo *)adInfo
{
	NSLog(@"[%@][%@] bannerDidClicked: %d", sessionIdShort(adInfo.showSessionId), adInfo.waterfallId, adInfo.networkId);
}

- (void)allNetworksFailedToDisplayAdInBanner:(BIDBannerView *)banner
{
    NSLog(@"allNetworksFailedToDisplayAdInBanner");
}

@end
