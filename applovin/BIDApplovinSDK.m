//
//  BIDApplovinSDK.m
//  bidapp
//
//  Created by Vasiliy Masnev on 11.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDApplovinSDK.h"

#import <AppLovinSDK/AppLovinSDK.h>

#import "BIDApplovinInitializer.h"
#import "BIDNetworkSettings.h"
#import "BIDApplovinBanner.h"
#import "BIDAdInfo_private.h"
#import "BIDAdFormat.h"
#import "NSError+Categories.h"
#import "BIDLogger.h"

@implementation BIDApplovinSDK
{
	id<BIDNetworkSDK> __weak networkSDK;
	NSString* accountId;
}

-(id)initWithNetworkSDK:(id<BIDNetworkSDK>)ntSDK accountId:(NSString*)accountId_
{
	if (self == [super init])
	{
		networkSDK = ntSDK;
		accountId = accountId_;
	}
	
	return self;
}

- (id __nullable)sharedNativeSDK
{
    return self.alSDK;
}

- (ALSdk *)alSDK
{
	return [ALSdk sharedWithKey:accountId];
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
														 error:weakSelf.isInitialized ? nil : [NSError error_sdkNotInitialized]];
			}
		}];
	}
};

- (BOOL)isInitialized
{
	return self.alSDK.isInitialized;
}

+ (BOOL)sdkAvailableWithCompatibleVersion
{
	Class NetworkClass = NSClassFromString(@"ALSdk");
	BIDLog(self, @"ApplovinSDK SDK Available: %@.",(Nil!=NetworkClass)?@"YES":@"NO");
	
	if (Nil!=NetworkClass)
	{
		NSUInteger versionCode = [NetworkClass versionCode];
		NSUInteger minVerCode = 11070000;
		NSUInteger maxVerCode = 11110399;
		if (versionCode >= minVerCode && versionCode <= maxVerCode)
		{
			BIDLog(self, @"ApplovinSDK version is compatible: v.%ld",versionCode);
			return YES;
		}
		else
		{
			BIDLog(self, @"ApplovinSDK version is NOT compatible: v.%ld. Compatable versions between: %ld - %ld",versionCode,minVerCode,maxVerCode);
			return NO;
		}
	}
	return NO;
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
		ALPrivacySettings.isAgeRestrictedUser = !consent.COPPA.boolValue;
	}
}

@end
