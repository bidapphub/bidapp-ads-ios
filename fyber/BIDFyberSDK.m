//
//  BIDTestAdapter.m
//  bidapp
//
//  Created by Vasiliy Masnev on 11.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDFyberSDK.h"
#import "BIDLogger.h"
#import "BIDFyberFullscreen.h"
#import "BIDFyberBanner.h"

#import "BIDNetworkSettings.h"
#import "BIDTestBanner.h"
#import "BIDAdFormat.h"
#import <IASDKCore/IASDKCore.h>

#import "TestSDK.h"

@interface BIDFyberSDK()

@property (nonatomic,weak) id<BIDNetworkSDK> networkSDK;

@end

@implementation BIDFyberSDK
{
	NSString* sdkKey;
}

-(id)initWithNetworkSDK:(id<BIDNetworkSDK>)ntSDK SDKKey:(NSString*)accId secondKey:(NSString * _Nullable)secondKey
{
	if (self == [super init])
	{
        _networkSDK = ntSDK;
		sdkKey = accId;
	}
	
	return self;
}

- (void)initializeSDK
{
	if (!self.isInitialized &&
		!_networkSDK.initializationInProgress)
	{
		[_networkSDK onInitializationStart];
		
        BIDFyberSDK* __weak t = self;
        [IASDKCore.sharedInstance initWithAppID:sdkKey
                                completionBlock:^(BOOL success, NSError * _Nullable error) {
            
            [t.networkSDK onInitializationComplete:success error:error];
        }
                                completionQueue:nil];
	}
};

- (BOOL)isInitialized
{
    return IASDKCore.sharedInstance.initialised;
}

+ (BOOL)sdkAvailableWithCompatibleVersion:(validate_selectors_t)validate
{
    BOOL fullscreenDelegatesAreValid = validate(BIDFyberFullscreen.class, BIDFyberFullscreen.delegateMethodsToValidate);

    BOOL bannerDelegatesAreValid = validate(BIDFyberBanner.class, BIDFyberBanner.delegateMethodsToValidate);
    
    return fullscreenDelegatesAreValid && bannerDelegatesAreValid;
}

- (void)enableTesting
{
}

- (void)enableLogging
{
}

- (void)setConsent:(id<BIDConsent>)consent
{
    if (consent.GDPR)
    {
        IASDKCore.sharedInstance.GDPRConsent = consent.GDPR.boolValue;
    }
    
    if (consent.CCPA)
    {
        IASDKCore.sharedInstance.CCPAString = consent.CCPA.boolValue ? @"1YNN" : @"1YYN";
    }
    
    if (consent.COPPA)
    {
        IASDKCore.sharedInstance.coppaApplies = consent.COPPA.boolValue ? IACoppaAppliesTypeGiven : IACoppaAppliesTypeDenied;
    }
}

@end
