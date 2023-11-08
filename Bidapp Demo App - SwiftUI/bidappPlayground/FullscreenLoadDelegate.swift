//
//  FullscreenLoadDelegate.swift
//  bidappPlayground
//
//  Copyright 2023 bidapp. All rights reserved.
//

import UIKit
import bidapp

class FullscreenLoadDelegate : NSObject, BIDFullscreenLoadDelegate {
    func didLoadAd(_ adInfo: BIDAdInfo) {
        let waterfallId = adInfo.waterfallId ?? ""
        let isRewardedString = adInfo.format.isRewarded() ? "yes" : "no";
        print("Bidapp fullscreen [\(waterfallId)] didLoadAd: \(adInfo.networkId) [\(adInfo)]. IsRewarded: \(isRewardedString)")
    }
    
    func didFail(toLoadAd adInfo: BIDAdInfo, error: Error) {
        let waterfallId = adInfo.waterfallId ?? ""
        let descr = error.localizedDescription
        print("Bidapp fullscreen [\(waterfallId))] didFailToLoadAd: \(adInfo.networkId) [\(adInfo)]. ERROR: \(descr)");
    }
}
