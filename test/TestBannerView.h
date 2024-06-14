//
//  TestBannerView.h
//  bidapp
//
//  Copyright © 2023 bidapp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TestBannerView;

@protocol TestBannerViewDelegate<NSObject>

-(void)bannerDidShowAd:(TestBannerView*)banner;
-(void)bannerDidFailedToShowAd:(TestBannerView*)banner error:(NSError*)error;
-(void)bannerDidClick:(TestBannerView*)banner;

@end

@interface TestBannerView : UIView

-(void)showAdWithDelegate:(id<TestBannerViewDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
