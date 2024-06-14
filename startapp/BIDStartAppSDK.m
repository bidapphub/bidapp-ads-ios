//
//  BIDStartAdapter.m
//  bidapp
//
//  Created by Vasiliy Masnev on 11.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDStartAppSDK.h"
#import "BIDLogger.h"

#import "BIDStartAppFullscreen.h"
#import "BIDStartAppBanner.h"
#import "BIDNetworkSettings.h"
#import "BIDTestBanner.h"
#import "BIDAdFormat.h"
#import <StartApp/StartApp.h>

@interface BIDStartAppSDK()
{
    BOOL initialized;
}

@property (nonatomic,weak) id<BIDNetworkSDK> networkSDK;

@end

@implementation BIDStartAppSDK
{
	NSString* appID;
}

-(id)initWithNetworkSDK:(id<BIDNetworkSDK>)ntSDK SDKKey:(NSString*)appId_ secondKey:(NSString * _Nullable)secondKey
{
	if (self == [super init])
	{
        _networkSDK = ntSDK;
		appID = appId_;
	}
	
	return self;
}

- (void)initializeSDK
{
	if (!self.isInitialized &&
		!_networkSDK.initializationInProgress)
	{
		[_networkSDK onInitializationStart];

        STAStartAppSDK* sdk = [STAStartAppSDK sharedInstance];

        sdk.appID = appID;
        
        sdk.returnAdEnabled = NO;
        
        initialized = YES;
        
        [_networkSDK onInitializationComplete:YES error:nil];
	}
};

- (BOOL)isInitialized
{
    return initialized;
}

+ (BOOL)sdkAvailableWithCompatibleVersion:(validate_selectors_t)validate
{
    BOOL fullscreenDelegatesAreValid = validate(BIDStartAppFullscreen.class, BIDStartAppFullscreen.delegateMethodsToValidate);
    BOOL bannerDelegatesAreValid = validate(BIDStartAppBanner.class, BIDStartAppBanner.delegateMethodsToValidate);
    
    return fullscreenDelegatesAreValid && bannerDelegatesAreValid;
}

- (void)enableTesting
{
    [STAStartAppSDK sharedInstance].testAdsEnabled = YES;
}

- (void)enableLogging
{
}

- (void)setConsent:(id<BIDConsent>)consent
{
    if (consent.GDPR)
    {
        [[STAStartAppSDK sharedInstance] setUserConsent:consent.GDPR.boolValue forConsentType:@"pas" withTimestamp:[[NSDate date] timeIntervalSince1970]];
    }
    
    if (consent.CCPA)
    {
        STAStartAppSDK *sdk = [STAStartAppSDK sharedInstance];
        [sdk handleExtras:^(NSMutableDictionary<NSString*,id>* extras) {
            [extras setObject:(consent.CCPA.boolValue ? @"1YNN" : @"1YYN") forKey:@"IABUSPrivacy_String"];
        }];
    }
}

@end
