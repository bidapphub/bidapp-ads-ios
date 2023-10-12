//
//  ViewController.swift
//  bidappPlayground
//
//  Copyright 2023 bidapp. All rights reserved.
//

import UIKit
import bidapp

class ViewController : UIViewController {
    
    static var delegates:[FullscreenShowDelegate] = []
    
    @IBAction func onShowInterstitial(_ sender: Any) {
        let interstitialDelegate = FullscreenShowDelegate(viewController: self)
        ViewController.delegates.append(interstitialDelegate)
        
        BIDInterstitial.show(with: interstitialDelegate)
    }

    @IBAction func onShowRewarded(_ sender: Any) {
        let rewardedDelegate = FullscreenShowDelegate(viewController: self)
        ViewController.delegates.append(rewardedDelegate)
        
        BIDRewarded.show(with: rewardedDelegate)
    }

    @IBAction func onShowBanners(_ sender: Any) {
        let bannersViewController = BannersTableViewController()
        present(bannersViewController, animated: true)
    }
}
