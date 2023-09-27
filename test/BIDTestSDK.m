//
//  BIDTestAdapter.m
//  bidapp
//
//  Created by Vasiliy Masnev on 11.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import "BIDTestSDK.h"
#import "BIDLogger.h"

#import "BIDNetworkSettings.h"
#import "BIDTestBanner.h"
#import "BIDAdInfo_private.h"
#import "BIDAdFormat.h"
#import "NSError+Categories.h"

#import "TestSDK.h"

@interface BIDTestSDK()

@property (nonatomic,weak) id<BIDNetworkSDK> networkSDK;

@end

@implementation BIDTestSDK
{
	NSString* sdkKey;
}

-(id)initWithNetworkSDK:(id<BIDNetworkSDK>)ntSDK SDKKey:(NSString*)accId
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
		
        BIDTestSDK* __weak t = self;
        [TestSDK startWithSDKKey:sdkKey completion:^(BOOL success, NSError* error) {
        
            [t.networkSDK onInitializationComplete:success error:error];
        }];
	}
};

- (BOOL)isInitialized
{
    return [TestSDK isInitialized];
}

+ (BOOL)sdkAvailableWithCompatibleVersion
{
    return YES;
}

- (void)enableTesting
{
}

- (void)enableLogging
{
}

- (void)setConsent:(id<BIDConsent>)consent
{
}

@end
