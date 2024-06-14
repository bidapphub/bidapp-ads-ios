//
//  BIDStartAppBanner.m
//  bidapp
//
//  Created by Vasiliy Masnev on 28.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDStartAppBanner.h"
#import "BIDNetworkBanner.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSettings.h"
#import "BIDStartAppSDK.h"
#import <StartApp/StartApp.h>

@implementation STABannerView(Frame)

-(void)setFrame:(CGRect)frame
{
    if (self.superview)
    {
        frame = CGRectMake((int)(self.superview.bounds.size.width/2)-frame.size.width/2, (int)(self.superview.bounds.size.height/2)-frame.size.height/2, frame.size.width, frame.size.height);
    }
    
    [super setFrame:frame];
}

@end

@interface BIDStartAppBanner ()<STABannerDelegateProtocol>
{
	NSString* formatName;
	NSString* ownerId;
    BOOL loaded;
    NSString* adTag;
    STABannerView* adView;
    id<BIDNetworkBanner> __weak networkBanner;
}

@end

@implementation BIDStartAppBanner

+ (NSString *)logPrefix { return @"StartAppBanner"; }
- (NSString *)logPrefix { return [NSString stringWithFormat:@"%@:%@ StartAppBanner",formatName,ownerId]; }

+ (instancetype)bannerWithNetworkBanner:(id<BIDNetworkBanner>)ntBanner
									 SDK:(id)sdk
								   adTag:(NSString*)adTag
								  format:(id<BIDAdFormat>)format
								 ownerId:(NSString * __nullable)ownerId_
{
    
    STABannerSize bannerSize;
    if (format.isBanner_320x50)
    {
        bannerSize = STA_PortraitAdSize_320x50;
    }
    else if (format.isBanner_300x250)
    {
        bannerSize = STA_MRecAdSize_300x250;
    }
    else
    {
        return nil;
    }
    
	BIDStartAppBanner *banner = [[BIDStartAppBanner alloc] init];
	if (banner)
	{
        banner->adTag = adTag;
		banner->networkBanner = ntBanner;
		banner->formatName = format.name;
		banner->ownerId = ownerId_;

        UIView* adView = [UIView new];
        
        STAAdPreferences *adPref = [STAAdPreferences preferencesWithMinCPM:0.0];
        if (adTag)
        {
            adPref.adTag = adTag;
        }
        
        banner->adView = [[STABannerView alloc] initWithSize:bannerSize
                                                   autoOrigin:STAAdOrigin_Top
                                                adPreferences:adPref
                                                 withDelegate:banner];
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

    [selectors addPointer:@selector(bannerAdIsReadyToDisplay:)];
    [selectors addPointer:@selector(failedLoadBannerAd:withError:)];
    [selectors addPointer:@selector(didClickBannerAd:)];
    
    return selectors;
}

#pragma mark - STABannerDelegateProtocol

- (void)bannerAdIsReadyToDisplay:(STABannerViewBase *)banner;
{
    BIDLog(self,@"bannerAdIsReadyToDisplay");
    
    loaded = YES;
    [networkBanner onLoad];
}

- (void)failedLoadBannerAd:(STABannerViewBase *)banner withError:(NSError *)error
{
    BIDLog(self,@"failedLoadBannerAd");
    
    [networkBanner onFailedToLoad:error];
}

- (void)didClickBannerAd:(STABannerViewBase *)banner;
{
    [networkBanner onClick];
}

@end
