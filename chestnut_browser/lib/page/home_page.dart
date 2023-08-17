import 'package:chestnut_browser/Util/colors_util.dart';
import 'package:chestnut_browser/Util/ext.dart';
import 'package:chestnut_browser/component/background.dart';
import 'package:chestnut_browser/page/base_page_state.dart';
import 'package:chestnut_browser/page/clean_alert.dart';
import 'package:chestnut_browser/page/setting_page.dart';
import 'package:chestnut_browser/page/tab_page.dart';
import 'package:chestnut_browser/provider/home_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends BasePageState {
  TextEditingController? textEditingController;
  WebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    HomeProvider().addListener(() {
      textEditingController?.text = HomeProvider().searchText;
    });
    refreshWebView();
  }

  @override
  void dispose() {
    textEditingController = null;
    webViewController = null;
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    refreshWebView();
    refreshSearchView();
  }

  @override
  void didPushNext() {
    super.didPushNext();
    disposeState();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildSearchView(), _buildCenterView(), _buildTabBar()],
      ),
    );
  }

  @cwidget
  Widget _buildSearchView() {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 28, right: 28),
      child: Column(
        children: [
          Container(
              height: 56,
              padding: const EdgeInsets.only(top: 18, bottom: 18, left: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28), color: Colors.white),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Flexible(
                    child: TextField(
                  controller: textEditingController,
                  style: const TextStyle(fontSize: 14),
                  onSubmitted: (_) => load(),
                  decoration: const InputDecoration.collapsed(
                      hintText: "Search or enter an address"),
                )),
                CupertinoButton(
                  onPressed: searchClick,
                  padding: EdgeInsets.zero,
                  child: Consumer<HomeProvider>(
                    builder: (context, provider, child) {
                      return Image.asset(
                        !provider.isLoading
                            ? "assets/image"
                                "s/search.png"
                            : "assets/image"
                                "s/tab_delete.png",
                        width: 20,
                        height: 20,
                      );
                    },
                  ),
                ),
              ])),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Consumer<HomeProvider>(builder: (context, provider, child) {
              return provider.isLoading
                  ? LinearProgressIndicator(
                      value: provider.progress,
                      borderRadius: BorderRadius.circular(2),
                      color: ColorsUtil("#FE7B00"),
                      backgroundColor: ColorsUtil("#000000", alpha: 0.2),
                    )
                  : const Center();
            }),
          )
        ],
      ),
    );
  }

  @swidget
  Widget _buildCenterView() {
    return Flexible(
        child: Consumer<HomeProvider>(builder: (context, provider, child) {
      return provider.isNavigation
          ? Column(
              children: [
                GridView.count(
                  crossAxisCount: 4,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  childAspectRatio: 90.0 / 87.0,
                  children: List<Widget>.from(
                      HomeItemType.values.map((e) => _buildHomeItem(e))),
                ),
                const Center(),
              ],
            )
          : WebViewWidget(controller: webViewController!);
    }));
  }

  // 图标Item
  Widget _buildHomeItem(HomeItemType item) {
    return MaterialButton(
        onPressed: () => navigationClick(item),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(item.displayImage),
            Container(
              padding: const EdgeInsets.only(top: 9),
              child: Text(item.displayTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
        ));
  }

  @swidget
  Widget _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          List<Widget>.from(TabBarItem.values.map((e) => _buildTabBarItem(e))),
    );
  }

  @cwidget
  Widget _buildTabBarItem(TabBarItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: CupertinoButton(
        onPressed: () => didSelectedTabBar(item),
        padding: EdgeInsets.zero,
        child: Consumer<HomeProvider>(builder: (context, provider, child) {
          return Stack(alignment: Alignment.center, children: [
            _buildItemImage(context, item),
            Text(
              item == TabBarItem.tab ? "${provider.items.length}" : "",
              style: const TextStyle(color: Colors.black, fontSize: 12.0),
            )
          ]);
        }),
      ),
    );
  }

  @cwidget
  Widget _buildItemImage(BuildContext context, TabBarItem item) {
    switch (item) {
      case TabBarItem.forward:
      case TabBarItem.back:
        return Consumer<HomeProvider>(builder: (context, provider, child) {
          return Image.asset(provider.canGoBack || provider.canGoForward
              ? item.selectedImage
              : item.displayImage);
        });
      default:
        return Image.asset(item.displayImage);
    }
  }
}

extension _HomePageExt on _HomeState {
  void refreshWebView() {
    final homeProvider = HomeProvider();
    webViewController = homeProvider.controller;
    webViewController
        ?.setNavigationDelegate(NavigationDelegate(onPageStarted: (url) {
      homeProvider.updateIsLoading(true);
      homeProvider.updateSearchText(url);
    }, onPageFinished: (url) {
      homeProvider.updateIsLoading(false);
      homeProvider.updateIsNavigation(url.isEmpty == true);
    }, onProgress: (progress) {
      debugPrint("$progress");
      webViewController
          ?.canGoForward()
          .then((value) => homeProvider.updateCanGoForward(value));
      webViewController
          ?.canGoBack()
          .then((value) => homeProvider.updateCanGoBack(value));
      homeProvider.updateProgress(progress / 100);
      homeProvider.updateIsLoading(progress != 0 && progress != 100);
    }, onUrlChange: (url) {
      homeProvider.updateSearchText(url.url ?? "");
    }));
    webViewController?.currentUrl().then((value) {
      homeProvider.updateSearchText(value ?? "");
      homeProvider.updateIsNavigation(value?.isEmpty != false);
    });
  }

  void refreshSearchView () {
    final homeProvider = HomeProvider();
    homeProvider.updateSearchText("");
    homeProvider.updateIsLoading(false);
  }

  void disposeState() {
    final homeProvider = HomeProvider();

    webViewController = homeProvider.controller;
    webViewController?.setNavigationDelegate(NavigationDelegate());
  }

  bool load() {
    if (textEditingController?.text == null ||
        textEditingController!.text.isEmpty) {
      return false;
    }
    _search(textEditingController!.text);
    return true;
  }

  void _search(String url) {
    if (url.isUrl()) {
      var uri = Uri.parse(url);
      webViewController?.loadRequest(uri);
    } else {
      url = 'https://www.google.com/search?q=$url';
      _search(url);
    }
  }

  void navigationClick(HomeItemType item) {
    textEditingController?.text = item.url;
    _search(item.url);
  }

  void searchClick() {
    if (!HomeProvider().isLoading) {
      if (load()) {
        HomeProvider().updateIsLoading(true);
      }
    } else {
      HomeProvider().updateIsLoading(false);
      webViewController?.runJavaScript('window.stop();').then((_) {
        webViewController?.currentUrl().then((value) {
          if (value != null && value.isNotEmpty) {
            HomeProvider().updateIsNavigation(false);
          } else {
            HomeProvider().updateIsNavigation(true);
          }
        });
      });
    }
  }

  void didSelectedTabBar(TabBarItem item) {
    switch (item) {
      case TabBarItem.back:
        webViewController?.goBack();
      case TabBarItem.forward:
        webViewController?.goForward();
      case TabBarItem.clean:
        Navigator.push(context, TransformPageRoute((context) => CleanAlertPage()));
      case TabBarItem.tab:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const TabPage()));
      case TabBarItem.setting:
        Navigator.push(context, TransformPageRoute((context) => SettingPage()));
    }
  }
}
