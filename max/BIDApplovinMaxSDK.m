//
//  BIDApplovinMaxSDK.m
//  bidapp
//
//  Created by Vasiliy Masnev on 11.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDApplovinMaxSDK.h"
#import "BIDLogger.h"
#import "BIDApplovinInitializer.h"

#import <AppLovinSDK/AppLovinSDK.h>

#import "BIDApplovinMaxInterstitial.h"
#import "BIDApplovinMaxRewarded.h"
#import "BIDApplovinMaxBanner.h"
#import "BIDNetworkSettings.h"
#import "BIDApplovinMaxBanner.h"
#import "BIDAdFormat.h"

@implementation BIDApplovinMaxSDK
{
	id<BIDNetworkSDK> __weak adapter;
	NSString* sdkKey;
}

-(id)initWithNetworkSDK:(id<BIDNetworkSDK>)adapter_ SDKKey:(NSString*)sdkKey_ secondKey:(NSString * _Nullable)secondKey
{
	if (self == [super init])
	{
		adapter = adapter_;
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
		!adapter.initializationInProgress)
	{
		[adapter onInitializationStart];
		
		__weak typeof(self) weakSelf = self;
		[BIDApplovinMaxSDK startSDK:self.alSDK completion:^{
			BIDApplovinMaxSDK* strongSelf = weakSelf;
			if (strongSelf)
			{
				[strongSelf->adapter onInitializationComplete:weakSelf.isInitialized
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
    BOOL interstitialDelegatesAreValid = validate(BIDApplovinMaxInterstitial.class, BIDApplovinMaxInterstitial.delegateMethodsToValidate);
    BOOL rewardedDelegatesAreValid = validate(BIDApplovinMaxRewarded.class, BIDApplovinMaxRewarded.delegateMethodsToValidate);
    BOOL bannerDelegatesAreValid = validate(BIDApplovinMaxBanner.class, BIDApplovinMaxBanner.delegateMethodsToValidate);
    
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
