//
//  BIDLiftoffInterstitial.h
//  bidapp
//
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "BIDFullscreenAdapter.h"

@interface BIDLiftoffInterstitial : NSObject<BIDFullscreenAdapter>

+(void)setAppId:(NSString*)appId publisherId:(NSString*)publisherId;

@end

