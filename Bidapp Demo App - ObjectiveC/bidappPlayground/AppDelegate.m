//
//  AppDelegate.m
//  bidappPlayground
//
//  Created by Vasiliy Masnev on 30.01.2023.
//  Copyright 2023 bidapp. All rights reserved.
//

#import "AppDelegate.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <bidapp/bidapp.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	
	BIDConfiguration *bidConfig = [BIDConfiguration new];
	[bidConfig enableTestMode];
	[bidConfig enableLogging];
	
	[bidConfig enableInterstitialAds];
	[bidConfig enableRewardedAds];
	[bidConfig enableBannerAds];
	
	NSString *pubid = @"15ddd248-7acc-46ce-a6fd-e6f6543d22cd";
	if (@available(iOS 14, *)) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			[ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus s){}];
			
			NSLog(@"start");
			[BidappAds startWithPubid:pubid config:bidConfig];
		});
	}
	else {
		NSLog(@"start");
		[BidappAds startWithPubid:pubid config:bidConfig];
	}
  
	return YES;
}

@end
