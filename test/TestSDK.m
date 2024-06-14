//
//  TestSDK.m
//  bidapp
//
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "TestSDK.h"

@implementation TestSDK

static BOOL _isInitialized = NO;

+(void)startWithSDKKey:(NSString*)key completion:(test_sdk_completion_t)completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!_isInitialized &&
            !(rand() % 8))
        {
            return completion(NO, [NSError errorWithDomain:@"co.testcompany.sdk" code:343455 userInfo:@{NSLocalizedDescriptionKey:@"Unknown error"}]);
        }
        
        _isInitialized = YES;
        
        completion(YES, nil);
    });
}

+(BOOL)isInitialized
{
    return _isInitialized;
}

@end
