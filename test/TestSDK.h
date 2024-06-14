//
//  TestSDK.h
//  bidapp
//
//  Copyright © 2023 bidapp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^test_sdk_completion_t)(BOOL initialized, NSError* __nullable error);

@interface TestSDK : NSObject

+(BOOL)isInitialized;

+(void)startWithSDKKey:(NSString*)key completion:(test_sdk_completion_t)completion;

@end

NS_ASSUME_NONNULL_END
