//
//  BIDFyberBanner.m
//  bidapp
//
//  Created by Vasiliy Masnev on 28.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDFyberBanner.h"
#import "BIDNetworkBanner.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSettings.h"
#import <IASDKCore/IASDKCore.h>

@interface BIDFyberBanner ()<IAUnitDelegate>
{
	NSString* formatName;
	NSString* _ownerId;
}

@property (nonatomic) NSString *adTag;
@property (nonatomic,readonly) UIView *adView;
@property (nonatomic,weak,readonly) id<BIDNetworkBanner> networkBanner;
@property (nonatomic,readonly) IAVideoContentController *videoContentController;
@property (nonatomic,readonly) IAMRAIDContentController *mraidContentController;
@property (nonatomic,readonly) IAViewUnitController *unitController;
@property (nonatomic,readonly) IAAdSpot *adSpot;

@property (nonatomic) IAAdModel *loadedAd;

@end

@implementation BIDFyberBanner

+ (NSString *)logPrefix { return @"FyberBanner"; }
- (NSString *)logPrefix { return [NSString stringWithFormat:@"%@:%@ FyberBanner",formatName,_ownerId]; }

+ (instancetype)bannerWithNetworkBanner:(id<BIDNetworkBanner>)ntBanner
									 SDK:(id)sdk
								   adTag:(NSString*)adTag
								  format:(id<BIDAdFormat>)format
								 ownerId:(NSString * __nullable)ownerId
{
    if (@available(iOS 15.0, *)) {
    }
    else
    {
        return nil;
    }
    
	BIDFyberBanner *banner = [[BIDFyberBanner alloc] init];
	if (banner)
	{
        banner->_adTag = adTag;
		banner->_networkBanner = ntBanner;
		banner->formatName = format.name;
		banner->_ownerId = ownerId;
        
        BIDFyberBanner* __weak weakBanner = banner;
        banner->_videoContentController = [IAVideoContentController build:
         ^(id  _Nonnull builder) {
        }];

        banner->_mraidContentController =
        [IAMRAIDContentController build:
         ^(id  _Nonnull builder) {
        }];
        
        banner->_unitController = [IAViewUnitController build:^(id<IAViewUnitControllerBuilder> _Nonnull builder)
         {
            builder.unitDelegate = weakBanner;
            [builder addSupportedContentController:weakBanner.videoContentController];
            [builder addSupportedContentController:weakBanner.mraidContentController];
        }];
		
        UIView* adView = [UIView new];
        banner->_adView = adView;
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
	return _adView;
}

-(void)prepareForDealloc
{
    _adView = nil;
}

#pragma mark - BIDCacheable

- (BOOL)isAdReady
{
    return nil != _unitController && nil != _loadedAd;
}

-(void)loadWithBid:(id<BidappBid>)bid
{
    BIDLog(self, @"_load %@", _adTag);
        
    __weak typeof(self) weakSelf = self;
    IAAdRequest *adRequest =
    [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
        builder.spotID = weakSelf.adTag;
        builder.timeout = 15;
        builder.useSecureConnections = NO;
    }];
    
    _adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
        builder.adRequest = adRequest;
        [builder addSupportedUnitController:weakSelf.unitController];
    }];
    
    [self.adSpot fetchAdWithCompletion:^(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error) {
        if (error)
        {
            weakSelf.loadedAd = nil;
            return [weakSelf.networkBanner onFailedToLoad:error];
        }

        weakSelf.loadedAd = adModel;
        [weakSelf.unitController showAdInParentView:weakSelf.adView];
        [weakSelf.networkBanner onLoad];
    }];
}

#pragma mark - show

-(BOOL)showOnView:(UIView*)view error:(NSError *__autoreleasing  _Nullable *)error
{
	_adView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
	[view insertSubview:_adView atIndex:0];
	
	return YES;
}

+(NSPointerArray*)delegateMethodsToValidate
{
    NSPointerArray *selectors = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsOpaqueMemory];
    
    [selectors addPointer:@selector(IAParentViewControllerForUnitController:)];
    [selectors addPointer:@selector(IAAdDidReceiveClick:)];

    return selectors;
}

#pragma mark - UADSBannerViewDelegate

static UIWindowScene* currentScene(void)
{
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* s in UIApplication.sharedApplication.connectedScenes)
        {
            if (s.activationState == UISceneActivationStateForegroundActive &&
                [s isKindOfClass:UIWindowScene.class])
            {
                return s;
            }
        }
    }
    
    return nil;
}

- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(IAUnitController * _Nullable)unitController
{
    return currentScene().keyWindow.rootViewController;
}

- (void)IAAdDidReceiveClick:(IAUnitController * _Nullable)unitController
{
    [_networkBanner onClick];
}

@end
