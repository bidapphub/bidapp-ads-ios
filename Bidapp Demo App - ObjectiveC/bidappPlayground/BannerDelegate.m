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

- (void)adView:(BIDBannerView *)adView readyToRefresh:(BIDAdInfo *)adInfo
{
	NSLog(@"[%@][%@] readyToRefreshBanner: %d", sessionIdShort(adInfo.showSessionId), adInfo.waterfallId, adInfo.networkId);
	
	if (!adView.isAdDisplayed)
	{
		[adView refreshAd];
	}
}

- (void)adView:(BIDBannerView *)adView didDisplayAd:(BIDAdInfo *)adInfo
{
	NSLog(@"[%@][%@] didDisplayBanner: %d", sessionIdShort(adInfo.showSessionId), adInfo.waterfallId, adInfo.networkId);
}

- (void)adView:(BIDBannerView *)adView didFailToDisplayAd:(nonnull BIDAdInfo *)adInfo error:(nonnull NSError *)error
{
	NSLog(@"[%@][%@] didFailToDisplayBanner: %d ERROR: %@", sessionIdShort(adInfo.showSessionId), adInfo.waterfallId, adInfo.networkId, error.localizedDescription ? error.localizedDescription : error);
}

- (void)adView:(BIDBannerView *)adView didClicked:(BIDAdInfo *)adInfo
{
	NSLog(@"[%@][%@] bannerDidClicked: %d", sessionIdShort(adInfo.showSessionId), adInfo.waterfallId, adInfo.networkId);
}


@end
