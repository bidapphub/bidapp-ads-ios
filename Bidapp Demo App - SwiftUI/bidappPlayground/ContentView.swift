//
//  ContentView.swift
//  bidappPlayground
//
//  Copyright 2023 bidapp. All rights reserved.
//

import SwiftUI
import bidapp
import AppTrackingTransparency

class BigOrSmallBanner: Identifiable, Equatable {
    
    let id: Int
    let big: Bool
    let banner: BIDBannerView
    let bannerDelegate = BannerDelegate()
    
    static func == (lhs: BigOrSmallBanner, rhs: BigOrSmallBanner) -> Bool {
        return lhs.id == rhs.id
    }
    
    private var _onLoad: (BigOrSmallBanner) -> Void = { (BigOrSmallBanner) -> Void in }
    var onLoad: (BigOrSmallBanner) -> Void {
        get {
            return _onLoad
        }
        set {
            _onLoad = newValue
            bannerDelegate.onLoad = { () -> Void in
                self.onLoad(self)
                self.bannerDelegate.onLoad = { () -> Void in }
            }
        }
    }
    
    init(id: Int, big: Bool) {
        self.id = id
        self.big = big
        
        if (big) {
            self.banner = BIDBannerView.banner(with: BIDAdFormat.banner_300x250 as! BIDAdFormat, delegate: bannerDelegate)
        } else {
            self.banner = BIDBannerView.banner(with: BIDAdFormat.banner_320x50 as! BIDAdFormat, delegate: bannerDelegate)
        }
        
        self.banner.backgroundColor = UIColor.orange
        self.banner.stopAutorefresh()
    }
}

class Banners : ObservableObject {
    
    @Published var items = [BigOrSmallBanner]()
    var pendingBanners = [BigOrSmallBanner]()
    var counter = 0
    var addingTimer:Timer?
    var removingTimer:Timer?
    
    func start() {
        
        self.addOneMoreBanner()
        addingTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            self.addOneMoreBanner()
        }
        
        removingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            if (self.items.count > 2) {
                if let random = self.items.randomElement() {
                    if let index = self.items.firstIndex(of: random) {
                        self.items.remove(at: index)
                    }
                }
            }
        }
    }
    
    private func addOneMoreBanner() {
        if (self.items.count < 5 &&
            self.pendingBanners.count < 2) {
            self.counter += 1
            let banner = BigOrSmallBanner(id: self.counter, big:1 == self.counter%2)
            banner.onLoad = { banner in
                self.items.append(banner)
                
                if let index = self.pendingBanners.firstIndex(of: banner) {
                    self.pendingBanners.remove(at: index)
                }
            }
            self.pendingBanners.append(banner)
        }
    }
    
    func clear() {
        addingTimer?.invalidate()
        addingTimer = nil
        
        removingTimer?.invalidate()
        removingTimer = nil
        
        pendingBanners = []
        items = []
    }
}

struct AdView: UIViewRepresentable {
    
    let bannerDelegate = BannerDelegate()
    let banner:BIDBannerView
    
    init() {
        banner = BIDBannerView.banner(with: BIDAdFormat.banner_320x50 as! BIDAdFormat, delegate: bannerDelegate)
    }
    
    init(bannerView:BIDBannerView) {
        banner = bannerView
    }
    
    func makeUIView(context: Context) -> UIView {
        return banner
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

struct ContentView: View {
    
    @State private var showBanners = false
    
    private var interstitial:BIDInterstitial?
    private var rewarded:BIDRewarded?
    
    let loadDelegate = FullscreenLoadDelegate()
    let showDelegate = FullscreenShowDelegate()
    
    init() {
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
        
        interstitial = BIDInterstitial()
        interstitial?.loadDelegate = loadDelegate
        
        rewarded = BIDRewarded()
        rewarded?.loadDelegate = loadDelegate
    }
    
    @ObservedObject var banners = Banners()
    
    var body: some View {
        
        VStack(alignment: .center) {
            Text("").frame(maxHeight:.infinity)
            Button("Show Interstitial") {
                interstitial?.show(with: showDelegate)
            }
            Text(" ")
            Button("Show Rewarded") {
                rewarded?.show(with: showDelegate)
            }
            Text(" ")
            Button("Show Banners") {
                banners.start()
                showBanners = true
            }
            Text("").frame(maxHeight:.infinity)
        }.safeAreaInset(edge: .bottom) {
            AdView().frame(minWidth: 320, maxWidth: 320, minHeight: 50, maxHeight: 50, alignment: .bottom)
        }.fullScreenCover(isPresented: $showBanners) {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showBanners = false
                        banners.clear()
                    }) {
                        Image(systemName: "xmark")
                            .padding(15)
                    }
                }
                .padding(.top, 5)
                Spacer()
                
                List(banners.items) { b in
                    if b.big {
                        HStack {
                            Spacer()
                            AdView(bannerView: b.banner).frame(minWidth: 300, maxWidth: 300, minHeight: 250, maxHeight: 250, alignment: .center).background(.green)
                            Spacer()
                        }
                    } else {
                        AdView(bannerView: b.banner).frame(minWidth: 320, maxWidth: 320, minHeight: 50, maxHeight: 50, alignment: .center).background(.green)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
