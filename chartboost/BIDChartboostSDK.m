//
//  BIDChartboostSDK.m
//  bidapp
//
//  Created by Vasiliy Masnev on 11.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDChartboostSDK.h"
#import "BIDLogger.h"

#import "BIDNetworkSettings.h"
#import "BIDTestBanner.h"
#import "BIDAdFormat.h"
#import "NSError+Categories.h"

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

+ (BOOL)sdkAvailableWithCompatibleVersion
{
    if (![Chartboost respondsToSelector:@selector(getSDKVersion)])
    {
        return NO;
    }
    
    int componentIndex = 0;
    for (NSString* v in [[Chartboost getSDKVersion]componentsSeparatedByString:@"."])
    {
        int versionComponent = v.intValue;
        if (componentIndex == 0)
        {
            if (versionComponent != 9)
            {
                return NO;
            }
        }
        else if (componentIndex == 1)
        {
            if (versionComponent != 5)
            {
                return NO;
            }
        }
        else
        {
            break;
        }
        
        ++componentIndex;
    }

    return YES;
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
