import 'dart:async';

import 'package:chestnut_browser/gad/gad_model.dart';
import 'package:event_bus/event_bus.dart';

typedef BoolHandler = void Function(bool);
typedef NativeHandler = void Function(GADNativeModel?);

class EventBusUtil {
  static final _shared = EventBusUtil._internal();
  EventBusUtil._internal();
  factory EventBusUtil() => _shared;

  // 首页是加载还是进入主页了
  late final _launchEvent = EventBus();
  late final _backgroundEvent = EventBus();
  late final _nativeAD =EventBus();

  static updateLaunched(bool isLaunched) {
    _shared._launchEvent.fire(isLaunched);
  }

  static StreamSubscription listenIsLaunched(BoolHandler f) {
    return _shared._launchEvent.on<bool>().listen((isLaunched) {
      f(isLaunched);
    });
  }

  static updateBackground(bool isBackground) {
    _shared._backgroundEvent.fire(isBackground);
  }

  static StreamSubscription listenIsBackground(BoolHandler f) {
    return _shared._backgroundEvent.on<bool>().listen((isLaunched) {
      f(isLaunched);
    });
  }

  static updateNativeAD(GADNativeModel? nativeModel) {
    _shared._nativeAD.fire(nativeModel);
  }

  static StreamSubscription listenNativeModel(NativeHandler f) {
    return _shared._nativeAD.on<GADNativeModel?>().listen((nativeModel) {
      f(nativeModel);
    });
  }
}