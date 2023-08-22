//
//  GADNativeView.swift
//  Runner
//
//  Created by yangjian on 2023/8/18.
//

import UIKit
import google_mobile_ads

class GADNativeView: GADNativeAdView {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var install: UIButton!
    @IBOutlet weak var adTag: UIImageView!
    @IBOutlet weak var placeholder: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var weightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        weightConstraint.constant = (self.window?.frame.width ?? 375.0) - 32
        heightConstraint.constant = weightConstraint.constant * 78.0 / 328.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        weightConstraint.constant = (self.window?.frame.width ?? 375.0) - 32
        heightConstraint.constant = weightConstraint.constant * 78.0 / 328.0
    }

    override var nativeAd: GADNativeAd? {
        didSet {
            super.nativeAd = nativeAd;
            if let nativeAd = nativeAd {
                
                self.icon.isHidden = false
                self.title.isHidden = false
                self.subTitle.isHidden = false
                self.install.isHidden = false
                self.adTag.isHidden = false
                
                self.placeholder.isHidden = true
                
                
                if let image = nativeAd.images?.first?.image {
                    self.icon.image =  image
                }
                self.title.text = nativeAd.headline
                self.subTitle.text = nativeAd.body
                self.install.setTitle(nativeAd.callToAction, for: .normal)
                self.install.setTitleColor(.white, for: .normal)
            } else {
                self.icon.isHidden = true
                self.title.isHidden = true
                self.subTitle.isHidden = true
                self.install.isHidden = true
                self.adTag.isHidden = true
                self.placeholder.isHidden = false
            }
            
            callToActionView = install
            headlineView = title
            bodyView = subTitle
            advertiserView = adTag
            iconView = icon
        }
    }

}
