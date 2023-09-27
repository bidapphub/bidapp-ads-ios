//
//  BIDAdmobBanner.m
//  bidapp
//
//  Created by Vasiliy Masnev on 28.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDAdmobBanner.h"
#import "BIDAdmobSDK.h"
#import "BIDNetworkBanner.h"
#import "BIDAdInfo_private.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSettings.h"
#import "NSError+Categories.h"

#import <GoogleMobileAds/GoogleMobileAds.h>

@interface BIDAdmobBanner ()<GADBannerViewDelegate>
{
	NSString* formatName;
	NSString* _ownerId;
	
	id<BIDNetworkBanner> __weak networkBanner;
	
    GADBannerView *adView;
	BOOL ready;
}

@end

@implementation BIDAdmobBanner

+ (NSString *)logPrefix { return @"AdmobBanner"; }
- (NSString *)logPrefix { return [NSString stringWithFormat:@"%@:%@ AdmobBanner",formatName,_ownerId]; }

+ (instancetype)bannerWithNetworkBanner:(id<BIDNetworkBanner>)ntBanner
									 SDK:(id)sdk
								   adTag:(NSString*)adTag
								  format:(id<BIDAdFormat>)format
								 ownerId:(NSString * __nullable)ownerId
{
    if (!format.isBanner_320x50 &&
        !format.isBanner_300x250)
    {
        BIDLog(self, @"ERROR - Unsuported banner format: %@", format);
        return nil;
    }
    
    GADBannerView *adView = [(GADBannerView*)[GADBannerView alloc] initWithAdSize:format.isBanner_320x50 ? GADAdSizeBanner : GADAdSizeMediumRectangle];
    if (nil==adView) {
        return nil;
    }

    adView.autoloadEnabled = NO;
    adView.adUnitID = adTag;
    adView.rootViewController = self.vcToShowAds;
	
	BIDAdmobBanner *banner = [[BIDAdmobBanner alloc] init];
	if (banner)
	{
		banner->networkBanner = ntBanner;
		banner->formatName = format.name;
		banner->_ownerId = ownerId;
		
		banner->adView = adView;
#ifdef DEBUG
		adView.backgroundColor = [UIColor redColor];
#endif
        adView.delegate = banner;
		adView.frame = format.bounds;
		adView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
								   UIViewAutoresizingFlexibleBottomMargin |
								   UIViewAutoresizingFlexibleLeftMargin |
								   UIViewAutoresizingFlexibleRightMargin);
	}
	
	return banner;
}

+(UIViewController*)vcToShowAds
{
    UIWindow* theWindow = [UIApplication sharedApplication].keyWindow;
    if (!theWindow)
    {
        for (UIWindow* w in [UIApplication sharedApplication].windows)
        {
            if (!w.hidden)
            {
                theWindow = w;
                break;
            }
        }
    }
    
    if (!theWindow)
    {
        return [UIViewController new];//Failsafe
    }
    
    UIViewController *topController = [theWindow rootViewController];
    while(topController.presentedViewController)
    {
        if (topController.presentedViewController.isBeingDismissed)
        {
            break;
        }

        topController = topController.presentedViewController;
    }
    
    return topController ? topController : [UIViewController new];//Failsafe
}

-(UIView*)nativeAdView
{
	return adView;
}

-(void)prepareForDealloc
{
    adView = nil;
}

#pragma mark - BIDCacheable

- (BOOL)isAdReady
{
	return ready;
}

- (void)load
{
    GADRequest* request = [GADRequest request];
    
    if (nil != BIDAdmobSDK.GDPR ||
        nil != BIDAdmobSDK.CCPA)
    {
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = @{ @"npa": @( !(BIDAdmobSDK.GDPR.boolValue || BIDAdmobSDK.GDPR.boolValue) ) };
        [request registerAdNetworkExtras:extras];
    }
    
    [adView loadRequest:request];
}

#pragma mark - show

-(BOOL)showOnView:(UIView*)view error:(NSError *__autoreleasing  _Nullable *)error
{
    adView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    [view insertSubview:adView atIndex:0];
    
    return YES;
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(nonnull GADBannerView *)bannerView
{
    BIDLog(self, @"bannerViewDidReceiveAd: %@", bannerView);
    
    ready = YES;
    
    [networkBanner onLoad];
}

- (void)bannerView:(nonnull GADBannerView *)bannerView
    didFailToReceiveAdWithError:(nonnull NSError *)error
{
    BIDLog(self, @"bannerView: %@ didFailToReceiveAdWithError: %@", bannerView, error);
    
    [networkBanner onFailedToLoad:error];
}

- (void)bannerViewDidRecordClick:(nonnull GADBannerView *)bannerView
{
    [networkBanner onClick];
}

@end
