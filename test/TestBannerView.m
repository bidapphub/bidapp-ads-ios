//
//  TestBannerView.m
//  bidapp
//
//  Created by Mikhail Krasnorutskiy on 11/9/23.
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "TestBannerView.h"

@interface TestBannerView()

@property(nonatomic,weak) id<TestBannerViewDelegate> delegate;

@end

@implementation TestBannerView

-(void)showAdWithDelegate:(id<TestBannerViewDelegate>)d
{
    self.delegate = d;
    TestBannerView* __weak weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!(rand() % 8))
        {
            return [weakSelf.delegate bannerDidFailedToShowAd:weakSelf error:[NSError errorWithDomain:@"co.testcompany.sdk" code:343455 userInfo:@{NSLocalizedDescriptionKey:@"No fill"}]];
        }
        
        [weakSelf.subviews.lastObject removeFromSuperview];
        
        UILabel* l = [UILabel new];
        l.text = @"Test Ad";
        [l sizeToFit];
        l.backgroundColor = UIColor.whiteColor;
        
        UITapGestureRecognizer *gesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(handleTap)]; // Declare the Gesture.
        [weakSelf addGestureRecognizer:gesRecognizer]; // Add Gesture to your view.

        [weakSelf addSubview:l];
        
        [weakSelf.delegate bannerDidShowAd:weakSelf];
    });
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [(UILabel*)self.subviews.lastObject setCenter:CGPointMake(self.bounds.size.width/2,self.bounds.size.height/2)];
}

-(void)handleTap
{
    [self.delegate bannerDidClick:self];
}

@end
