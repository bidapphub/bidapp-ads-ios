//
//  TestFullscreen.h
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 11/9/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TestAd;

@protocol TestAdShowDelegate<NSObject>

-(void)onAdWillAppear:(TestAd*)ad;
-(void)onAdDidAppear:(TestAd*)ad;
-(void)onAdDidFailedToAppear:(TestAd*)ad error:(NSError*)error;
-(void)onAdDidClick:(TestAd*)ad;
-(void)onAdDidDisappear:(TestAd*)ad;
-(void)onReward;

@end

@interface TestAd : UIViewController

-(void)showWithDelegate:(id<TestAdShowDelegate>)delegate fromViewController:(UIViewController*)vc;

@end

@protocol TestAdLoadDelegate<NSObject>

-(void)onFullscreen:(id)fullscreen didLoadAd:(TestAd*)ad;
-(void)onFullscreenDidFailedToLoadAd:(id)fullscreen error:(NSError*)error;

@end

@interface TestInterstitial : NSObject

-(void)loadWithDelegate:(id<TestAdLoadDelegate>)delegate;

@end

@interface TestRewarded : NSObject

-(void)loadWithDelegate:(id<TestAdLoadDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
