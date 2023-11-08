//
//  FullscreenShowDelegate.swift
//  bidappPlayground
//
//  Copyright 2023 bidapp. All rights reserved.
//

import UIKit
import bidapp

class FullscreenShowDelegate : NSObject, BIDRewardedDelegate, BIDInterstitialDelegate {
    
    var sessionId:String = ""
    var waterfallId:String = ""
    
    var keyWindowInConnectedScenes: UIWindow? {
        let windowScenes: [UIWindowScene] =  UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene })
        let windows: [UIWindow] = windowScenes.flatMap({ $0.windows })
        return windows.first(where: { $0.isKeyWindow })
    }
    
    func viewControllerForDisplayAd() -> UIViewController {

        if let vc = self.keyWindowInConnectedScenes?.rootViewController {
            return vc
        }
        
        return UIViewController()
    }
    
    func didDisplayAd(_ adInfo: BIDAdInfo) {
        sessionId = adInfo.showSessionId ?? ""
        sessionId = String(sessionId.prefix(3))
        waterfallId = adInfo.waterfallId ?? ""
        
        print("Bidapp fullscreen [\(sessionId)][\(waterfallId)] didDisplayAd: \(adInfo.networkId)")
    }
    
    func didClickAd(_ adInfo: BIDAdInfo) {
        print("Bidapp fullscreen [\(sessionId)][\(waterfallId)] didClickAd: \(adInfo.networkId)")
    }
    
    func didHideAd(_ adInfo: BIDAdInfo) {
        print("Bidapp fullscreen [\(sessionId)][\(waterfallId)] didHideAd: \(adInfo.networkId)")
    }
    
    func didFail(toDisplayAd adInfo: BIDAdInfo, error: Error) {
        sessionId = adInfo.showSessionId ?? ""
        sessionId = String(sessionId.prefix(3))
        waterfallId = adInfo.waterfallId ?? ""
        
        print("Bidapp fullscreen [\(sessionId)][\(waterfallId)] didFailToDisplayAd: \(adInfo.networkId), ERROR: \(error.localizedDescription)")
    }
    
    func allNetworksDidFailToDisplayAd() {
        print("Bidapp fullscreen [\(sessionId)][\(waterfallId)] allNetworksDidFailToDisplayAd")
    }
    
    func didRewardUser() {
        print("Bidapp fullscreen didRewardUser")
    }
}
