import 'dart:async';

import 'package:event_bus/event_bus.dart';

typedef BoolHandler = void Function(bool);

class EventBusUtil {
  static final _shared = EventBusUtil._internal();
  EventBusUtil._internal();
  factory EventBusUtil() => _shared;

  // 首页是加载还是进入主页了
  late final _launchEvent = EventBus();
  late final _backgroundEvent = EventBus();

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
}