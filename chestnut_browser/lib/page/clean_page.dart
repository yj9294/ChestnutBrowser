import 'dart:async';
import 'dart:ffi';

import 'package:chestnut_browser/component/background.dart';
import 'package:chestnut_browser/event/event_bus_util.dart';
import 'package:chestnut_browser/gad/gad_position.dart';
import 'package:chestnut_browser/page/base_page_state.dart';
import 'package:chestnut_browser/provider/gad_provider.dart';
import 'package:chestnut_browser/provider/home_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CleanPage extends StatefulWidget {
  const CleanPage({super.key});

  @override
  State<StatefulWidget> createState() => _CleanState();
}

class _CleanState extends BasePageState with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late StreamSubscription _subscription;
  late Animation<double> _animation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _subscription = EventBusUtil.listenIsBackground((isBackground) {
      if (!isBackground) {
        _timer?.cancel();
        Navigator.pop(context);
      } else  {
        _timer?.cancel();
      }
    });
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2)
        )..addListener(() {
          if (_animationController.isCompleted) {
            _animationController.forward(from: 0);
          }
        });
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate
      (_animationController);
    _animationController.forward();

    var progress = 0.0;
    var duration = 13.5;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      progress += 0.01 / duration;
      debugPrint("$progress");
      if (progress >= 1.0) {
        timer.cancel();
        if (GADProvider().isLoadedInterstitialAD() && GADProvider().hasInterstitialAD()) {
          debugPrint("没返回");
          GADProvider().show(GADPosition.interstitial, closeHandler: () {
            HomeProvider().clean();
            // Navigator.pop(context);
          });
        } else {
          debugPrint("返回");
          HomeProvider().clean();
          Navigator.pop(context);
        }
      }

      if (GADProvider().isLoadedInterstitialAD() && progress > 0.2) {
        duration = 0.5;
      }
    });

    GADProvider().load(GADPosition.interstitial);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                RotationTransition(
                  turns: _animation,
                  child: Image.asset("assets/images/clean_1.png"),
                ),
                Image.asset("assets/images/clean_2.png")
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 105),
              child: Text("Cleaning..."),
            )
          ],
        ),
      ),
    );
  }
}
