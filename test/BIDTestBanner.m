//
//  BIDTestBanner.m
//  bidapp
//
//  Created by Vasiliy Masnev on 28.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDTestBanner.h"
#import "BIDNetworkBanner.h"
#import "TestBannerView.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSettings.h"
#import "NSError+Categories.h"

@interface BIDTestBanner () <TestBannerViewDelegate>
{
	NSString* formatName;
	NSString* _ownerId;
	
	id<BIDNetworkBanner> __weak networkBanner;
	
    TestBannerView *adView;
	BOOL ready;
}

@end

@implementation BIDTestBanner

+ (NSString *)logPrefix { return @"TestBanner"; }
- (NSString *)logPrefix { return [NSString stringWithFormat:@"%@:%@ TestBanner",formatName,_ownerId]; }

+ (instancetype)bannerWithNetworkBanner:(id<BIDNetworkBanner>)ntBanner
									 SDK:(id)sdk
								   adTag:(NSString*)adTag
								  format:(id<BIDAdFormat>)format
								 ownerId:(NSString * __nullable)ownerId
{
    TestBannerView *adView = [[TestBannerView alloc] init];
	if (nil==adView) {
		return nil;
	}
	
	BIDTestBanner *banner = [[BIDTestBanner alloc] init];
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
	return ready;
}

- (void)load
{
    [adView showAdWithDelegate:self];
}

#pragma mark - show

-(BOOL)showOnView:(UIView*)view error:(NSError *__autoreleasing  _Nullable *)error
{
	adView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
	[view insertSubview:adView atIndex:0];
	
	return YES;
}

#pragma mark - UADSBannerViewDelegate

-(void)bannerDidShowAd:(TestBannerView*)banner
{
    ready = YES;
    
    [networkBanner onLoad];
}

-(void)bannerDidFailedToShowAd:(TestBannerView*)banner error:(NSError*)error
{
    [networkBanner onFailedToLoad:error];
}

-(void)bannerDidClick:(TestBannerView*)banner
{
    [networkBanner onClick];
}

@end
