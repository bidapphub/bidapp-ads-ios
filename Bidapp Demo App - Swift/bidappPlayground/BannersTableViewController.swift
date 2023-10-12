//
//  BannersTableViewController.swift
//  bidappPlayground
//
//  Copyright 2023 bidapp. All rights reserved.
//

import UIKit
import bidapp

@objc(BannersTableViewController)
class BannersTableViewController : UITableViewController,BIDBannerViewDelegate {
    
    var pendingBanners:[BIDBannerView] = []
    var dataSource:[UIView] = []
    var generateBannerTimer:Timer?
    var removeBannerTimer:Timer?
    var reloadTableDelayTimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        schedulAddOneMoreBanner()
        addOneMoreBanner()
        
        removeBannerTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true, block: { [weak self] _ in
            self?.removeOneBanner()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        generateBannerTimer?.invalidate()
        reloadTableDelayTimer?.invalidate()
        removeBannerTimer?.invalidate()
    }
    
    func schedulAddOneMoreBanner() {
        generateBannerTimer?.invalidate()
        generateBannerTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: { [weak self] _ in
            self?.addOneMoreBanner()
        })
    }
    
    func addOneMoreBanner() {
        if (pendingBanners.count < 2) {
            let format = (arc4random_uniform(2)==0) ? BIDAdFormat.banner_300x250 : BIDAdFormat.banner_320x50
            let banner = BIDBannerView.banner(with: format, delegate: self)
            banner.backgroundColor = UIColor.green
            pendingBanners.append(banner)
        }
    }
    
    func removeOneBanner() {
        var removedTheLastOne = false
        for view in dataSource.reversed() {
            if (view.subviews.count > 0) {
                view.subviews.forEach {
                    $0.removeFromSuperview()
                }
                
                view.backgroundColor = UIColor.red
                
                removedTheLastOne = (view == dataSource.first);
                break;
            }
        }
        
        if (removedTheLastOne) {
            dataSource.forEach {
                $0.removeFromSuperview()
            }
            
            dataSource = []
            
            schedulAddOneMoreBanner()
        }

        schedulUpdateTableView()
    }
    
    
    func schedulUpdateTableView() {
        reloadTableDelayTimer?.invalidate()
        reloadTableDelayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { [weak self] _ in
            self?.tableView.reloadData()
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "LOADING..."
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Banner") ?? UITableViewCell(style: .default, reuseIdentifier: "Banner")
        
        cell.contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        let view = self.dataSource[indexPath.row];
        view.center = CGPoint(x: cell.contentView.bounds.midX, y: cell.contentView.bounds.midY);
        view.frame = cell.contentView.bounds;
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cell.contentView.addSubview(view)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let view = dataSource[indexPath.row]
        let bannerView = view.subviews.first
        return (bannerView?.frame.size.height ?? 0) + 10;
    }

    func addAdToSuperviewIfNeeded(_ adView:BIDBannerView) {
        if nil != adView.superview {
            return
        }
        
        let containerView = UIView(frame: .zero)
        containerView.backgroundColor = UIColor.green
        
        adView.backgroundColor = UIColor.orange
        adView.center = CGPoint(x:containerView.bounds.midX, y:containerView.bounds.midY);
        adView.autoresizingMask = [.flexibleTopMargin,.flexibleBottomMargin,.flexibleLeftMargin,.flexibleRightMargin]
        containerView.addSubview(adView)
        
        if let index = pendingBanners.firstIndex(of: adView) {
            pendingBanners.remove(at: index)
        }
        
        dataSource.insert(containerView, at: 0)
        
        if self.dataSource.count > 5 {
            generateBannerTimer?.invalidate()
            generateBannerTimer = nil
        }
        
        schedulUpdateTableView()
    }
    
    func adView(_ adView: BIDBannerView, readyToRefresh adInfo: BIDAdInfo) {
        print("App - readyToRefresh. AdView: \(adView), AdInfo: \(adInfo)")
        
        if !adView.isAdDisplayed() {
            addAdToSuperviewIfNeeded(adView)
            
            adView.refreshAd()
        }
    }
    
    func adView(_ adView: BIDBannerView, didDisplayAd adInfo: BIDAdInfo) {
        print("App - didDisplayAd. AdView: \(adView), AdInfo: \(adInfo)", adView, adInfo);
        
        addAdToSuperviewIfNeeded(adView)
    }
    
    func adView(_ adView: BIDBannerView, didFailToDisplayAd adInfo: BIDAdInfo, error: Error) {
        print("App - didFailToDisplayAd. AdView: \(adView), Error: \(error)");
        
        if let index = pendingBanners.firstIndex(of: adView) {
            pendingBanners.remove(at: index)
        }
    }
    
    func adView(_ adView: BIDBannerView, didClicked adInfo: BIDAdInfo) {
        print("App - didClicked. AdView: \(adView), AdInfo: \(adInfo)")
    }
}
