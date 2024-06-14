//
//  BIDUnityAdapter.m
//  bidapp
//
//  Created by Vasiliy Masnev on 11.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDUnitySDK.h"
#import "BIDLogger.h"

#import <UnityAds/UnityAds.h>
#import "BIDUnityFullscreen.h"
#import "BIDUnityBanner.h"

#import "BIDNetworkSettings.h"
#import "BIDUnityBanner.h"
#import "BIDAdFormat.h"

@interface BIDUnitySDK ()<UnityAdsInitializationDelegate>
{
	BOOL testMode;
}

@end

@implementation BIDUnitySDK
{
	id<BIDNetworkSDK> __weak networkSDK;
	NSString* sdkKey;
}

-(id)initWithNetworkSDK:(id<BIDNetworkSDK>)ntSDK SDKKey:(NSString*)sdkK secondKey:(NSString * _Nullable)secondKey
{
	if (self == [super init])
	{
        networkSDK = ntSDK;
		sdkKey = sdkK;
	}
	
	return self;
}

- (void)initializeSDK
{
	if (!self.isInitialized &&
		!networkSDK.initializationInProgress)
	{
		[networkSDK onInitializationStart];
		[UnityAds initialize:sdkKey testMode:testMode initializationDelegate:self];
	}
};

+(NSPointerArray*)delegateMethodsToValidate
{
    NSPointerArray *selectors = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsOpaqueMemory];

    [selectors addPointer:@selector(initializationComplete)];
    [selectors addPointer:@selector(initializationFailed:withMessage:)];
    
    return selectors;
}

#pragma mark - UnityAdsInitializationDelegate protocol

- (void)initializationComplete
{
	BIDLog(self,@"SDK initialized");
	
	[networkSDK onInitializationComplete:YES error:nil];
}

- (void)initializationFailed:(UnityAdsInitializationError)error withMessage:(NSString *)message
{
	BIDLog(self,@"SDK NOT initialized. Error: %@",message);

    NSString* prefix = @"";
    switch (error) {
        case kUnityInitializationErrorInternalError:
            prefix = @"kUnityInitializationErrorInternalError. ";
            break;

        case kUnityInitializationErrorInvalidArgument:
            prefix = @"kUnityInitializationErrorInvalidArgument. ";
            break;

        case kUnityInitializationErrorAdBlockerDetected:
            prefix = @"kUnityInitializationErrorAdBlockerDetected. ";
            break;
            
        default:
            break;
    }
    
    NSError* nsError = [NSError errorWithDomain:@"io.bidapp" code:(284445+(int)error) userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"%@%@", prefix, message]}];

	[networkSDK onInitializationComplete:NO
								 error:nsError];
}

- (BOOL)isInitialized
{
	return [UnityAds isInitialized];
}

+ (BOOL)sdkAvailableWithCompatibleVersion:(validate_selectors_t)validate
{
    BOOL sdkDelegatesAreValid = validate(BIDUnitySDK.class, BIDUnitySDK.delegateMethodsToValidate);
    BOOL fullscreenDelegatesAreValid = validate(BIDUnityFullscreen.class, BIDUnityFullscreen.delegateMethodsToValidate);
    BOOL bannerDelegatesAreValid = validate(BIDUnityBanner.class, BIDUnityBanner.delegateMethodsToValidate);
    
    return sdkDelegatesAreValid && fullscreenDelegatesAreValid && bannerDelegatesAreValid;
}

- (void)enableTesting
{
	testMode = YES;
}

- (void)enableLogging
{
	[UnityAds setDebugMode:YES];
}

- (void)setConsent:(id<BIDConsent>)consent
{
	UADSMetaData *privacyConsentMetaData = [[UADSMetaData alloc] init];
	if (consent.GDPR)
	{
		[privacyConsentMetaData set:@"gdpr.consent" value:consent.GDPR];
		[privacyConsentMetaData commit];
	}
	
	if (consent.CCPA)
	{
		[privacyConsentMetaData set:@"privacy.consent" value:consent.CCPA];
		[privacyConsentMetaData commit];
	}
	
	[privacyConsentMetaData set:@"privacy.mode" value:@"mixed"];
	[privacyConsentMetaData commit];
	
	if (consent.COPPA)
	{
		[privacyConsentMetaData set:@"user.nonbehavioral" value:@(consent.COPPA.boolValue)];
		[privacyConsentMetaData commit];
	}
}

@end
