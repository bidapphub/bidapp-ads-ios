//
//  BIDAdmobSDK.m
//  bidapp
//
//  Created by Vasiliy Masnev on 11.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDAdmobSDK.h"
#import "BIDLogger.h"

#import "BIDAdmobInterstitial.h"
#import "BIDAdmobRewarded.h"
#import "BIDAdmobBanner.h"
#import "BIDNetworkSettings.h"
#import "BIDAdmobBanner.h"
#import "BIDAdFormat.h"

#import <GoogleMobileAds/GoogleMobileAds.h>

@interface BIDAdmobSDK()

@property (nonatomic,weak) id<BIDNetworkSDK> networkSDK;
@property (nonatomic) BOOL initialized;

@end

@implementation BIDAdmobSDK
{
	NSString* sdkKey;
}

-(id)initWithNetworkSDK:(id<BIDNetworkSDK>)ntSDK SDKKey:(NSString*)sdkK secondKey:(NSString * _Nullable)secondKey
{
	if (self == [super init])
	{
        _networkSDK = ntSDK;
		sdkKey = sdkK;
	}
	
	return self;
}

- (void)initializeSDK
{
	if (!self.isInitialized &&
		!_networkSDK.initializationInProgress)
	{
		[_networkSDK onInitializationStart];
		
        BIDAdmobSDK* __weak t = self;
        [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus * _Nonnull status) {
            t.initialized = YES;
            [t.networkSDK onInitializationComplete:YES error:nil];
        }];
	}
};

- (BOOL)isInitialized
{
    return self.initialized;
}

+ (BOOL)sdkAvailableWithCompatibleVersion:(validate_selectors_t)validate
{
    BOOL interstitialDelegatesAreValid = validate(BIDAdmobInterstitial.class, BIDAdmobInterstitial.delegateMethodsToValidate);
    BOOL rewardedDelegatesAreValid = validate(BIDAdmobRewarded.class, BIDAdmobRewarded.delegateMethodsToValidate);
    BOOL bannerDelegatesAreValid = validate(BIDAdmobBanner.class, BIDAdmobBanner.delegateMethodsToValidate);
    
    return interstitialDelegatesAreValid && rewardedDelegatesAreValid && bannerDelegatesAreValid;
}

- (void)enableAdmobing
{
}

- (void)enableLogging
{
}

- (void)enableTesting {
    
}

static NSNumber* currentConsent_GDPR = nil;
+ (NSNumber *)GDPR
{
    return currentConsent_GDPR;
}

- (void)setConsent:(id<BIDConsent>)consent
{
    currentConsent_GDPR = consent.GDPR;

    if (consent.CCPA)
    {
        if (!consent.CCPA.boolValue)
        {
            // Restrict data processing - https://developers.google.com/admob/ios/ccpa
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"gad_rdp"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"gad_rdp"];
        }
    }
    
    if (consent.COPPA)
    {
        GADMobileAds.sharedInstance.requestConfiguration.tagForChildDirectedTreatment = consent.COPPA;
    }
}

@end
