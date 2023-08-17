import 'dart:async';

import 'package:chestnut_browser/Util/ext.dart';
import 'package:chestnut_browser/component/background.dart';
import 'package:chestnut_browser/event/event_bus_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WebPage extends StatefulWidget {
  final WebItem item;

  const WebPage(this.item, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _WebState(item);
  }
}

class _WebState extends State<WebPage> {
  WebItem item;
  StreamSubscription? _subscription;

  _WebState(this.item);

  @override
  void initState() {
    super.initState();
    _subscription = EventBusUtil.listenIsBackground((isBackground) {
      if(!isBackground) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      appbar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(item.title, style: const TextStyle(fontSize: 18,
            fontWeight: FontWeight.bold),),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [Text(item.body)],
      ),
    );
  }
}
