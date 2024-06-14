//
//  TestFullscreen.m
//  bidapp
//
//  Copyright © 2023 bidapp. All rights reserved.
//

#import "TestFullscreen.h"

@interface TestAd()

@property(nonatomic,weak) id<TestAdShowDelegate> delegate;
@property(nonatomic) BOOL isRewarded;

@end

@implementation TestAd
{
    UIButton* closeButton;
}

-(void)showWithDelegate:(id<TestAdShowDelegate>)delegate fromViewController:(UIViewController*)vc;
{
    [self.delegate onAdWillAppear:self];
    if (!vc)
    {
        TestAd* __weak t = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [t.delegate onAdDidFailedToAppear:t error:[NSError errorWithDomain:@"co.testcompany.sdk" code:45656 userInfo:@{NSLocalizedDescriptionKey:@"Presenting view controller is nil"}]];
        });
        
        return;
    }
    
    self.delegate = delegate;
    
    TestAd* __weak t = self;
    [vc presentViewController:self animated:YES completion:^{
        
        [t.delegate onAdDidAppear:t];
        if (t.isRewarded)
        {
            [t.delegate onReward];
        }
    }];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        closeButton = [UIButton buttonWithType:UIButtonTypeClose];
        [closeButton addTarget:self action:@selector(handleClose) forControlEvents:UIControlEventTouchDown];
        [closeButton sizeToFit];
        [self.view addSubview:closeButton];
    }
    
    UILabel* l = [UILabel new];
    l.text = @"Test Ad";
    [l sizeToFit];
    l.backgroundColor = UIColor.whiteColor;
    self.view.backgroundColor = UIColor.grayColor;
    
    UITapGestureRecognizer *gesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]; // Declare the Gesture.
    [self.view addGestureRecognizer:gesRecognizer]; // Add Gesture to your view.

    [self.view addSubview:l];
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized)
    {
        [_delegate onAdDidClick:self];
        
        if (@available(iOS 13.0, *)) {
        }
        else
        {
            [self handleClose];
        }
    }
}

- (void)handleClose
{
    TestAd* __weak t = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [t.delegate onAdDidDisappear:self];
    }];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [closeButton setCenter:CGPointMake(self.view.bounds.size.width-closeButton.bounds.size.width,closeButton.bounds.size.height)];
    
    [(UILabel*)self.view.subviews.lastObject setCenter:CGPointMake(self.view.bounds.size.width/2,self.view.bounds.size.height/2)];
}

@end

@implementation TestInterstitial : NSObject

-(void)loadWithDelegate:(id<TestAdLoadDelegate>)d
{
    id<TestAdLoadDelegate> __weak delegate = d;
    TestInterstitial* __weak weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!(rand() % 8))
        {
            return [delegate onFullscreenDidFailedToLoadAd:weakSelf error:[NSError errorWithDomain:@"co.testcompany.sdk" code:375455 userInfo:@{NSLocalizedDescriptionKey:@"No fill"}]];
        }
        
        TestAd* ad = [TestAd new];
        ad.isRewarded = NO;
        
        [delegate onFullscreen:weakSelf didLoadAd:ad];
    });
}

@end

@implementation TestRewarded : NSObject

-(void)loadWithDelegate:(id<TestAdLoadDelegate>)d
{
    id<TestAdLoadDelegate> __weak delegate = d;
    TestRewarded* __weak weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!(rand() % 8))
        {
            return [delegate onFullscreenDidFailedToLoadAd:weakSelf error:[NSError errorWithDomain:@"co.testcompany.sdk" code:375455 userInfo:@{NSLocalizedDescriptionKey:@"No fill"}]];
        }
        
        TestAd* ad = [TestAd new];
        ad.isRewarded = YES;
        
        [delegate onFullscreen:weakSelf didLoadAd:ad];
    });
}

@end
