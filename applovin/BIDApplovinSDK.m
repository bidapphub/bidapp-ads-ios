//
//  BIDApplovinSDK.m
//  bidapp
//
//  Created by Vasiliy Masnev on 11.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDApplovinSDK.h"

#import <AppLovinSDK/AppLovinSDK.h>

#import "BIDApplovinInterstitial.h"
#import "BIDApplovinRewarded.h"
#import "BIDApplovinBanner.h"
#import "BIDApplovinInitializer.h"
#import "BIDNetworkSettings.h"
#import "BIDApplovinBanner.h"
#import "BIDAdFormat.h"
#import "BIDLogger.h"

@implementation BIDApplovinSDK
{
	id<BIDNetworkSDK> __weak networkSDK;
	NSString* sdkKey;
}

-(id)initWithNetworkSDK:(id<BIDNetworkSDK>)ntSDK SDKKey:(NSString*)sdkKey_ secondKey:(NSString * _Nullable)secondKey
{
	if (self == [super init])
	{
		networkSDK = ntSDK;
		sdkKey = sdkKey_;
	}
	
	return self;
}

- (id __nullable)sharedNativeSDK
{
    return self.alSDK;
}

- (ALSdk *)alSDK
{
	return [ALSdk sharedWithKey:sdkKey];
}

- (void)initializeSDK
{
	if (!self.isInitialized &&
		!networkSDK.initializationInProgress)
	{
		[networkSDK onInitializationStart];
		
		__weak typeof(self) weakSelf = self;
		[BIDApplovinSDK startSDK:self.alSDK completion:^{
			BIDApplovinSDK* strongSelf = weakSelf;
			if (strongSelf)
			{
				[strongSelf->networkSDK onInitializationComplete:weakSelf.isInitialized
														 error:weakSelf.isInitialized ? nil : [NSError errorWithDomain:@"io.bidapp"
                                                                                                                  code:503503
                                                                                                          userInfo:@{NSLocalizedDescriptionKey:@"SDK is not Initialized yet"}]];
			}
		}];
	}
};

- (BOOL)isInitialized
{
	return self.alSDK.isInitialized;
}

+ (BOOL)sdkAvailableWithCompatibleVersion:(validate_selectors_t)validate
{
    BOOL interstitialDelegatesAreValid = validate(BIDApplovinInterstitial.class, BIDApplovinInterstitial.delegateMethodsToValidate);
    BOOL rewardedDelegatesAreValid = validate(BIDApplovinRewarded.class, BIDApplovinRewarded.delegateMethodsToValidate);
    BOOL bannerDelegatesAreValid = validate(BIDApplovinBanner.class, BIDApplovinBanner.delegateMethodsToValidate);
    
    return interstitialDelegatesAreValid && rewardedDelegatesAreValid && bannerDelegatesAreValid;
}

- (void)enableTesting
{
}

- (void)enableLogging
{
	self.alSDK.settings.verboseLoggingEnabled = YES;
}

- (void)setConsent:(id<BIDConsent>)consent
{
	if (consent.GDPR)
	{
		ALPrivacySettings.hasUserConsent = consent.GDPR.boolValue;
	}
	
	if (consent.CCPA)
	{
		ALPrivacySettings.doNotSell = !consent.CCPA.boolValue;
	}
	
	if (consent.COPPA)
	{
		ALPrivacySettings.isAgeRestrictedUser = consent.COPPA.boolValue;
	}
}

-(void)setUserId:(NSString *)userId
{
    self.alSDK.userIdentifier = userId;
}

@end
