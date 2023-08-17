import 'dart:async';

import 'package:chestnut_browser/Util/colors_util.dart';
import 'package:chestnut_browser/Util/ext.dart';
import 'package:chestnut_browser/event/event_bus_util.dart';
import 'package:chestnut_browser/page/base_page_state.dart';
import 'package:chestnut_browser/page/clean_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

class CleanAlertPage extends StatefulWidget {
  const CleanAlertPage({super.key});
  @override
  State<StatefulWidget> createState() => _CleanAlertState();
}

class _CleanAlertState extends BasePageState {
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = EventBusUtil.listenIsBackground((isBackground) {
      if (!isBackground) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ColorsUtil("#000000", alpha: 0.65)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
              child: GestureDetector(onTap: () => Navigator.pop(context))),
          _buildContentView(),
        ],
      ),
    );
  }

  @cwidget
  Widget _buildContentView() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white
      ),
      height: 240,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Image.asset("assets/images/clean_alert.png", width: 61, height: 80,),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              "Close Tabs and Clear Data",
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.normal),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20, top: 20),
            child: CupertinoButton(
              onPressed: goClean,
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Container(
                padding: const EdgeInsets.only(
                    top: 14, bottom: 14, left: 70, right: 70),
                decoration: BoxDecoration(
                    color: ColorsUtil("#7C3F29"),
                    borderRadius: BorderRadius.circular(22)),
                child: const Text("Confirm",
                    style: TextStyle(fontSize: 14.0, color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }

  void goClean() {
    Navigator.pop(context);
    Navigator.push(context, TransformPageRoute((context) => CleanPage()));
  }
}
