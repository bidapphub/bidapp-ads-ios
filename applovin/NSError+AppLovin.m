//
//  NSError+AppLovin.m
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 28/4/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "NSError+AppLovin.h"
#import "NSError+Categories.h"
#import "BIDNetworkSettings.h"
#import <AppLovinSDK/AppLovinSDK.h>

@implementation NSError(BIDAppLovin)

+ (NSError *)applovinErrorWithCode:(int)code isLoadError:(BOOL* __nullable)pIsLoadError
{
	NSString *message = @"Unknown error";
	BOOL isLoadError = YES;
	switch (code) {
		case kALErrorCodeSdkDisabled:
			message = @"The Applovin SDK is currently disabled";
			break;
		case kALErrorCodeNoFill:
			message = @"No ads are currently eligible for your device & location";
			break;
		case kALErrorCodeAdRequestNetworkTimeout:
			message = @"A fetch ad request timed out (usually due to poor connectivity)";
			break;
		case kALErrorCodeNotConnectedToInternet:
			message = @"The device is not connected to internet (for instance if user is in Airplane mode)";
			break;
		case kALErrorCodeAdRequestUnspecifiedError:
			message = @"An unspecified network issue occurred";
			break;
		case kALErrorCodeUnableToRenderAd:
			message = @"There has been a failure to render an ad on screen";
			isLoadError = NO;
			break;
		case kALErrorCodeInvalidZone:
			message = @"The zone provided is invalid; the zone needs to be added to your AppLovin account or may still be propagating to our servers";
			break;
		case kALErrorCodeUnableToPrecacheResources:
			message = @"An attempt to cache a resource to the filesystem failed; the device may be out of space";
			break;
		case kALErrorCodeUnableToPrecacheImageResources:
			message = @"An attempt to cache an image resource to the filesystem failed; the device may be out of space";
			break;
		case kALErrorCodeUnableToPrecacheVideoResources:
			message = @"An attempt to cache a video resource to the filesystem failed; the device may be out of space";
			break;
		case kALErrorCodeInvalidResponse:
			message = @"AppLovin servers have returned an invalid response";
			break;
// Rewarded Videos
		case kALErrorCodeIncentiviziedAdNotPreloaded:
			message = @"The developer called for a rewarded video before one was available";
			break;
		case kALErrorCodeIncentivizedUnknownServerError:
			message = @"An unknown server-side error occurred";
			break;
		case kALErrorCodeIncentivizedValidationNetworkTimeout:
			message = @"A reward validation requested timed out (usually due to poor connectivity)";
			break;
		case kALErrorCodeIncentivizedUserClosedVideo:
			message = @"The user exited out of the rewarded ad early. You may or may not wish to grant a reward depending on your preference";
			isLoadError = NO;
			break;
		case kALErrorCodeInvalidURL:
			message = @"A postback URL you attempted to dispatch was empty or nil.";
			break;
	}
	
	if (pIsLoadError)
	{
		*pIsLoadError = isLoadError;
	}
	
	return [NSError errorWithDomain:[NSError domainForNetworkId:APPLOVIN_ADAPTER_UID]
							   code:code
						   userInfo:@{NSLocalizedDescriptionKey:message}];
}

+ (NSError *)applovinBannerErrorWithCode:(int)code
{
	NSString *message = @"Unknown error";
	BOOL isLoadError = YES;
	switch (code) {
		case kALErrorCodeSdkDisabled:
			message = @"The Applovin SDK is currently disabled";
			break;
		case kALErrorCodeNoFill:
			message = @"No ads are currently eligible for your device & location";
			break;
		case kALErrorCodeAdRequestNetworkTimeout:
			message = @"A fetch ad request timed out (usually due to poor connectivity)";
			break;
		case kALErrorCodeNotConnectedToInternet:
			message = @"The device is not connected to internet (for instance if user is in Airplane mode)";
			break;
		case kALErrorCodeAdRequestUnspecifiedError:
			message = @"An unspecified network issue occurred";
			break;
		case kALErrorCodeUnableToRenderAd:
			message = @"There has been a failure to render an ad on screen";
			isLoadError = NO;
			break;
		case kALErrorCodeInvalidZone:
			message = @"The zone provided is invalid; the zone needs to be added to your AppLovin account or may still be propagating to our servers";
			break;
		case kALErrorCodeUnableToPrecacheResources:
			message = @"An attempt to cache a resource to the filesystem failed; the device may be out of space";
			break;
		case kALErrorCodeUnableToPrecacheImageResources:
			message = @"An attempt to cache an image resource to the filesystem failed; the device may be out of space";
			break;
		case kALErrorCodeUnableToPrecacheVideoResources:
			message = @"An attempt to cache a video resource to the filesystem failed; the device may be out of space";
			break;
		case kALErrorCodeInvalidResponse:
			message = @"AppLovin servers have returned an invalid response";
			break;
// Rewarded Videos
		case kALErrorCodeIncentiviziedAdNotPreloaded:
			message = @"The developer called for a rewarded video before one was available";
			break;
		case kALErrorCodeIncentivizedUnknownServerError:
			message = @"An unknown server-side error occurred";
			break;
		case kALErrorCodeIncentivizedValidationNetworkTimeout:
			message = @"A reward validation requested timed out (usually due to poor connectivity)";
			break;
		case kALErrorCodeIncentivizedUserClosedVideo:
			message = @"The user exited out of the rewarded ad early. You may or may not wish to grant a reward depending on your preference";
			isLoadError = NO;
			break;
		case kALErrorCodeInvalidURL:
			message = @"A postback URL you attempted to dispatch was empty or nil.";
			break;
	}
	
	return [NSError errorWithDomain:@"io.bidapp.applovin"
							   code:code
						   userInfo:@{NSLocalizedDescriptionKey:message}];
}

@end
