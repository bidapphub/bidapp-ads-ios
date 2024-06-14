//
//  BIDApplovinInitializer.m
//  bidapp
//
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDApplovinInitializer.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import "BIDLogger.h"

#ifdef APPLOVIN_MAX
@implementation BIDApplovinMaxSDK(ALInit)
#else
@implementation BIDApplovinSDK(ALInit)
#endif

static NSMutableDictionary<NSString*,NSMutableArray<dispatch_block_t>*>* startSDKWaiters = nil;
+(BOOL)startSDK:(id)sdk completion:(dispatch_block_t)completion
{
#ifdef APPLOVIN_MAX
	Class c = NSClassFromString(@"BIDApplovinAdapter");
	if (c)
	{
		return [c startSDK:sdk completion:completion];
	}
#endif
	if (!startSDKWaiters)
	{
		startSDKWaiters = [NSMutableDictionary new];
	}
	
	NSString* sdkKey = [(ALSdk*)sdk sdkKey];
	if (!sdkKey)
	{
		dispatch_async(dispatch_get_main_queue(), ^(){
			
			completion();
		});
		
		return NO;
	}
	
	NSMutableArray* waiters = startSDKWaiters[sdkKey];
	if (!waiters)
	{
		waiters = [NSMutableArray new];
		startSDKWaiters[sdkKey] = waiters;
	}
	
	[waiters addObject:completion];
	
	if (waiters.count == 1)
	{
		[(ALSdk*)sdk initializeSdkWithCompletionHandler:^(ALSdkConfiguration *configuration) {
			BIDLog(self,@"Applovin SDK initialized");

            //In case we get callback from background thread (not sure it is possible or not)
			dispatch_async(dispatch_get_main_queue(), ^(){
				
				for (dispatch_block_t t in waiters)
				{
					t();
				}
				
				[waiters removeAllObjects];
			});
		}];
	}
	
	return YES;
}

@end
