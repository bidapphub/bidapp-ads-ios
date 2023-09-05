//
//  BIDApplovinInitializer.h
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 4/5/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#ifdef APPLOVIN_MAX
#import "BIDApplovinMaxSDK.h"
@interface BIDApplovinMaxSDK(ALInit)
#else
#import "BIDApplovinSDK.h"
@interface BIDApplovinSDK(ALInit)
#endif

+(BOOL)startSDK:(id)sdk completion:(dispatch_block_t)completion;

@end
