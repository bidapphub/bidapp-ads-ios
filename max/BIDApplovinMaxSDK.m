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

#import "BIDNetworkSettings.h"
#import "BIDApplovinMaxBanner.h"
#import "BIDAdInfo_private.h"
#import "BIDAdFormat.h"
#import "NSError+Categories.h"

@implementation BIDApplovinMaxSDK
{
	id<BIDNetworkSDK> __weak adapter;
	NSString* sdkKey;
}

-(id)initWithNetworkSDK:(id<BIDNetworkSDK>)adapter_ SDKKey:(NSString*)sdkKey_
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
