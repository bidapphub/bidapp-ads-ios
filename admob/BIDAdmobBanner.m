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
#import "BIDAdFormat.h"
#import "BIDNetworkSettings.h"

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
    GADAdSize bannerSize;
    if (format.isBanner_320x50)
    {
        bannerSize = GADAdSizeBanner;
    }
    else if (format.isBanner_300x250)
    {
        bannerSize = GADAdSizeMediumRectangle;
    }
    else if (format.isBanner_728x90)
    {
        bannerSize =  GADAdSizeLeaderboard;
    }
    else
    {
        BIDLog(self, @"ERROR - Unsuported banner format: %@", format);
        return nil;
    }
    
    GADBannerView *adView = [(GADBannerView*)[GADBannerView alloc] initWithAdSize:bannerSize];
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

- (void)loadWithBid:(id<BidappBid>)bid
{
    GADRequest* request = [GADRequest request];
    
    if (BIDAdmobSDK.GDPR)
    {
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = @{ @"npa": @( !BIDAdmobSDK.GDPR.boolValue ) };
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

+(NSPointerArray*)delegateMethodsToValidate
{
    NSPointerArray *selectors = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsOpaqueMemory];
    
    [selectors addPointer:@selector(bannerViewDidReceiveAd:)];
    [selectors addPointer:@selector(bannerView:didFailToReceiveAdWithError:)];
    [selectors addPointer:@selector(bannerViewDidRecordClick:)];
    
    return selectors;
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
