import 'package:chestnut_browser/main.dart';
import 'package:flutter/cupertino.dart';

abstract class BasePageState<T extends StatefulWidget> extends State<T> with
    RouteAware  {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    debugPrint("$widget dispose 💧💧💧💧");
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    debugPrint("$widget init 🔥🔥🔥🔥");
  }

  @override
  void didPopNext() {
    super.didPopNext();
    debugPrint("$widget appear ✅✅✅✅");
  }

  @override
  void didPush() {
    super.didPush();
    debugPrint("$widget appear ✅✅✅✅");
  }

  @override
  void didPop() {
    super.didPop();
    debugPrint("$widget disappear ❌❌❌❌");
  }

  @override
  void didPushNext() {
    super.didPushNext();
    debugPrint("$widget disappear ❌❌❌❌");
  }
}