//
//  BIDLiftoffBanner.m
//  bidapp
//
//  Created by Vasiliy Masnev on 28.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDLiftoffBanner.h"
#import "BIDNetworkBanner.h"

#import <VungleAdsSDK/VungleAdsSDK.h>

#import "BIDAdFormat.h"
#import "BIDNetworkSettings.h"
#import "NSError+Categories.h"

//If you display banner during caching - the app will crash
//#define DISPLAY_DURING_CACHING

@interface BIDLiftoffBanner ()<VungleBannerDelegate>
{
	NSString* formatName;
	NSString* _ownerId;
	
	id<BIDNetworkBanner> __weak networkBanner;
	
	UIView* adView;
#ifdef DISPLAY_DURING_CACHING
    BOOL adIsDisplayed;
#endif
}

@property (nonatomic,strong) VungleBanner *ad;
@property (nonatomic,strong) VungleBanner *cachedAd;

@end

@implementation BIDLiftoffBanner

+ (NSString *)logPrefix { return @"LiftoffBanner"; }
- (NSString *)logPrefix { return [NSString stringWithFormat:@"%@:%@ LiftoffBanner",formatName,_ownerId]; }

+ (instancetype)bannerWithNetworkBanner:(id<BIDNetworkBanner>)ntBanner
									 SDK:(id)sdk
								   adTag:(NSString*)adTag
								  format:(id<BIDAdFormat>)format
								 ownerId:(NSString * __nullable)ownerId
{
	BannerSize lfsize;
	if (format.isBanner_320x50)
	{
		lfsize = BannerSizeRegular;
	}
	else if (format.isBanner_300x250)
	{
		lfsize = BannerSizeMrec;
	}
	else
	{
		BIDLog(self, @"ERROR - Unsuported liftoff banner format: %@", format);
		return nil;
	}

	VungleBanner *ad =[[VungleBanner alloc] initWithPlacementId:adTag
														   size:lfsize];
	if (nil == ad)
	{
		return nil;
	}
	
	BIDLiftoffBanner *banner = [[BIDLiftoffBanner alloc] init];
	if (banner)
	{
		banner->networkBanner = ntBanner;
		banner->formatName = format.name;
		banner->_ownerId = ownerId;
		
		banner.ad = ad;
		banner.ad.delegate = banner;
		
		UIView* adView = [UIView new];
		banner->adView = adView;
#ifdef DEBUG
		adView.backgroundColor = [UIColor redColor];
#endif
		adView.frame = format.bounds;
		adView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
								   UIViewAutoresizingFlexibleBottomMargin |
								   UIViewAutoresizingFlexibleLeftMargin |
								   UIViewAutoresizingFlexibleRightMargin);
	}
	
	return banner;
}

-(UIView*)nativeAdView
{
	return adView;
}

#pragma mark - BIDCacheable

- (BOOL)isAdReady
{
#ifdef DISPLAY_DURING_CACHING
    return adIsDisplayed;
#else
	return nil != self.cachedAd;
#endif
}

- (void)load
{
	[self.ad load:nil];
}

-(void)prepareForDealloc
{
    _ad = nil;
    _cachedAd = nil;
}

#pragma mark - VungleBannerDelegate - load

#ifdef DISPLAY_DURING_CACHING

- (void)bannerAdDidLoad:(VungleBanner * _Nonnull)banner
{
	BIDLog(self, @"bannerAdDidLoad:");
	
	self.cachedAd = banner;
	[banner presentOn:(id)adapter];
}

- (void)bannerAdDidFailToLoad:(VungleBanner * _Nonnull)banner withError:(NSError * _Nonnull)error
{
    BIDLog(self, @"bannerAdDidFailToLoad: ERROR: %@", error);
    
	[adapter onFailedToLoad:error];
}

#pragma mark - VungleBannerDelegate - show

- (void)bannerAdDidPresent:(VungleBanner * _Nonnull)banner
{
	BIDLog(self, @"bannerAdDidPresent:");
	
    adIsDisplayed = YES;
	[adapter onLoad];
}

- (void)bannerAdDidFailToPresent:(VungleBanner * _Nonnull)banner withError:(NSError * _Nonnull)error
{
	BIDLog(self, @"bannerAdDidFailToPresent: withError: %@",error.localizedDescription);
	
	[adapter onFailedToLoad:error];
}

#else

-(BOOL)waitForAdToShow
{
    return YES;
}

-(BOOL)showOnView:(UIView*)view error:(NSError *__autoreleasing  _Nullable *)error
{
    if (!self.isAdReady)
    {
        *error = [NSError error_notReady];
        return NO;
    }
    
    if (!view.window)
    {
        *error = [NSError error_notOnWindow];
        return NO;
    }
	
	adView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
	[view insertSubview:adView atIndex:0];
    
    [self.cachedAd presentOn:adView];
    
    return YES;
}

- (void)bannerAdDidLoad:(VungleBanner * _Nonnull)banner
{
    BIDLog(self, @"bannerAdDidLoad:");
    
    self.cachedAd = banner;
    [networkBanner onLoad];
}

- (void)bannerAdDidFailToLoad:(VungleBanner * _Nonnull)banner withError:(NSError * _Nonnull)error
{
    BIDLog(self, @"bannerAdDidFailToLoad: ERROR: %@", error);
    
    [networkBanner onFailedToLoad:error];
}

#pragma mark - VungleBannerDelegate - show

- (void)bannerAdDidPresent:(VungleBanner * _Nonnull)banner
{
    BIDLog(self, @"bannerAdDidPresent:");
    
    [networkBanner onDisplay];
}

- (void)bannerAdDidFailToPresent:(VungleBanner * _Nonnull)banner withError:(NSError * _Nonnull)error
{
    BIDLog(self, @"bannerAdDidFailToPresent: withError: %@",error.localizedDescription);
    
    [networkBanner onFailedToDisplay:error];
}

#endif

- (void)bannerAdDidClick:(VungleBanner * _Nonnull)banner
{
	[networkBanner onClick];
}

@end
