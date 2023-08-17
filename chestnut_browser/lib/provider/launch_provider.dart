import 'dart:async';

import 'package:chestnut_browser/event/event_bus_util.dart';
import 'package:flutter/cupertino.dart';

class LaunchProvider extends ChangeNotifier {
  var progress = 0.0;
  Timer? timer;

  void updateProgress(double progress) {
    if (progress < 0.0) {
      progress = 0.0;
    }
    if (progress >= 1.0) {
      progress = 1.0;
    }
    this.progress = progress;
    notifyListeners();
  }

  void startLaunching() {
    const duration = 2.4;
    progress = 0.0;
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      progress += 0.01 / duration;
      updateProgress(progress);
      if (progress >= 1.0) {
        timer.cancel();
        EventBusUtil.updateLaunched(true);
      }
    });

  }

  void stopLaunching() {
    timer?.cancel();
  }
}
