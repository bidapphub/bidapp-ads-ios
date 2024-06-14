//
//  BIDChartboostBanner.m
//  bidapp
//
//  Created by Vasiliy Masnev on 28.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDChartboostBanner.h"
#import "BIDNetworkBanner.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSettings.h"

#import <ChartboostSDK/ChartboostSDK.h>

@interface BIDChartboostBanner () <CHBBannerDelegate>
{
	NSString* formatName;
	NSString* _ownerId;
	
	id<BIDNetworkBanner> __weak networkBanner;
	
    CHBBanner *adView;
}

@end

@implementation BIDChartboostBanner

+ (NSString *)logPrefix { return @"ChartboostBanner"; }
- (NSString *)logPrefix { return [NSString stringWithFormat:@"%@:%@ ChartboostBanner",formatName,_ownerId]; }

+ (instancetype)bannerWithNetworkBanner:(id<BIDNetworkBanner>)ntBanner
									 SDK:(id)sdk
								   adTag:(NSString*)adTag
								  format:(id<BIDAdFormat>)format
								 ownerId:(NSString * __nullable)ownerId
{
#if DEBUG
    assert(sizeof(CGSize) == sizeof(CHBBannerSize));
#endif
    CGSize chbSize;
    if (format.isBanner_320x50)
    {
        chbSize = CHBBannerSizeStandard;
    }
    else if (format.isBanner_300x250)
    {
        chbSize = CHBBannerSizeMedium;
    }
    else if (format.isBanner_728x90)
    {
        chbSize = CHBBannerSizeLeaderboard;
    }
    else
    {
        BIDLog(self, @"ERROR - Unsuported applovin banner format: %@", format);
        return nil;
    }

	BIDChartboostBanner *banner = [[BIDChartboostBanner alloc] init];
	if (banner)
	{
        CHBBanner* adView = [[CHBBanner alloc]initWithSize:chbSize
                                                  location:adTag
                                                  delegate:banner];
        if (!adView)
        {
            BIDLog(self, @"ERROR - Failed to create native banner: %@", format);
            return nil;
        }
        
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
}

#pragma mark - BIDCacheable

- (BOOL)isAdReady
{
    return adView.isCached;
}

- (void)loadWithBid:(id<BidappBid>)bid
{
    [adView cache];
}

- (void)didCacheAd:(CHBCacheEvent *)event error:(nullable CHBCacheError *)error
{
    BIDLog(self, @"didCacheAd: %@ error: %@", event.ad.location, error);
    
    if (!error)
    {
        [networkBanner onLoad];
    }
    else
    {
        [networkBanner onFailedToLoad:error];
    }
}

#pragma mark - show

-(UIViewController*)vcToShowAds
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

-(BOOL)waitForAdToShow
{
    return YES;
}

-(BOOL)showOnView:(UIView*)view error:(NSError *__autoreleasing  _Nullable *)error
{
    if (!self.isAdReady)
    {
        *error = [NSError errorWithDomain:@"io.bidapp"
                                     code:9376343
                             userInfo:@{NSLocalizedDescriptionKey:@"ERROR Ad not ready"}];
        return NO;
    }
    
    adView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    [view insertSubview:adView atIndex:0];
    
    [adView showFromViewController:[self vcToShowAds]];
    
    return YES;
}

+(NSPointerArray*)delegateMethodsToValidate
{
    NSPointerArray *selectors = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsOpaqueMemory];
    
    [selectors addPointer:@selector(didCacheAd:error:)];
    [selectors addPointer:@selector(didShowAd:error:)];
    [selectors addPointer:@selector(didClickAd:error:)];
    
    return selectors;
}

#pragma mark - CHBAdDelegate

- (void)didShowAd:(CHBShowEvent *)event error:(nullable CHBShowError *)error;
{
    BIDLog(self, @"didShowAd: %@ error: %@", event.ad.location, error);
    
    if (!error)
    {
        [networkBanner onDisplay];
    }
    else
    {
        [networkBanner onFailedToDisplay:error];
    }
}

- (void)didClickAd:(CHBClickEvent *)event error:(nullable CHBClickError *)error
{
    [networkBanner onClick];
}

@end
