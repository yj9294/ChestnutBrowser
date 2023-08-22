import UIKit
import Flutter
import google_mobile_ads

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      FLTGoogleMobileAdsPlugin.registerNativeAdFactory(self, factoryId: "small.nativeAd", nativeAdFactory: GADNativeFactory())
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
