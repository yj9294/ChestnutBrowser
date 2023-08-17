import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:chestnut_browser/event/event_bus_util.dart';
import 'package:chestnut_browser/page/base_page_state.dart';
import 'package:chestnut_browser/page/home_page.dart';
import 'package:chestnut_browser/page/launch_page.dart';
import 'package:chestnut_browser/provider/home_provider.dart';
import 'package:chestnut_browser/provider/launch_provider.dart';
import 'package:chestnut_browser/provider/provider_util.dart';
import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:provider/provider.dart';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  final app = MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => LaunchProvider()),
    ChangeNotifierProvider(create: (context) => HomeProvider()),
  ], child: const MyApp());
  runApp(app);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription? _subscription;
  var isLaunching = true;

  @override
  void initState() {
    super.initState();

    // att alert
    AppTrackingTransparency.requestTrackingAuthorization();

    // app life cycle
    WidgetsBinding.instance.addObserver(this);

    // listen launch status
    _subscription = EventBusUtil.listenIsLaunched((isLaunched) {
      setState(() {
        isLaunching = !isLaunched;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("active");
        ProviderUtil.startLaunching(context);
        EventBusUtil.updateBackground(false);
      case AppLifecycleState.inactive:
        EventBusUtil.updateLaunched(false);
        EventBusUtil.updateBackground(true);
        debugPrint("inActive");
      case AppLifecycleState.detached:
        debugPrint("detached");
      case AppLifecycleState.hidden:
        debugPrint("hidden");
      case AppLifecycleState.paused:
        debugPrint("hold");
        ProviderUtil.stopLaunching(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorObservers: [routeObserver],
        home: isLaunching ? const LaunchPage() : const HomePage());
  }
}
