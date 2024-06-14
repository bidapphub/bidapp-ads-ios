//
//  BIDStartAdapter.m
//  bidapp
//
//  Created by Vasiliy Masnev on 11.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDFacebookSDK.h"
#import "BIDLogger.h"
#import "BIDFacebookInterstitial.h"
#import "BIDFacebookRewarded.h"
#import "BIDFacebookBanner.h"

#import "BIDNetworkSettings.h"
#import "BIDTestBanner.h"
#import "BIDAdFormat.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface BIDFacebookSDK()

@property (nonatomic,weak) id<BIDNetworkSDK> networkSDK;
@property (nonatomic) BOOL isInitialized;

@end

@implementation BIDFacebookSDK

-(id)initWithNetworkSDK:(id<BIDNetworkSDK>)ntSDK SDKKey:(NSString*)appId_ secondKey:(NSString * _Nullable)secondKey
{
	if (self == [super init])
	{
        _networkSDK = ntSDK;
	}
	
	return self;
}

- (void)initializeSDK
{
	if (!self.isInitialized &&
		!_networkSDK.initializationInProgress)
	{
		[_networkSDK onInitializationStart];

        [FBAdSettings setMediationService:@"bidapp"];
        
        BIDFacebookSDK* __weak weakSelf = self;
        [FBAudienceNetworkAds initializeWithSettings:nil
                                   completionHandler:^(FBAdInitResults * _Nonnull results) {
            
            if (results.success)
            {
                weakSelf.isInitialized = YES;
            }
            
            [weakSelf.networkSDK onInitializationComplete:results.success
                                                error:results.success ? nil : [NSError errorWithDomain:@"com.facebook" code:3845755 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:results.message, nil]]];
        }];
	}
};

+ (BOOL)sdkAvailableWithCompatibleVersion:(validate_selectors_t)validate
{
    BOOL interstitialDelegatesAreValid = validate(BIDFacebookInterstitial.class, BIDFacebookInterstitial.delegateMethodsToValidate);
    BOOL rewardedDelegatesAreValid = validate(BIDFacebookRewarded.class, BIDFacebookRewarded.delegateMethodsToValidate);
    BOOL bannerDelegatesAreValid = validate(BIDFacebookBanner.class, BIDFacebookBanner.delegateMethodsToValidate);
    
    return interstitialDelegatesAreValid && rewardedDelegatesAreValid && bannerDelegatesAreValid;
}

- (void)enableTesting
{
}

- (void)enableLogging
{
    [FBAdSettings setLogLevel:FBAdLogLevelLog];
}

- (void)setConsent:(id<BIDConsent>)consent
{
    //In GDPR and CCPA we rely on Facebook app
    
    if (consent.COPPA)
    {
        [FBAdSettings setMixedAudience:consent.COPPA.boolValue];
    }
}

@end
