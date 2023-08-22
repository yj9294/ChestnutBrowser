import 'dart:async';

import 'package:chestnut_browser/provider/gad_provider.dart';
import 'package:flutter/cupertino.dart';
import './gad_config.dart';
import './gad_model.dart';
import './gad_position.dart';

class GADLoad {
  // 加载位置
  GADPosition position;

  // 预加载序列号
  var preloadIndex = 0;

  // 是否正在预加载
  var isPreloadingAD = false;

  // 正在加载中缓存
  List<GADModel> loadingList = [];

  // 加载完成缓存
  List<GADModel> loadedList = [];

  // 展示中缓存
  List<GADModel> showList = [];

  // 是否有显示中的广告
  bool get isDisplay {
    return showList.isNotEmpty;
  }

  // 是否加载完成 无论成功/失败
  bool loadCompletion = false;

  // 初始化
  GADLoad(this.position);

  // 开始事务瀑布流
  Future<GADModel?> beginADWaterFall() async {
    Completer<GADModel?> completer = Completer();
    preloadIndex = 0;
    // 如果没有加载中且也没有加载完成的缓存就开始加载
    if (!isPreloadingAD && loadedList.isEmpty) {
      debugPrint("[AD] [${position.title()}] start to "
          "prepareLoad-------------");
      // 获取配置
      var config = await GADProvider().getConfig();

      var list = config.itemsOf(position);
      // 预备加载
      GADProvider().isADLimited().then((isLimited) {
        if (isLimited) {
          debugPrint("[AD] [${position.title()}] limited.");
          completer.complete(null);
        } else {
          completer.complete(prepareLoadAD(list));
        }
      });
    } else if (loadedList.isNotEmpty) {
      loadCompletion = true;
      completer.complete(loadedList.first);
      debugPrint("[AD] [${position.title()}] already loaded ad");
    } else {
      debugPrint("[AD] [${position.title()}] loading ad");
    }
    return completer.future;
  }

  // 预加载
  Future<GADModel?> prepareLoadAD(List<GADConfigItem> list) async {
    debugPrint("[AD] [${position.title()}] preload index:$preloadIndex");
    // 加载数组长度判定
    if (list.isEmpty || preloadIndex >= list.length) {
      debugPrint("[AD] [${position.title()}] no more available config.");
      return null;
    }

    // 已经有缓存了
    if (loadedList.isNotEmpty) {
      debugPrint("[AD] [${position.title()}] 已经加载完成。");
      return null;
    }

    // 初次加载时候 前一个瀑布流还没加载完 正在加载中
    if (loadingList.isNotEmpty && preloadIndex == 0) {
      debugPrint("[AD] [${position.title()}] 正在加载中。");
    } else {
      // 构造加载
      var model = position == GADPosition.interstitial
          ? GADInterstitialModel(list[preloadIndex])
          : GADNativeModel(list[preloadIndex]);

      // 使用 completer
      Completer<GADModel?> completer = Completer();
      model.loadAD().then((isSuccess) {
        // 去掉正在加载中缓存
        loadingList = List<GADModel>.from(
            loadingList.where((element) => (model != element)));

        // 成功
        if (isSuccess) {
          loadedList.add(model);
          completer.complete(model);
        } else {
          // 失败 进入下个待加载id
          debugPrint("[AD] [${position.title()}] load ad Fail try load at "
              "index: ${++preloadIndex}");
          completer.complete(prepareLoadAD(list));
        }
      });

      // 放入加载中缓存
      loadingList.add(model);
      return completer.future;
    }
  }

  // 展示的时候会将加载中的缓存给展示缓存
  void appear() {
    // 展示的时候会将加载中的缓存给展示缓存
    showList = loadedList;

    // 晴空加载完成缓存
    loadedList = [];
  }

  // 清空显示缓存
  void disAppear() {
    showList = [];
  }

  // 清理缓存
  void clean() {
    loadingList = [];
    loadedList = [];
    showList = [];
  }
}
