//
//  BannerDelegate.swift
//  bidappPlayground
//
//  Copyright 2023 bidapp. All rights reserved.
//

import UIKit
import bidapp

class BannerDelegate : NSObject, BIDBannerViewDelegate {
    
    func adView(_ adView: BIDBannerView, readyToRefresh adInfo: BIDAdInfo) {
        print("[\(String(describing: adInfo.showSessionId))][\(String(describing: adInfo.waterfallId))] readyToRefreshBanner: \(adInfo.networkId) [\(adInfo)]")
        
        if !adView.isAdDisplayed() {
            adView.refreshAd()
        }
    }
    
    func adView(_ adView: BIDBannerView, didDisplayAd adInfo: BIDAdInfo) {
        print("[\(String(describing: adInfo.showSessionId))][\(String(describing: adInfo.waterfallId))] didDisplayBanner: \(adInfo.networkId) [\(adInfo)]")
    }
    
    func adView(_ adView: BIDBannerView, didFailToDisplayAd adInfo: BIDAdInfo, error: Error) {
        print("[\(String(describing: adInfo.showSessionId))][\(String(describing: adInfo.waterfallId))] didFailToDisplayBanner: \(adInfo.networkId) [\(adInfo)] ERROR: \(error.localizedDescription)")
    }
    
    func adView(_ adView: BIDBannerView, didClicked adInfo: BIDAdInfo) {
        print("[\(String(describing: adInfo.showSessionId))][\(String(describing: adInfo.waterfallId))] bannerDidClicked: \(adInfo.networkId) [\(adInfo)]")
    }
}
