import 'dart:async';

import 'package:chestnut_browser/Util/colors_util.dart';
import 'package:chestnut_browser/component/background.dart';
import 'package:chestnut_browser/event/event_bus_util.dart';
import 'package:chestnut_browser/gad/gad_model.dart';
import 'package:chestnut_browser/gad/gad_position.dart';
import 'package:chestnut_browser/page/base_page_state.dart';
import 'package:chestnut_browser/provider/gad_provider.dart';
import 'package:chestnut_browser/provider/home_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef BackHandler = void Function();

class TabPage extends StatefulWidget {

  BackHandler? handler;
  TabPage({super.key, this.handler});

  @override
  State<StatefulWidget> createState() => _TabState(handler: handler);
}

class _TabState extends BasePageState {
  BackHandler? handler;
  StreamSubscription? _subscription;
  StreamSubscription? _foregroundSubscription;
  _TabState({this.handler});

  @override
  void initState() {
    super.initState();
    _refreshGAD();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _foregroundSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: _buildCenterView()),
            Column(
              children: [_buildGADView(), _buildFooterView()],
            ),
          ],
        ),
      ),
    );
  }

  @cwidget
  Widget _buildCenterView() {
    return Consumer<HomeProvider>(
        builder: (context, provider, child) => GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              childAspectRatio: 158 / 204,
              children: List<Widget>.from(provider.items.map((e) => _TabItem(
                    e,
                    select: selected,
                    delete: delete,
                  ))),
            ));
  }

  @swidget
  Widget _buildGADView() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width - 32,
      height: (MediaQuery.sizeOf(context).width - 32) * 78 / 328,
      child: Consumer<GADProvider>(
        builder: (context, provider, child) => (provider.nativeModel != null)
            ? AdWidget(ad: provider.nativeModel!.ad!)
            : const Center(),
      ),
    );
  }

  @swidget
  Widget _buildFooterView() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CupertinoButton(
            onPressed: add,
            padding: EdgeInsets.zero,
            child: Image.asset('assets/images/tab_add.png')),
        Row(
          children: [
            const Flexible(child: Center()),
            CupertinoButton(onPressed: goBack, child: const Text('Back'))
          ],
        )
      ],
    );
  }
}

typedef _TabDeleteHandle = void Function(BrowserItem item);
typedef _TabSelectedHandle = void Function(BrowserItem item);

class _TabItem extends StatefulWidget {
  final BrowserItem item;
  final _TabDeleteHandle? delete;
  final _TabSelectedHandle? select;

  const _TabItem(this.item, {this.delete, this.select});

  @override
  State<StatefulWidget> createState() =>
      _TabItemState(item, delete: delete, select: select);
}

class _TabItemState extends State<_TabItem> {
  final BrowserItem item;
  final _TabDeleteHandle? delete;
  final _TabSelectedHandle? select;

  _TabItemState(this.item, {this.delete, this.select});

  String title = "";
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    setTitleState();
  }

  void setTitleState() async {
    final title = await item.controller.currentUrl() ?? "Navigation";
    setState(() {
      this.title = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          _buildCenterView(item, select),
          HomeProvider().items.length <= 1
              ? const Center()
              : _buildDeleteButton(item, delete)
        ],
      ),
    );
  }

  @cwidget
  Widget _buildCenterView(BrowserItem item, _TabSelectedHandle? select) {
    return CupertinoButton(
        onPressed: () {
          if (select != null) {
            select(item);
          }
        },
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Container(
              color: item.isSelect ? ColorsUtil("#FE7B00") : Colors.white,
            ),
            Center(
              child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14.0),
                  )),
            )
          ],
        ));
  }

  @cwidget
  Widget _buildDeleteButton(BrowserItem item, _TabSelectedHandle? delete) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Center(),
        Column(
          children: [
            CupertinoButton(
              onPressed: () {
                if (delete != null) {
                  delete(item);
                }
              },
              child: Image.asset("assets/images/tab_delete.png"),
            ),
          ],
        )
      ],
    );
  }
}

extension _TabStateExt on _TabState {
  void _refreshGAD() {
    _adObserver();
    GADProvider().load(GADPosition.native);
  }

  bool _isNeedShowNative() {
    return DateTime.now()
            .difference(GADProvider().tabImpressionDate)
            .inSeconds >
        10;
  }

  void _adObserver() {
    _subscription?.cancel();
    _subscription = EventBusUtil.listenNativeModel((model) {
      GADProvider().show(GADPosition.native);
      if (!_isNeedShowNative() || GADProvider().nativeModel == model) {
        debugPrint("[AD] tab 原生广告10s展示间隔 或 预加载的数据");
        return;
      }
      debugPrint("[AD] tab当前显示的tab广告ID${model?.ad?.responseInfo?.responseId}");
      GADProvider().tabImpressionDate = DateTime.now();
      GADProvider().updateNativeAD(model);
    });

    _foregroundSubscription = EventBusUtil.listenIsBackground((event) {
      Navigator.pop(context);
    });
  }

  void goBack() {
    if (handler != null) {
      handler!();
    }
    _subscription?.cancel();
    GADProvider().disAppear(GADPosition.native);
    GADProvider().updateNativeAD(null);
    Navigator.pop(context);
  }

  void delete(BrowserItem item) {
    HomeProvider().removeItem(item);
  }

  void selected(BrowserItem item) {
    HomeProvider().selected(item);
    goBack();
  }

  void add() {
    HomeProvider().addItems();
    goBack();
  }
}
