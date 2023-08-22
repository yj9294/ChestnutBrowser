import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import './gad_config.dart';
import './gad_position.dart';

typedef GADClickHandler = void Function();
typedef GADImpressionHandler = void Function();
typedef GADCloseHandler = void Function();
typedef GADErrorHandler = void Function();

abstract class GADModel {
  DateTime? loadedDate;

  GADModelCallback? callback;

  // 当前广告id
  GADConfigItem item;

  // 广告位置
  GADPosition position = GADPosition.interstitial;

  // 构造方法
  GADModel(this.item);

  // 加载
  Future<bool> loadAD();

  // 展示
  void present();

  //销毁
  void dispose();
}

class GADInterstitialModel extends GADModel {
  InterstitialAd? _ad;

  GADInterstitialModel(super.item) {
    position = GADPosition.interstitial;
  }

  @override
  void dispose() {
    _ad?.dispose();
    debugPrint("[AD [$position] dispose 🔥🔥🔥");
  }

  @override
  Future<bool> loadAD() async {
    Completer<bool> completer = Completer();
    InterstitialAd.load(
        adUnitId: item.id!,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
          debugPrint("[AD] [interstitial] load ✅✅✅  ${ad.adUnitId}");
          _ad = ad;
          loadedDate = DateTime.now();
          completer.complete(true);
        }, onAdFailedToLoad: (error) {
          debugPrint("[AD] [interstitial] load ❌❌❌  ${item.id} , err:$error");
          completer.complete(false);
        }));
    return completer.future;
  }

  @override
  void present() {
    _ad?.fullScreenContentCallback =
        FullScreenContentCallback(onAdClicked: (ad) {
      callback!.clickHandler();
    }, onAdImpression: (ad) {
      callback?.impressionHandler();
    }, onAdDismissedFullScreenContent: (ad) {
      dispose();
      callback?.closeHandler();
    }, onAdFailedToShowFullScreenContent: (ad, err) {
      debugPrint("[AD] [interstitial] show ❌❌❌ ${ad.adUnitId} , err:$err");
      dispose();
      callback?.errorHandler();
    });
    _ad?.show();
  }
}

class GADNativeModel extends GADModel {
  NativeAd? ad;

  // 构造起
  GADNativeModel(super.item) {
    position = GADPosition.native;
  }

  @override
  void dispose() {
    ad?.dispose();
  }

  @override
  Future<bool> loadAD() async {
    Completer<bool> completer = Completer();
    ad = NativeAd(
        adUnitId: item.id!,
        factoryId: 'small.nativeAd',
        listener: NativeAdListener(onAdLoaded: (ad) {
          debugPrint("[AD] [native] load ✅✅✅  ${ad.adUnitId}");
          // 记录加载时间
          loadedDate = DateTime.now();
          completer.complete(true);
        }, onAdFailedToLoad: (ad, error) {
          debugPrint("[AD] [native] load ❌❌❌  ${ad.adUnitId} , err:$error");
          completer.complete(false);
          dispose();
        }, onAdImpression: (ad) {
          callback?.impressionHandler();
        }, onAdClicked: (ad) {
          callback?.clickHandler();
        }),
        request: const AdRequest());
    ad?.load();
    return completer.future;
  }

  @override
  void present() {}
}

class GADModelCallback {
  GADImpressionHandler impressionHandler;
  GADClickHandler clickHandler;
  GADCloseHandler closeHandler;
  GADErrorHandler errorHandler;

  GADModelCallback(
      {required this.impressionHandler,
      required this.clickHandler,
      required this.closeHandler,
      required this.errorHandler});
}
