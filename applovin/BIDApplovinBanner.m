//
//  BIDApplovinBanner.m
//  bidapp
//
//  Created by Vasiliy Masnev on 28.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDApplovinBanner.h"
#import "BIDNetworkBanner.h"

#import <AppLovinSDK/AppLovinSDK.h>

#import "BIDAdFormat.h"
#import "BIDNetworkSettings.h"
#import "NSError+AppLovin.h"

@interface BIDApplovinBanner () <ALAdLoadDelegate,ALAdDisplayDelegate>
{
	NSString* formatName;
	NSString* _ownerId;
	
	ALAdView* adView;
	
	id<BIDNetworkBanner> __weak networkBanner;
}

@property (nonatomic,strong) ALAd *cachedAd;

@end

@implementation BIDApplovinBanner

+ (NSString *)logPrefix { return @"ApplovinBanner"; }
- (NSString *)logPrefix { return [NSString stringWithFormat:@"%@:%@ ApplovinBanner",formatName,_ownerId]; }

+ (instancetype)bannerWithNetworkBanner:(id<BIDNetworkBanner>)ntBanner
									 SDK:(id)sdk
								   adTag:(NSString*)adTag
								  format:(id<BIDAdFormat>)format
								 ownerId:(NSString * __nullable)ownerId
{
	ALAdSize *alsize = nil;
	if (format.isBanner_320x50)
	{
		alsize = [ALAdSize banner];
	}
	else if (format.isBanner_300x250)
	{
		alsize = [ALAdSize mrec];
	}
    else if (format.isBanner_728x90)
    {
        alsize = [ALAdSize leader];
    }
	else
	{
		BIDLog(self, @"ERROR - Unsuported applovin banner format: %@", format);
		return nil;
	}

	ALSdk *alSDK = sdk;
	ALAdView *adView = [[ALAdView alloc] initWithSdk:alSDK size:alsize];
	if (nil==adView) {
		return nil;
	}
	
	BIDApplovinBanner *banner = [[BIDApplovinBanner alloc] init];
	if (banner)
	{
		banner->networkBanner = ntBanner;
		banner->formatName = format.name;
		banner->_ownerId = ownerId;
		
		banner->adView = adView;
#ifdef DEBUG
		adView.backgroundColor = [UIColor redColor];
#endif
		adView.frame = format.bounds;
		adView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
								   UIViewAutoresizingFlexibleBottomMargin |
								   UIViewAutoresizingFlexibleLeftMargin |
								   UIViewAutoresizingFlexibleRightMargin);
		adView.autoload = NO;
		adView.adLoadDelegate = banner;
		adView.adDisplayDelegate = banner;
	}
	
	return banner;
}

-(UIView*)nativeAdView
{
	return adView;
}

-(void)prepareForDealloc
{
    adView = nil;
    _cachedAd = nil;
}

#pragma mark - BIDCacheable

- (BOOL)isAdReady
{
	return nil != self.cachedAd;
}

- (void)loadWithBid:(id<BidappBid>)bid
{
	[adView loadNextAd];
}

#pragma mark - ALAdLoadDelegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
	self.cachedAd = ad;
	
	[networkBanner onLoad];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
	[networkBanner onFailedToLoad:[NSError applovinBannerErrorWithCode:code]];
}

#pragma mark - show

-(BOOL)showOnView:(UIView*)view error:(NSError *__autoreleasing  _Nullable *)error
{
	adView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
	[view insertSubview:adView atIndex:0];
	
	return YES;
}

+(NSPointerArray*)delegateMethodsToValidate
{
    NSPointerArray *selectors = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsOpaqueMemory];

    [selectors addPointer:@selector(adService:didLoadAd:)];
    [selectors addPointer:@selector(adService:didFailToLoadAdWithError:)];
    [selectors addPointer:@selector(ad:wasDisplayedIn:)];
    [selectors addPointer:@selector(ad:wasClickedIn:)];
    [selectors addPointer:@selector(ad:wasHiddenIn:)];
    
    return selectors;
}

#pragma mark - ALAdDisplayDelegate

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view
{
	BIDLog(self, @"Did Display ad");
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view
{
	BIDLog(self, @"Did Hide ad");
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view
{
	BIDLog(self, @"Did Click ad");
	
	[networkBanner onClick];
}

@end
