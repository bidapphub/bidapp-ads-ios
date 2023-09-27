//
//  BIDUnityFullscreen.m
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 19/4/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDUnityFullscreen.h"

#import "BIDNetworkSettings.h"
#import "BIDUnityBanner.h"
#import "BIDNetworkFullscreen.h"
#import "BIDAdFormat.h"
#import "BIDNetworkSDK.h"
#import "NSError+Categories.h"
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

#import <UnityAds/UnityAds.h>

#define UNITY_FULLSCREEN_AD_OPEN_NOTIFICATION @"UNITY_FULLSCREEN_AD_OPEN_NOTIFICATION"
#define UNITY_FULLSCREEN_AD_CLOSE_NOTIFICATION @"UNITY_FULLSCREEN_AD_CLOSE_NOTIFICATION"

@interface USRVWebViewApp : NSObject

- (void)userContentController: (id)userContentController didReceiveScriptMessage: (id)message;

@end

@implementation USRVWebViewApp(Tracking)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Class class = [self class];
		
		{
			SEL originalSelector = @selector(userContentController:didReceiveScriptMessage:);
			SEL swizzledSelector = @selector(xxx_userContentController:didReceiveScriptMessage:);
			
			Method originalMethod = class_getInstanceMethod(class, originalSelector);
			Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
			
			IMP originalImp = method_getImplementation(originalMethod);
			IMP swizzledImp = method_getImplementation(swizzledMethod);
			
			class_replaceMethod(class,
								swizzledSelector,
								originalImp,
								method_getTypeEncoding(originalMethod));
			class_replaceMethod(class,
								originalSelector,
								swizzledImp,
								method_getTypeEncoding(swizzledMethod));
		}
	});
}

#pragma mark - Method Swizzling

- (void)xxx_userContentController: (id)userContentController didReceiveScriptMessage: (WKScriptMessage*)message;
{
	if ([message respondsToSelector:@selector(name)] &&
		[message respondsToSelector:@selector(body)])
	{
		NSArray* eventsArray = nil;
		if ([message.body isKindOfClass:[NSString class]])
		{
			eventsArray = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
		}
		
		if ([eventsArray isKindOfClass:[NSDictionary class]])
		{
			eventsArray = @[eventsArray];
		}
		
		if ([eventsArray isKindOfClass:[NSArray class]])
		{
			for (NSArray* event in eventsArray)
			{
				if ([event isKindOfClass:[NSArray class]] &&
					event.count >= 2 &&
					[event[0] isKindOfClass:[NSString class]] &&
					[event[0] isEqualToString:@"UADSApiAdUnit"] &&
					[event[1] isKindOfClass:[NSString class]])
				{
					if ([event[1] isEqualToString:@"open"])
					{
						[NSNotificationCenter.defaultCenter postNotificationName:UNITY_FULLSCREEN_AD_OPEN_NOTIFICATION object:nil];
					}
					else if ([event[1] isEqualToString:@"close"])
					{
						[NSNotificationCenter.defaultCenter postNotificationName:UNITY_FULLSCREEN_AD_CLOSE_NOTIFICATION object:nil];
					}
				}
			}
		}
	}
	
	return [self xxx_userContentController:userContentController didReceiveScriptMessage:message];
}

@end

@interface BIDUnityFullscreen()<UnityAdsLoadDelegate, UnityAdsShowDelegate>
{
	id<BIDNetworkFullscreen> __weak networkFullscreen;
	
	BOOL unityAdControllerOpened;
	BOOL unityAdControllerClosed;
	BOOL useCloseEventWorkaround;
	
	BOOL showInProgress;
}

@property (nonatomic,readonly) NSString* placementId;
@property (nonatomic,readonly) BOOL rewarded;
@property (nonatomic,strong) NSString *loadedPlacementId;

@end

@implementation BIDUnityFullscreen

+ (NSString *)logPrefix { return @"UnityFull"; }
- (NSString *)logPrefix { return [NSString stringWithFormat:@"%@ UnityFull",_rewarded ? @"rewarded" : @"interstitial"]; }

-(id)initWithNetworkFullscreen:(id<BIDNetworkFullscreen>)ntFull SDK:(id)networkSDK adTag:(NSString *)tag isRewarded:(BOOL)isRewarded
{
	if (self = [super init])
	{
		networkFullscreen = ntFull;
		
        _rewarded = isRewarded;
        _placementId = tag;
		
		[NSNotificationCenter.defaultCenter addObserver:self
											   selector:@selector(willOpenPlayerController)
												   name:UNITY_FULLSCREEN_AD_OPEN_NOTIFICATION
												 object:nil];
		
		[NSNotificationCenter.defaultCenter addObserver:self
											   selector:@selector(willClosePlayerController)
												   name:UNITY_FULLSCREEN_AD_CLOSE_NOTIFICATION
												 object:nil];
    }
    
    return self;
}

-(void)dealloc
{
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

-(BOOL)readyToShow
{
    return nil != _loadedPlacementId;
}

#pragma mark - Load ad

-(void)load
{
	BIDLog(self, @"_load %@", _placementId);
	
	[UnityAds load:_placementId loadDelegate:self];
}

#pragma mark - UnityAdsLoadDelegate

- (void)unityAdsAdLoaded:(NSString *)placementId
{
	BIDLog(self, @"unityAdsAdLoaded: %@", placementId);
	
    _loadedPlacementId = placementId;
    
	[networkFullscreen onAdLoaded];
}
 
- (void)unityAdsAdFailedToLoad:(NSString *)placementId
                     withError:(UnityAdsLoadError)error
                   withMessage:(NSString *)message
{
	BIDLog(self, @"unityAdsAdFailedToLoad: %@ error: %ld message: %@", placementId, error, message);
	
	[networkFullscreen onAdFailedToLoadWithError:[NSError errorWithNetworkId:UNITY_ADAPTER_UID code:error description:message]];
}

#pragma mark - Display ad

-(BOOL)viewControllerNeededForDisplay
{
	return YES;
}

-(BOOL)shouldWaitForAdToDisplay
{
	return YES;
}

-(BOOL)showWithViewController:(UIViewController *)vc error:(NSError *__autoreleasing  _Nullable *)error
{
	BIDLog(self,@"_showWithViewController: %@ placementId: %@", vc, _placementId);

    //For testing at layer1Playgrouns. For other situation it is not needed because all adapters are used only once
	unityAdControllerOpened = NO;
	unityAdControllerClosed = NO;
	useCloseEventWorkaround = NO;
	
	showInProgress = YES;
    [UnityAds show:vc placementId:_placementId showDelegate:self];
    
    return YES;
}

#pragma mark - UnityAdsShowDelegate

//Intercepted event from the swizzled method
- (void)willOpenPlayerController
{
	if (showInProgress)
	{
		BIDLog(self,@"willShowPlayerController %@", _placementId);
		
		unityAdControllerOpened = YES;
	}
}

- (void)unityAdsShowStart:(NSString *)placementId
{
	BIDLog(self, @"unityAdsShowStart: %@", placementId);
	[networkFullscreen onDisplay];
}

- (void)unityAdsShowFailed:(NSString *)placementId withError:(UnityAdsShowError)error withMessage:(NSString *)message
{
	NSError* e = [NSError errorWithNetworkId:UNITY_ADAPTER_UID code:error description:message];
	useCloseEventWorkaround = unityAdControllerOpened && !unityAdControllerClosed;
	
	BIDLog(self,@"unityAdsShowFailed: %@ %ld %@ useCloseWorkaround: %d", placementId, error, message, useCloseEventWorkaround);
	
	[networkFullscreen onFailedToDisplay:e andToClose:useCloseEventWorkaround];
}

//Intercepted event from the swizzled method
- (void)willClosePlayerController
{
	if (showInProgress)
	{
		NSLog(@"willClosePlayerController %@", _placementId);

		unityAdControllerClosed = YES;
		
		if (useCloseEventWorkaround)
		{
			showInProgress = NO;
			[networkFullscreen onHide];
		}
	}
}

- (void)unityAdsShowClick:(NSString *)placementId
{
	[networkFullscreen onClick];
}

- (void)unityAdsShowComplete:(NSString *)placementId withFinishState:(UnityAdsShowCompletionState)state
{
	BIDLog(self, @"unityAdsShowComplete: %@ withFinishState: %ld", placementId, state);
	
	if (state == kUnityShowCompletionStateCompleted &&
        _rewarded)
	{
		[networkFullscreen onReward];
	}
	
	if (showInProgress)
	{
		showInProgress = NO;
		[networkFullscreen onHide];
	}
}

@end
