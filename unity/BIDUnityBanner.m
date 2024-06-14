//
//  BIDUnityBanner.m
//  bidapp
//
//  Created by Vasiliy Masnev on 28.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDUnityBanner.h"
#import "BIDNetworkBanner.h"

#import <UnityAds/UnityAds.h>

#import "BIDAdFormat.h"
#import "BIDNetworkSettings.h"

@interface BIDUnityBanner () <UADSBannerViewDelegate>
{
	NSString* formatName;
	NSString* _ownerId;
	
	id<BIDNetworkBanner> __weak networkBanner;
	
	UADSBannerView *adView;
	BOOL ready;
}

@end

@implementation BIDUnityBanner

+ (NSString *)logPrefix { return @"UnityBanner"; }
- (NSString *)logPrefix { return [NSString stringWithFormat:@"%@:%@ UnityBanner",formatName,_ownerId]; }

+ (instancetype)bannerWithNetworkBanner:(id<BIDNetworkBanner>)ntBanner
									 SDK:(id)sdk
								   adTag:(NSString*)adTag
								  format:(id<BIDAdFormat>)format
								 ownerId:(NSString * __nullable)ownerId
{
	if (!format.isBanner_320x50)
	{
		BIDLog(self, @"ERROR - Unsuported Unity banner format: %@", format);
		return nil;
	}
	
	UADSBannerView *adView = [[UADSBannerView alloc] initWithPlacementId:adTag size:format.size];
	if (nil==adView) {
		return nil;
	}
	
	BIDUnityBanner *banner = [[BIDUnityBanner alloc] init];
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

+(NSPointerArray*)delegateMethodsToValidate
{
    NSPointerArray *selectors = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsOpaqueMemory];
    
    [selectors addPointer:@selector(bannerViewDidLoad:)];
    [selectors addPointer:@selector(bannerViewDidShow:)];
    [selectors addPointer:@selector(bannerViewDidError:error:)];
    [selectors addPointer:@selector(bannerViewDidClick:)];
    [selectors addPointer:@selector(bannerViewDidLeaveApplication:)];
    
    return selectors;
}

#pragma mark - BIDCacheable

- (BOOL)isAdReady
{
	return ready;
}

- (void)loadWithBid:(id<BidappBid>)bid
{
	[adView load];
}

#pragma mark - show

-(BOOL)showOnView:(UIView*)view error:(NSError *__autoreleasing  _Nullable *)error
{
	adView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
	[view insertSubview:adView atIndex:0];
	
	return YES;
}

#pragma mark - UADSBannerViewDelegate

- (void)bannerViewDidLoad:(UADSBannerView *)bannerView
{
	ready = YES;
	
	[networkBanner onLoad];
}

- (void)bannerViewDidShow: (UADSBannerView *)bannerView
{
}

- (void)bannerViewDidError:(UADSBannerView *)bannerView error:(UADSBannerError *)error
{
	[networkBanner onFailedToLoad:error];
}

- (void)bannerViewDidClick:(UADSBannerView *)bannerView
{
	[networkBanner onClick];
}

- (void)bannerViewDidLeaveApplication: (UADSBannerView *)bannerView { }

@end
