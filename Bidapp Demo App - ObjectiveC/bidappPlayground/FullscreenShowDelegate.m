//
//  FullscreenShowDelegate.m
//  bidappPlayground
//
//  Copyright 2023 bidapp. All rights reserved.
//

#import "FullscreenShowDelegate.h"
#import <bidapp/BIDAdInfo.h>
#import "tools.h"

@interface FullscreenShowDelegate()
{
	UIViewController* viewController;
}

@property(nonatomic) NSString* sessionId;
@property(nonatomic) NSString* waterfallId;

@end

@implementation FullscreenShowDelegate

-(id)initWithViewController:(UIViewController*)vc
{
	if (self = [super init])
	{
		viewController = vc;
	}
	
	return self;
}

#pragma mark - BIDInterstitialDelegate and BIDRewardedDelegate

- (nonnull UIViewController*)viewControllerForDisplayAd
{
	return viewController;
}

- (void)didDisplayAd:(BIDAdInfo*)adInfo
{
	_sessionId = adInfo.showSessionId;
	_waterfallId = adInfo.waterfallId;

	NSLog(@"[%@][%@] didDisplayAd: %d", sessionIdShort(adInfo.showSessionId), adInfo.waterfallId, adInfo.networkId);
}

- (void)didClickAd:(BIDAdInfo*)adInfo
{
	NSLog(@"[%@][%@] didClickAd: %d", sessionIdShort(adInfo.showSessionId), adInfo.waterfallId, adInfo.networkId);
}

- (void)didHideAd:(BIDAdInfo*)adInfo
{
	NSLog(@"[%@][%@] didHideAd: %d", sessionIdShort(adInfo.showSessionId), adInfo.waterfallId, adInfo.networkId);
}

- (void)didFailToDisplayAd:(BIDAdInfo*)adInfo error:(NSError *)error
{
	_sessionId = adInfo.showSessionId;
	_waterfallId = adInfo.waterfallId;
    
	NSLog(@"[%@][%@] didFailToDisplayAd: %d, ERROR: %@", sessionIdShort(adInfo.showSessionId), adInfo.waterfallId, adInfo.networkId, error.localizedDescription ? error.localizedDescription : error);
}

-(void)allNetworksDidFailToDisplayAd
{
	NSLog(@"[%@][%@] allNetworksDidFailToDisplayAd", sessionIdShort(_sessionId), _waterfallId);
}

#pragma mark - BIDRewardedDelegate

- (void)didRewardUser
{
	NSLog(@"[%@][%@] didRewardUser",sessionIdShort(_sessionId), _waterfallId);
}

@end
