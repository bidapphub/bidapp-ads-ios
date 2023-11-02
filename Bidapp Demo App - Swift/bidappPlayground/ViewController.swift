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
    
    var interstitial:BIDInterstitial? = nil
    var rewarded:BIDRewarded? = nil
    let loadDelegate = FullscreenLoadDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        interstitial = BIDInterstitial()
        interstitial?.loadDelegate = loadDelegate
        
        rewarded = BIDRewarded()
        rewarded?.loadDelegate = loadDelegate
    }
    
    @IBAction func onShowInterstitial(_ sender: Any) {
        let interstitialDelegate = FullscreenShowDelegate(viewController: self)
        ViewController.delegates.append(interstitialDelegate)
        
        interstitial?.show(with: interstitialDelegate)
    }

    @IBAction func onShowRewarded(_ sender: Any) {
        let rewardedDelegate = FullscreenShowDelegate(viewController: self)
        ViewController.delegates.append(rewardedDelegate)
        
        rewarded?.show(with: rewardedDelegate)
    }

    @IBAction func onShowBanners(_ sender: Any) {
        let bannersViewController = BannersTableViewController()
        present(bannersViewController, animated: true)
    }
}
