//
//  GADNativeFactory.swift
//  Runner
//
//  Created by yangjian on 2023/8/18.
//

import UIKit
import google_mobile_ads

class GADNativeFactory: NSObject {

}

extension GADNativeFactory: FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: GADNativeAd, customOptions: [AnyHashable : Any]? = nil) -> GADNativeAdView? {
        if let adView = Bundle.main.loadNibNamed("GADNativeView", owner: self)?.first as? GADNativeAdView {
            DispatchQueue.main.async {
                adView.nativeAd = nativeAd
            }
            return adView
        }
        return nil
    }
}
