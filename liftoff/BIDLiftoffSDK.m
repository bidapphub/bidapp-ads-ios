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

#import "BIDNetworkSettings.h"
#import "BIDLiftoffBanner.h"
#import "BIDAdInfo_private.h"
#import "BIDAdFormat.h"

@implementation BIDLiftoffSDK
{
	id<BIDNetworkSDK> __weak networkSDK;
	NSString* accountId;
	
	BOOL testMode;
}

-(id)initWithNetworkSDK:(id<BIDNetworkSDK>)ntSDK accountId:(NSString*)accId
{
	if (self == [super init])
	{
		networkSDK = ntSDK;
		accountId = accId;
	}
	
	return self;
}

+ (BOOL)sdkAvailableWithCompatibleVersion
{
	Class NetworkClass = NSClassFromString(@"VungleAdsSDK.VungleAds");
	BIDLog(self, @"Liftoff Available: %@.",(Nil!=NetworkClass)?@"YES":@"NO");
	
	if (Nil!=NetworkClass) {
		NSString *version = ![NetworkClass respondsToSelector:@selector(sdkVersion)] ? nil : [(id)NetworkClass sdkVersion];
		NSArray *verComponents = [version componentsSeparatedByString:@"."];
		if (verComponents.count < 2) {
			BIDLog(self, @"Liftoff version is NOT compatible: v.%@. Version is Undefined",version);
			return NO;
		}
		else {
			NSString *major = verComponents[0];
			NSString *minor = verComponents[1];
			NSUInteger compatibleMajor = 7;
			NSUInteger compatibleMinor = 0;
			if (compatibleMajor == [major integerValue] && compatibleMinor == [minor integerValue])
			{
				BIDLog(self, @"Liftoff version is compatible: v.%@",version);
				return YES;
			}
			else
			{
				BIDLog(self, @"Liftoff version is NOT compatible: v.%@. Compatable versions are: %ld.%ld.*",version,compatibleMajor,compatibleMinor);
				return NO;
			}
		}
	}
	return NO;
}

// super override
- (void)initializeSDK
{
	if (!self.isInitialized &&
		!networkSDK.initializationInProgress)
	{
		[networkSDK onInitializationStart];
		
		__weak typeof(self) weakSelf = self;
		[VungleAds initWithAppId:accountId completion:^(NSError * _Nullable error) {
			
			//Вангл дергает completion из неглавного потока
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
