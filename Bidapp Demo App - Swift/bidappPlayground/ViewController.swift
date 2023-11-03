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
    
    var bannerView:BIDBannerView? = nil
    let bannerDelegate = BannerDelegate()
    @IBOutlet weak var bannerBaseView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        interstitial = BIDInterstitial()
        interstitial?.loadDelegate = loadDelegate
        
        rewarded = BIDRewarded()
        rewarded?.loadDelegate = loadDelegate
        
        bannerView = BIDBannerView.banner(with: BIDAdFormat.banner_320x50 as! BIDAdFormat, delegate: bannerDelegate)
        
        if let bannerView = bannerView {
            bannerBaseView.addSubview(bannerView)
        }
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
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        
        bannerView?.stopAutorefresh()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        
        bannerView?.startAutorefresh(30.0)
    }
}
