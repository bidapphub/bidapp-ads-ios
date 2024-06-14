//
//  BannerDelegate.swift
//  bidappPlayground
//
//  Copyright 2023 bidapp. All rights reserved.
//

import UIKit
import bidapp

class BannerDelegate : NSObject, BIDBannerViewDelegate {
    
    func bannerDidLoad(_ banner: BIDBannerView, adInfo: BIDAdInfo) {
        print("[\(String(describing: adInfo.showSessionId))][\(String(describing: adInfo.waterfallId))] bannerDidLoad: \(adInfo.networkId) [\(adInfo)]")
        
        if !banner.isAdDisplayed() {
            banner.refreshAd()
        }
    }
    
    func bannerDidDisplay(_ banner: BIDBannerView, adInfo: BIDAdInfo) {
        print("[\(String(describing: adInfo.showSessionId))][\(String(describing: adInfo.waterfallId))] bannerDidDisplay: \(adInfo.networkId) [\(adInfo)]")
    }
    
    func bannerDidFail(toDisplay banner: BIDBannerView, adInfo: BIDAdInfo, error: Error) {
        print("[\(String(describing: adInfo.showSessionId))][\(String(describing: adInfo.waterfallId))] bannerDidFailToDisplay: \(adInfo.networkId) [\(adInfo)] ERROR: \(error.localizedDescription)")
    }
    
    func bannerDidClick(_ banner: BIDBannerView, adInfo: BIDAdInfo) {
        print("[\(String(describing: adInfo.showSessionId))][\(String(describing: adInfo.waterfallId))] bannerDidClick: \(adInfo.networkId) [\(adInfo)]")
    }
    
    func allNetworksFailedToDisplayAd(inBanner banner: BIDBannerView) {
        print("allNetworksFailedToDisplayAd")
    }
}
