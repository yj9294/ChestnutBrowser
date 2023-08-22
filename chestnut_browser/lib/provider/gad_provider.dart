import 'dart:async';
import 'dart:convert';

import 'package:chestnut_browser/event/event_bus_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Util/ext.dart';
import '../gad/gad_position.dart';
import '../gad/gad_limit.dart';
import '../gad/gad_load.dart';
import '../gad/gad_model.dart';
import '../gad/gad_config.dart';

class GADProvider extends ChangeNotifier {
  static final _shared = GADProvider._internal();

  factory GADProvider() => _shared;

  GADProvider._internal() {
    Timer.periodic(const Duration(milliseconds: 5), (timer) {
      for (var element in adLoads) {
        element.loadedList = List<GADModel>.from(element.loadedList
            .where((item) => item.loadedDate?.isExpired() == false));
      }
    });
  }

  // 构造加载模型
  late List<GADLoad> adLoads =
      List<GADLoad>.from(GADPosition.values.map((e) => GADLoad(e)));

  // 当前加载成功的原生广告
  GADNativeModel? nativeModel;

  // 是否正在展示插屏 因为插屏必须手动关闭
  bool isPresentingInterstitialAD = false;

  Future<GADConfig> getConfig() async {
    var prefs = await SharedPreferences.getInstance();
    var configString = prefs.getString('config') ?? "{}";
    return GADConfig.fromJson(configString);
  }

  Future<void> setConfig(GADConfig config) async {
    var prefs = await SharedPreferences.getInstance();
    var ret = await prefs.setString("config", jsonEncode(config.toJson()));
  }

  Future<GADLimit> getLimit() async {
    var prefs = await SharedPreferences.getInstance();
    return GADLimit.fromJsonString(prefs.getString('limit') ?? "{}");
  }

  Future<void> setLimit(GADLimit limit) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('limit', limit.toJsonString());
  }

  void updateNativeAD(GADNativeModel? model) {
    nativeModel = model;
    notifyListeners();
  }

  // 原生广告展示时间
  DateTime homeImpressionDate = DateTime.utc(2020);

  // 原生广告展示时间
  DateTime tabImpressionDate = DateTime.utc(2020);
}

extension GADUtilExt on GADProvider {
  // 是否超限
  Future<bool> isADLimited() async {
    var config = await getConfig();
    var limit = await getLimit();
    if (limit.date?.isToday() == true) {
      return (limit.showTimes ?? 0) >= (config.showTimes ?? 0) ||
          (limit.clickTimes ?? 0) >= (config.clickTimes ?? 0);
    }
    return false;
  }

  // 是否加载完成
  bool isLoadedInterstitialAD() {
    final adLoad = adLoads
        .where((element) => element.position == GADPosition.interstitial)
        .first;
    return adLoad.loadCompletion;
  }

  // 是否有插屏
  bool hasInterstitialAD() {
    return adLoads
        .where((element) => element.position == GADPosition.interstitial)
        .first.loadedList.isNotEmpty;
  }

  // 是否需要清理点击缓存
  Future<bool> isNeedCleanLimit() async {
    var limit = await getLimit();
    return limit.date?.isToday() != true;
  }

  // 清理点击缓存
  void cleanLimit() {
    setLimit(GADLimit(showTimes: 0, clickTimes: 0, date: DateTime.now()));
  }

  // 更改缓存
  Future<void> updateLimit(GADLimitPosition p) async {
    var limit = await getLimit();
    var isLimited = await isADLimited();
    if (isLimited) {
      debugPrint("[AD] limited ad");
      return;
    }
    if (p == GADLimitPosition.show) {
      limit.showTimes = (limit.showTimes ?? 0) + 1;
      limit.date = DateTime.now();
      setLimit(limit);
      debugPrint("[AD] [Limited] [show] ${limit.showTimes}");
    }
    if (p == GADLimitPosition.click) {
      limit.clickTimes = (limit.clickTimes ?? 0) + 1;
      limit.date = DateTime.now();
      setLimit(limit);
      debugPrint("[AD] [Limited] [click] ${limit.clickTimes}");
    }
  }

  Future<GADModel?> load(GADPosition position) async {
    Completer<GADModel?> completer = Completer();
    var load = adLoads.where((element) => element.position == position).first;
    load.loadCompletion = false;
    load.beginADWaterFall().then((value) {
      load.loadCompletion = true;
      completer.complete(value);
      // 发出加载完成事件通知
      if (value is GADNativeModel) {
        EventBusUtil.updateNativeAD(value);
      }
    });
    return completer.future;
  }

  Future<void> show(GADPosition position,
      {GADCloseHandler? closeHandler}) async {
    // 获取当前加载
    GADLoad loadModel = List<GADLoad>.from(
        adLoads.where((element) => element.position == position)).first;

    isADLimited().then((isADLimited) {
      if (loadModel.loadedList.isNotEmpty && !isADLimited) {
        // 插屏
        GADModel ad = loadModel.loadedList.first;

        if (position == GADPosition.interstitial) {
          isPresentingInterstitialAD = true;
        }
        // 回调
        ad.callback = GADModelCallback(impressionHandler: () {
          // 缓存展示
          updateLimit(GADLimitPosition.show);
          // 展示
          appear(position);
          // 预加载
          if (position == GADPosition.native) {
            load(position);
          }
        }, clickHandler: () {
          // 缓存点击
          updateLimit(GADLimitPosition.click);
        }, closeHandler: () {
          // 消失
          disAppear(position);
          if (closeHandler != null) {
            closeHandler();
          }
          isPresentingInterstitialAD = false;
          load(position);
        }, errorHandler: () {
          // 错误展示
          if (closeHandler != null) {
            closeHandler();
          }
          clean(position);
          if (position == GADPosition.interstitial) {
            isPresentingInterstitialAD = false;
          }
        });
        ad.present();
      } else {
        clean(GADPosition.native);
        clean(GADPosition.interstitial);
        if (closeHandler != null) {
          closeHandler();
        }
      }
    });
  }

  void appear(GADPosition position) {
    adLoads.where((element) => element.position == position).first.appear();
  }

  void disAppear(GADPosition position) {
    adLoads.where((element) => element.position == position).first.disAppear();
    if (position == GADPosition.native) {
      updateNativeAD(null);
    }
  }

  void clean(GADPosition position) {
    adLoads.where((element) => element.position == position).first.clean();
    if (position == GADPosition.native) {
      updateNativeAD(null);
    }
  }

  Future<void> requestConfig() async {
    try {
      var config = await getConfig();
      if (config.showTimes == null) {
        var data = await rootBundle.loadString('assets/data/config.json');
        config = GADConfig.fromJson(data);
        setConfig(config);
        GADProvider().load(GADPosition.interstitial);
        GADProvider().load(GADPosition.native);
        debugPrint("[Config] :${jsonEncode(config.toJson())}");
      } else {
        debugPrint("[Config] :${jsonEncode(config.toJson())}");
      }
    } catch (e) {
      debugPrint("[Config] err:$e");
    }

    /// 广告配置是否是当天的
    isNeedCleanLimit().then((isNeed) {
      if (isNeed) {
        cleanLimit();
      }
    });
  }
}
