//
//  AppDelegate.swift
//  bidappPlayground
//
//  Copyright 2023 bidapp. All rights reserved.
//

import UIKit
import AppTrackingTransparency
import bidapp

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var loadDelegate:BIDFullscreenLoadDelegate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let bidConfig = BIDConfiguration()
        bidConfig.enableTestMode()
        bidConfig.enableLogging()
        
        bidConfig.enableInterstitialAds()
        bidConfig.enableRewardedAds()
        bidConfig.enableBannerAds()
        
        let pubid = "15ddd248-7acc-46ce-a6fd-e6f6543d22cd"
        if #available(iOS 14, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ATTrackingManager.requestTrackingAuthorization { _ in }
                
                print("start");
                BidappAds.start(withPubid: pubid, config: bidConfig)
            }
        }
        else {
            print("start")
            BidappAds.start(withPubid: pubid, config: bidConfig)
        }
 
        return true
    }
}
