//
//  BIDFyberFullscreen.m
//  bidapp
//
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDFyberFullscreen.h"

#import "BIDNetworkSettings.h"
#import "BIDTestBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"
#import "TestFullscreen.h"
#import <IASDKCore/IASDKCore.h>

@interface BIDFyberFullscreen()<IAUnitDelegate>

@property (nonatomic,weak,readonly) id<BIDNetworkFullscreen> networkFullscreen;
@property (nonatomic,readonly) NSString* placementId;
@property (nonatomic,readonly) BOOL rewarded;

@property (nonatomic,readonly) IAVideoContentController *videoContentController;
@property (nonatomic,readonly) IAMRAIDContentController *mraidContentController;
@property (nonatomic,readonly) IAFullscreenUnitController *fullscreenUnitController;
@property (nonatomic,readonly) IAAdSpot *adSpot;

@property (nonatomic) IAAdModel *loadedAd;

@end

@implementation BIDFyberFullscreen

+ (NSString *)logPrefix { return @"FyberFull"; }
- (NSString *)logPrefix { return [NSString stringWithFormat:@"%@ FyberFull",_rewarded ? @"rewarded" : @"interstitial"]; }

-(id)initWithNetworkFullscreen:(id<BIDNetworkFullscreen>)ntFull SDK:(id)networkSDK adTag:(NSString *)tag isRewarded:(BOOL)isRewarded
{
	if (self = [super init])
	{
		_networkFullscreen = ntFull;
		
        _rewarded = isRewarded;
        _placementId = tag;
        
        __weak typeof(self) weakSelf = self;
        _videoContentController = [IAVideoContentController build:
         ^(id  _Nonnull builder) {
            //builder.videoContentDelegate = self;
            // A delegate should be passed in order to get video content related callbacks;
        }];

        _mraidContentController =
        [IAMRAIDContentController build:
         ^(id  _Nonnull builder) {
            //builder.MRAIDContentDelegate = self; // a delegate should be passed in order to get video content related callbacks;
        }];
        
        _fullscreenUnitController = [IAFullscreenUnitController build:^(id<IAFullscreenUnitControllerBuilder> _Nonnull builder)
         {
            builder.unitDelegate = weakSelf;
            // all the needed content controllers should be added to the desired unit controller:
            [builder addSupportedContentController:weakSelf.videoContentController];
            [builder addSupportedContentController:weakSelf.mraidContentController];
        }];
    }
    
    return self;
}

#pragma mark - Load ad

-(void)loadWithBid:(id<BidappBid>)bid
{
	BIDLog(self, @"_load %@", _placementId);
        
    __weak typeof(self) weakSelf = self;
    IAAdRequest *adRequest =
    [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
        builder.spotID = weakSelf.placementId;
        builder.timeout = 15;
        builder.useSecureConnections = NO;
    }];
    
    _adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
        builder.adRequest = adRequest;
        [builder addSupportedUnitController:weakSelf.fullscreenUnitController];
    }];
    
    [self.adSpot fetchAdWithCompletion:^(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error) {
        if (error)
        {
            weakSelf.loadedAd = nil;
            return [weakSelf.networkFullscreen onAdFailedToLoadWithError:error];
        }

        [weakSelf.networkFullscreen onAdLoaded];
        weakSelf.loadedAd = adModel;
    }];
}

#pragma mark - show ad

-(BOOL)readyToShow
{
    return nil != _fullscreenUnitController && nil != _loadedAd;
}

-(BOOL)showWithViewController:(UIViewController *)vc error:(NSError *__autoreleasing  _Nullable *)error
{
    BIDLog(self,@"_showWithViewController: %@ placementId: %@", vc, _placementId);

    [_fullscreenUnitController showAdAnimated:YES completion:nil];
    
    return YES;
}

+(NSPointerArray*)delegateMethodsToValidate
{
    NSPointerArray *selectors = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsOpaqueMemory];
    
    [selectors addPointer:@selector(IAParentViewControllerForUnitController:)];
    [selectors addPointer:@selector(IAUnitControllerWillPresentFullscreen:)];
    [selectors addPointer:@selector(IAUnitControllerDidDismissFullscreen:)];
    [selectors addPointer:@selector(IAAdDidExpire:)];
    [selectors addPointer:@selector(IAAdDidReceiveClick:)];
    [selectors addPointer:@selector(IAAdDidReward:)];
    
    return selectors;
}

#pragma mark - IAUnitDelegate

- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(IAUnitController * _Nullable)unitController
{
    if (![_networkFullscreen respondsToSelector:@selector(delegate)])
    {
        //impossible
        return nil;
    }
    
    id delegate = [(id)_networkFullscreen delegate];
    if (![delegate respondsToSelector:@selector(delegate)])
    {
        //impossible
        return nil;
    }

    return [delegate viewControllerForDisplayAd];
}

- (void)IAUnitControllerWillPresentFullscreen:(IAUnitController * _Nullable)unitController
{
    [_networkFullscreen onDisplay];
}

- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController * _Nullable)unitController
{
    [_networkFullscreen onHide];
    _loadedAd = nil;
}

- (void)IAAdDidExpire:(IAUnitController * _Nullable)unitController
{
    _loadedAd = nil;
}

- (void)IAAdDidReceiveClick:(IAUnitController * _Nullable)unitController
{
    [_networkFullscreen onClick];
}

- (void)IAAdDidReward:(IAUnitController * _Nullable)unitController
{
    [_networkFullscreen onReward];
}

@end
