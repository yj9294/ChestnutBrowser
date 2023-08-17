import 'package:chestnut_browser/provider/launch_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ProviderUtil {
  static final _shared = ProviderUtil._internal();
  factory ProviderUtil() => _shared;
  ProviderUtil._internal();

  static void updateLaunchProgress(BuildContext context, double progress) {
    Provider.of<LaunchProvider>(context, listen: false).updateProgress(progress);
  }

  static void startLaunching(BuildContext context) {
    Provider.of<LaunchProvider>(context, listen: false).startLaunching();
  }

  static void stopLaunching(BuildContext context) {
    Provider.of<LaunchProvider>(context, listen: false).stopLaunching();
  }
}