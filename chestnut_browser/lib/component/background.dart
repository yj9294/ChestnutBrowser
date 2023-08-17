import 'package:chestnut_browser/Util/colors_util.dart';
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget? child;
  final PreferredSizeWidget? appbar;

  const Background({super.key, this.appbar, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [ColorsUtil("#FFD289"), ColorsUtil("#FFF7EB")],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
        ),
        SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: appbar ??
                PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: AppBar(),
                ),
            body: child ?? const Center(),
          ),
        )
      ],
    );
  }
}
