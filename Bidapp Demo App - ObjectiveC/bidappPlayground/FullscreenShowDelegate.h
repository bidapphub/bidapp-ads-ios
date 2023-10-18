//
//  FullscreenShowDelegate.h
//  bidappPlayground
//
//  Copyright 2023 bidapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <bidapp/BIDFullscreenDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface FullscreenShowDelegate : NSObject<BIDRewardedDelegate>

-(id)initWithViewController:(UIViewController*)vc;

@end

NS_ASSUME_NONNULL_END
