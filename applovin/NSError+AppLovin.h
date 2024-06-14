//
//  NSError+AppLovin.h
//  bidapp
//
//  Copyright © 2023 bidapp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError(BIDAppLovin)

+ (NSError *)applovinErrorWithCode:(int)code isLoadError:(BOOL* __nullable)isLoadError; //if isLoadError = NO, it is a display error
+ (NSError *)applovinBannerErrorWithCode:(int)code; //if isLoadError = NO, it is a display error

@end

NS_ASSUME_NONNULL_END
