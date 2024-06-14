//
//  BIDLiftoffAdapter.m
//  bidapp
//
//  Created by Vasiliy Masnev on 11.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDLiftoffSDK.h"
#import "BIDLogger.h"

#import <VungleAdsSDK/VungleAdsSDK.h>
#import "BIDLiftoffInterstitial.h"
#import "BIDLiftoffRewarded.h"
#import "BIDNetworkSettings.h"
#import "BIDLiftoffBanner.h"
#import "BIDAdFormat.h"

@implementation BIDLiftoffSDK
{
	id<BIDNetworkSDK> __weak networkSDK;
	NSString* sdkKey;
	
	BOOL testMode;
}

-(id)initWithNetworkSDK:(id<BIDNetworkSDK>)ntSDK SDKKey:(NSString*)sdkK secondKey:(NSString * _Nullable)secondKey
{
	if (self == [super init])
	{
		networkSDK = ntSDK;
		sdkKey = sdkK;
        
        [BIDLiftoffInterstitial setAppId:sdkK publisherId:secondKey];
	}
	
	return self;
}

+ (BOOL)sdkAvailableWithCompatibleVersion:(validate_selectors_t)validate
{
    BOOL interstitialDelegatesAreValid = validate(BIDLiftoffInterstitial.class, BIDLiftoffInterstitial.delegateMethodsToValidate);
    BOOL rewardedDelegatesAreValid = validate(BIDLiftoffRewarded.class, BIDLiftoffRewarded.delegateMethodsToValidate);
    BOOL bannerDelegatesAreValid = validate(BIDLiftoffBanner.class, BIDLiftoffBanner.delegateMethodsToValidate);
    
    return interstitialDelegatesAreValid && rewardedDelegatesAreValid && bannerDelegatesAreValid;
}

- (void)initializeSDK
{
	if (!self.isInitialized &&
		!networkSDK.initializationInProgress)
	{
		[networkSDK onInitializationStart];
		
		__weak typeof(self) weakSelf = self;
		[VungleAds initWithAppId:sdkKey completion:^(NSError * _Nullable error) {

            //Redirecting from a background to the main thread
			dispatch_async(dispatch_get_main_queue(), ^(){
				
				if (error)
				{
					BIDLog(self,@"SDK NOT initialized. Error: %@",error);
				}
                
				BIDLiftoffSDK* strongSelf = weakSelf;
				if (strongSelf)
				{
					[strongSelf->networkSDK onInitializationComplete:nil == error
															error:error];
				}
			});
		}];
	}
};

+(NSString*)getBiddingToken
{
    return VungleAds.getBiddingToken;
}

- (BOOL)isInitialized
{
	return VungleAds.isInitialized;
}

- (void)enableTesting
{
	testMode = YES;
}

- (void)enableLogging
{
	//TODO: add logging
	//[self.liftSdk setLoggingEnabled:YES];
}

- (void)setConsent:(id<BIDConsent>)consent
{
	if (consent.GDPR)
	{
		VunglePrivacySettings.GDPRStatus = consent.GDPR.boolValue;
	}
	
	if (consent.CCPA)
	{
		VunglePrivacySettings.CCPAStatus = consent.CCPA.boolValue;
	}
	
	if (consent.COPPA)
	{
		VunglePrivacySettings.COPPAStatus = consent.COPPA.boolValue;
	}
}

@end
