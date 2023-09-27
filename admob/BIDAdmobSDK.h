//
//  BIDAdmobSDK.h
//  bidapp
//
//  Created by Vasiliy Masnev on 11.03.2023.
//  Copyright © 2023 Vasiliy Macnev. All rights reserved.
//

#import <bidapp/BIDNetworkAdapter.h>

NS_ASSUME_NONNULL_BEGIN

@interface BIDAdmobSDK : NSObject<BIDNetworkAdapter>

@property(nonatomic,readonly,class) NSNumber* GDPR;

@end

NS_ASSUME_NONNULL_END
