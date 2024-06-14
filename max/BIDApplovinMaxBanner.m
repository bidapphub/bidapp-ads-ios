//
//  BIDApplovinMaxBanner.m
//  bidapp
//
//  Created by Vasiliy Masnev on 28.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDApplovinMaxBanner.h"
#import "BIDNetworkBanner.h"

#import <AppLovinSDK/AppLovinSDK.h>

#import "BIDAdFormat.h"
#import "BIDNetworkSettings.h"

@interface BIDApplovinMaxBanner () <MAAdViewAdDelegate>
{
	NSString* formatName;
	NSString* _ownerId;
	
	MAAdView* adView;
	
	id<BIDNetworkBanner> __weak networkBanner;
}

@property (nonatomic,strong) MAAd *cachedAd;

@end

@implementation BIDApplovinMaxBanner

+ (NSString *)logPrefix { return @"MaxBanner"; }
- (NSString *)logPrefix { return [NSString stringWithFormat:@"%@:%@ MaxBanner",formatName,_ownerId]; }

+ (instancetype)bannerWithNetworkBanner:(id<BIDNetworkBanner>)ntBanner
									 SDK:(id)sdk
								   adTag:(NSString*)adTag
								  format:(id<BIDAdFormat>)format
								 ownerId:(NSString * __nullable)ownerId
{
	MAAdFormat *adFormat = nil;
	if (format.isBanner_320x50)
	{
		adFormat = MAAdFormat.banner;
	}
	else if (format.isBanner_300x250)
	{
		adFormat = MAAdFormat.mrec;
	}
    else if (format.isBanner_728x90)
    {
        adFormat = MAAdFormat.leader;
    }
	else
	{
		BIDLog(self, @"ERROR - Unsuported applovin MAX banner format: %@", format);
		return nil;
	}

	ALSdk *alSDK = sdk;
	MAAdView *adView = [[MAAdView alloc] initWithAdUnitIdentifier:adTag adFormat:adFormat sdk:alSDK];
	if (nil==adView) {
		return nil;
	}
	
	BIDApplovinMaxBanner *banner = [[BIDApplovinMaxBanner alloc] init];
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
		adView.delegate = banner;
		
		// Set this extra parameter to work around SDK bug that ignores calls to stopAutoRefresh()
		[adView setExtraParameterForKey:@"allow_pause_auto_refresh_immediately" value:@"true"];
		[adView stopAutoRefresh];
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
	[adView loadAd];
}

#pragma mark - MAAdViewAdDelegate

- (void)didLoadAd:(MAAd *)ad
{
	self.cachedAd = ad;
	
	[networkBanner onLoad];
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error
{
	NSError *bError = [NSError errorWithDomain:@"io.bidapp.max"
																			 code:error.code
																	 userInfo:@{NSLocalizedDescriptionKey:error.message}];
	
	[networkBanner onFailedToLoad:bError];
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

    [selectors addPointer:@selector(didLoadAd:)];
    [selectors addPointer:@selector(didFailToLoadAdForAdUnitIdentifier:withError:)];
    [selectors addPointer:@selector(didDisplayAd:)];
    [selectors addPointer:@selector(didFailToDisplayAd:withError:)];
    [selectors addPointer:@selector(didClickAd:)];
    [selectors addPointer:@selector(didHideAd:)];
    [selectors addPointer:@selector(didExpandAd:)];
    [selectors addPointer:@selector(didCollapseAd:)];
    
    return selectors;
}

#pragma mark - ALAdDisplayDelegate

- (void)didDisplayAd:(MAAd *)ad { }
- (void)didHideAd:(MAAd *)ad { }
- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error
{
	BIDLog(self, @"Did Failed to Display ad. Error: %@",error);
}

- (void)didClickAd:(MAAd *)ad
{
	[networkBanner onClick];
}

- (void)didExpandAd:(MAAd *)ad { }

- (void)didCollapseAd:(MAAd *)ad { }

#pragma mark - revenue

-(NSNumber*)revenue
{
    if (!_cachedAd)
    {
        return nil;
    }
    
    return @(_cachedAd.revenue);
}


@end
