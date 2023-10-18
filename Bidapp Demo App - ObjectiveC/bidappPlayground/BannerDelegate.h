//
//  BannerDelegate.h
//  bidappPlayground
//
//  Copyright 2023 bidapp. All rights reserved.
//

#import <bidapp/bidapp.h>

#define AD_BANNER_TO_SUBVIEW_IMMEDIATELY

NS_ASSUME_NONNULL_BEGIN

@interface BannerDelegate : NSObject<BIDBannerViewDelegate>

@property(nonatomic,weak) UIView* bannerContainerView;

@end

NS_ASSUME_NONNULL_END
