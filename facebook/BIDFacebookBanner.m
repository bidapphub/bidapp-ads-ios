//
//  BIDFacebookBanner.m
//  bidapp
//
//  Created by Vasiliy Masnev on 28.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDFacebookBanner.h"
#import "BIDNetworkBanner.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSettings.h"
#import "BIDFacebookSDK.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface BIDFacebookBanner ()<FBAdViewDelegate>
{
	NSString* formatName;
	NSString* ownerId;
    BOOL loaded;
    NSString* adTag;
    FBAdView* adView;
    id<BIDNetworkBanner> __weak networkBanner;
}

@end

@implementation BIDFacebookBanner

+ (NSString *)logPrefix { return @"FacebookBanner"; }
- (NSString *)logPrefix { return [NSString stringWithFormat:@"%@:%@ FacebookBanner",formatName,ownerId]; }

+ (instancetype)bannerWithNetworkBanner:(id<BIDNetworkBanner>)ntBanner
									 SDK:(id)sdk
								   adTag:(NSString*)adTag
								  format:(id<BIDAdFormat>)format
								 ownerId:(NSString * __nullable)ownerId_
{
    FBAdSize size;
    if (format.isBanner_320x50)
    {
        size = kFBAdSize320x50;
    }
    else if (format.isBanner_300x250)
    {
        size = kFBAdSizeHeight250Rectangle;
    }
    else if (format.isBanner_728x90)
    {
        size = kFBAdSizeHeight90Banner;
    }
    else
    {
        return nil;
    }

	BIDFacebookBanner *banner = [[BIDFacebookBanner alloc] init];
	if (banner)
	{
        banner->adTag = adTag;
		banner->networkBanner = ntBanner;
		banner->formatName = format.name;
		banner->ownerId = ownerId_;

        FBAdView *adView = [[FBAdView alloc] initWithPlacementID:adTag
                                                              adSize:size
                                                  rootViewController:nil];
        adView.delegate = banner;
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
    return loaded;
}

-(void)loadWithBid:(id<BidappBid>)bid
{
    BIDLog(self, @"load %@", adTag);
    
    loaded = NO;
    [adView loadAd];
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
    
    [selectors addPointer:@selector(adViewDidLoad:)];
    [selectors addPointer:@selector(adView:didFailWithError:)];
    [selectors addPointer:@selector(adViewDidClick:)];
    
    return selectors;
}

#pragma mark - FBAdViewDelegate

- (void)adViewDidLoad:(FBAdView *)adView
{
    loaded = YES;
    [networkBanner onLoad];
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error
{
    [networkBanner onFailedToLoad:error];
}

- (void)adViewDidClick:(FBAdView *)adView
{
    [networkBanner onClick];
}

@end
