
import 'dart:async';

import 'package:chestnut_browser/Util/ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeProvider extends ChangeNotifier {
  static final shared =  HomeProvider._internal();
  factory HomeProvider() => shared;
  HomeProvider._internal();

  var searchText = "";
  var isLoading = false;
  var progress = 0.0;
  var canGoBack = false;
  var canGoForward = false;
  var isNavigation = true;
  var items = [BrowserItem.navigation()];

  updateProgress(double progress) {
    this.progress = progress;
    notifyListeners();
  }

  updateIsLoading(bool isLoading) {
    this.isLoading = isLoading;
    notifyListeners();
  }

  updateSearchText(String searchText) {
    this.searchText = searchText;
    notifyListeners();
  }

  updateCanGoBack(bool canGoBack) {
    this.canGoBack = canGoBack;
    notifyListeners();
  }

  updateCanGoForward(bool canGoForward) {
    this.canGoForward = canGoForward;
    notifyListeners();
  }

  updateIsNavigation(bool isNavigation) {
    this.isNavigation = isNavigation;
    notifyListeners();
  }

  addItems() {
    for (var ele in items) {
      ele.isSelect = false;
    }
    items.insert(0, BrowserItem.navigation());
    notifyListeners();
  }

  removeItem(BrowserItem item) {
    if (item.isSelect) {
      items = List<BrowserItem>.from(items.where((element) => element != item));
      items.first.isSelect = true;
    } else {
      items = List<BrowserItem>.from(items.where((element) => element != item));
    }
    notifyListeners();
  }

  selected(BrowserItem item) {
    for (var ele in items) {
      ele.isSelect = false;
    }
    item.isSelect = true;
    notifyListeners();
  }

  clean() {
    items = [BrowserItem.navigation()];
    notifyListeners();
  }
}

extension HomeProviderExt on HomeProvider {
  BrowserItem get item {
    return List<BrowserItem>.from(items.where((element) =>  element.isSelect)
    ).first;
  }

  WebViewController get controller {
    return item.controller;
  }

  Future<bool> get isNavigation {
    return item.isNavigation;
  }
}


class BrowserItem {

  WebViewController controller;
  var isSelect = true;

  Future<bool> get isNavigation async {
    String? url = await controller.currentUrl();
    return url == null || url.isEmpty == true;
  }

  bool getNavigation() {
    bool ret = false;
    controller.currentUrl().then((url) {
      ret = url == null || url.isEmpty == true;
    });
    return ret;
  }

  Future<String> get url async {
    String? url = await controller.currentUrl();
    return url ?? "";
  }

  BrowserItem(this.controller);

  BrowserItem.navigation() : controller = WebViewController();

  // 加载url
  void loadUrl(String url) {
    if (url.isUrl()) {
      var uri = Uri.parse(url);
      controller.loadRequest(uri);
    } else {
      url = 'https://www.google.com/search?q=$url';
      loadUrl(url);
    }
  }

  void stopLoad() {
    controller.runJavaScript('window.stop();');
  }
}