import '../Util/colors_util.dart';
import '../component//background.dart';
import '../page/base_page_state.dart';
import '../provider/launch_provider.dart';
import '../provider/provider_util.dart';

import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:provider/provider.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<StatefulWidget> createState() => _LaunchState();
}

class _LaunchState extends BasePageState {
  @override
  void initState() {
    super.initState();
    ProviderUtil.startLaunching(context);
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _contentView(),
          Consumer<LaunchProvider>(builder: (context, pro, ch8ild) {
            return _progressView(pro.progress);
          }),
        ],
      ),
    );
  }

  @swidget
  Widget _contentView() {
    return Container(
        padding: const EdgeInsets.only(top: 132),
        child: Column(children: [
          Image.asset("assets/images/launch_icon.png"),
          Container(
              padding: const EdgeInsets.only(top: 27),
              child: Image.asset("assets/images/launch_title.png"))
        ]));
  }

  @cwidget
  Widget _progressView(double progress) {
    return Container(
        padding: const EdgeInsets.only(left: 70, right: 70, bottom: 40),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
                value: progress,
                color: ColorsUtil("#FAB231"),
                backgroundColor: ColorsUtil("#F9861E", alpha: 0.1))));
  }
}
