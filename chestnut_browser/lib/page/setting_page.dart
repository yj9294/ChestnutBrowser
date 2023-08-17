import 'dart:async';

import 'package:chestnut_browser/Util/colors_util.dart';
import 'package:chestnut_browser/Util/ext.dart';
import 'package:chestnut_browser/component/background.dart';
import 'package:chestnut_browser/event/event_bus_util.dart';
import 'package:chestnut_browser/page/base_page_state.dart';
import 'package:chestnut_browser/page/web_page.dart';
import 'package:chestnut_browser/provider/home_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share/share.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  @override
  State<StatefulWidget> createState() => _SettingState();
}

class _SettingState extends BasePageState {

  late StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription = EventBusUtil.listenIsBackground((isBackground) {
      if (!isBackground) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ColorsUtil("#000000", alpha: 0.65)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Colors.transparent,
                  ))),
          _buildContentView()
        ],
      ),
    );
  }

  @swidget
  Widget _buildContentView() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
                colors: [ColorsUtil("#FFD289"), ColorsUtil("#FFFFFF")],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          childAspectRatio: 114.0 / 94.0,
          children: List<Widget>.from(
              SettingItem.values.map((e) => _buildSettingItem(e))),
        ),
      ),
    );
  }

  @cwidget
  Widget _buildSettingItem(SettingItem item) {
    return CupertinoButton(
      onPressed: () => selected(item),
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.only(top: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(item.image),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                item.title,
                style: const TextStyle(fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }

  void selected(SettingItem item) {
    switch (item) {
      case SettingItem.add:
        HomeProvider().addItems();
        Navigator.pop(context);
      case SettingItem.share:
        Navigator.pop(context);
        HomeProvider().controller.currentUrl().then((value) {
          if (value != null) {
            if (value.isEmpty == true) {
              Share.share("https://itunes.apple.com/cn/app/id}");
            } else {
              Share.share(value);
            }
          } else {
            Share.share("https://itunes.apple.com/cn/app/id}");
          }
        });
      case SettingItem.copy:
        Navigator.pop(context);
        HomeProvider().controller.currentUrl().then((value) {
          Clipboard.setData(ClipboardData(text: value ?? ""));
        });
      case SettingItem.rate:
        Navigator.pop(context);
        LaunchReview.launch(iOSAppId: "");
      case SettingItem.terms:
        Navigator.pop(context);
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => const WebPage(WebItem.terms)));
      case SettingItem.privacy:
        Navigator.pop(context);
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => const WebPage(WebItem.privacy)));
    }
  }
}
