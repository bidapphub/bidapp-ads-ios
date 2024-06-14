//
//  BIDChartboostSDK.m
//  bidapp
//
//  Created by Vasiliy Masnev on 11.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDChartboostSDK.h"
#import "BIDLogger.h"

#import "BIDChartboostInterstitial.h"
#import "BIDChartboostRewarded.h"
#import "BIDChartboostBanner.h"
#import "BIDNetworkSettings.h"
#import "BIDTestBanner.h"
#import "BIDAdFormat.h"

#import "TestSDK.h"

#import <ChartboostSDK/Chartboost.h>

@interface BIDChartboostSDK()

@property (nonatomic,weak) id<BIDNetworkSDK> networkSDK;
@property (nonatomic) BOOL initialized;

@end

@implementation BIDChartboostSDK
{
	NSString* appId;
    NSString* appSignature;
}

-(id)initWithNetworkSDK:(id<BIDNetworkSDK>)ntSDK SDKKey:(NSString*)accId secondKey:(NSString * _Nullable)secondKey
{
	if (self == [super init])
	{
        if (!secondKey)
        {
            return nil;
        }
        
        _networkSDK = ntSDK;
        
        appId = accId;
        appSignature = secondKey;
	}
	
	return self;
}

- (void)initializeSDK
{
	if (!self.isInitialized &&
		!_networkSDK.initializationInProgress)
	{
		[_networkSDK onInitializationStart];
		
        BIDChartboostSDK* __weak t = self;
        NSLog(@"Chartboost SDK Version %@", [Chartboost getSDKVersion]);

        [Chartboost startWithAppID:appId
                      appSignature:appSignature
                        completion:^(CHBStartError * _Nullable error) {
            
            if (nil == error)
            {
                self.initialized = YES;
            }
            
            [t.networkSDK onInitializationComplete:nil==error error:error];
        }];
	}
};

- (BOOL)isInitialized
{
    return self.initialized;
}

+ (BOOL)sdkAvailableWithCompatibleVersion:(validate_selectors_t)validate
{
    BOOL interstitialDelegatesAreValid = validate(BIDChartboostInterstitial.class, BIDChartboostInterstitial.delegateMethodsToValidate);
    BOOL rewardedDelegatesAreValid = validate(BIDChartboostRewarded.class,BIDChartboostRewarded.delegateMethodsToValidate);
    BOOL bannerDelegatesAreValid = validate(BIDChartboostBanner.class, BIDChartboostBanner.delegateMethodsToValidate);
    
    return interstitialDelegatesAreValid && rewardedDelegatesAreValid && bannerDelegatesAreValid;
}

- (void)enableTesting
{
}

- (void)enableLogging
{
    [Chartboost setLoggingLevel:CBLoggingLevelInfo];
}

- (void)setConsent:(id<BIDConsent>)consent
{
    if (consent.GDPR)
    {
        [Chartboost addDataUseConsent:[CHBGDPRDataUseConsent gdprConsent:consent.GDPR.boolValue ? CHBGDPRConsentBehavioral : CHBGDPRConsentNonBehavioral]];
    }
    
    if (consent.CCPA)
    {
        [Chartboost addDataUseConsent:[CHBCCPADataUseConsent ccpaConsent:consent.CCPA.boolValue ? CHBCCPAConsentOptInSale: CHBCCPAConsentOptOutSale]];
    }
    
    if (consent.COPPA)
    {
        [Chartboost addDataUseConsent:[CHBCOPPADataUseConsent isChildDirected:consent.COPPA.boolValue]];
    }
}

@end
