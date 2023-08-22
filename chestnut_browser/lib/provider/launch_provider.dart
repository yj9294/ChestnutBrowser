import 'dart:async';

import 'package:chestnut_browser/event/event_bus_util.dart';
import 'package:chestnut_browser/gad/gad_position.dart';
import 'package:chestnut_browser/provider/gad_provider.dart';
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
    var duration = 12.4;
    progress = 0.0;
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      progress += 0.01 / duration;
      updateProgress(progress);
      if (progress >= 1.0) {
        timer.cancel();
        GADProvider().show(GADPosition.interstitial, closeHandler: () {
          EventBusUtil.updateLaunched(true);
        });
      }

      if (GADProvider().isLoadedInterstitialAD() && progress > 0.29) {
        duration = 0.5;
      }
    });

    GADProvider().load(GADPosition.native);
    GADProvider().load(GADPosition.interstitial);
  }

  void stopLaunching() {
    timer?.cancel();
  }
}
