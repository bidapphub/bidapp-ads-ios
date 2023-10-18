//
//  FullscreenLoadDelegate.m
//  bidappPlayground
//
//  Copyright 2023 bidapp. All rights reserved.
//

#import "FullscreenLoadDelegate.h"
#import "tools.h"
#import <bidapp/BIDAdInfo.h>
#import <bidapp/BIDAdFormat.h>

@implementation FullscreenLoadDelegate

#pragma mark - BIDFullscreenLoadDelegate

- (void)didLoadAd:(BIDAdInfo*)adInfo
{
	NSLog(@"[%@] didLoadAd: %d. IsRewarded: %@ ", sessionIdShort(adInfo.loadSessionId), adInfo.networkId, (adInfo.format.isRewarded) ? @"YES" : @"NO");
}

- (void)didFailToLoadAd:(BIDAdInfo*)adInfo error:(NSError *)error
{
	NSLog(@"[%@] didFailToLoadAd: %d. ERROR: %@", sessionIdShort(adInfo.loadSessionId), adInfo.networkId, error.localizedDescription ? error.localizedDescription : error);
}

@end
