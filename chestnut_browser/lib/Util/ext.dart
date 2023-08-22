import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool isUrl() {
    RegExp exp = RegExp('[a-zA-z]+://.*');
    return exp.hasMatch(this);
  }
}

extension DateTimeExt on DateTime {
  bool isExpired() {
    var difference = DateTime.now().difference(this);
    return difference.inSeconds > 3000;
  }

  bool isToday() {
    return day == DateTime.now().day;
  }
}

enum HomeItemType {
  facebook,
  google,
  instagram,
  youtube,
  amazon,
  gmail,
  yahoo,
  twitter
}

extension HomeItemTypeExtension on HomeItemType {
  String get name => describeEnum(this);

  String get url {
    return 'https://www.${describeEnum(this)}.com';
  }

  String get displayTitle {
    return describeEnum(this).capitalize();
  }

  String get displayImage {
    return 'assets/images/${describeEnum(this)}.png';
  }

  String describeEnum(Object enumEntry) {
    final String description = enumEntry.toString();
    final int indexOfDot = description.indexOf('.');
    assert(indexOfDot != -1 && indexOfDot < description.length - 1);
    return description.substring(indexOfDot + 1);
  }
}

enum TabBarItem { back, forward, clean, tab, setting }

extension TabBarItemExt on TabBarItem {
  String get displayImage {
    return 'assets/images/${describeEnum(this)}.png';
  }

  String get selectedImage {
    return 'assets/images/${describeEnum(this)}_1.png';
  }

  String describeEnum(Object enumEntry) {
    final String description = enumEntry.toString();
    final int indexOfDot = description.indexOf('.');
    assert(indexOfDot != -1 && indexOfDot < description.length - 1);
    return description.substring(indexOfDot + 1);
  }
}

enum SettingItem { add, share, copy, rate, terms, privacy }

extension SettingItemExt on SettingItem {
  String describeEnum(Object enumEntry) {
    final String description = enumEntry.toString();
    final int indexOfDot = description.indexOf('.');
    assert(indexOfDot != -1 && indexOfDot < description.length - 1);
    return description.substring(indexOfDot + 1);
  }

  String get title {
    switch (describeEnum(this)) {
      case 'rate':
        return "Rate Us";
      case 'terms':
        return "Terms of Users";
      case 'privacy':
        return "Privacy Policy";
      case 'add':
        return "New";
      default:
        return describeEnum(this).capitalize();
    }
  }

  String get image {
    return "assets/images/${describeEnum(this)}.png";
  }
}

enum WebItem { privacy, terms }

extension WebItemExt on WebItem {
  String get title {
    switch (this) {
      case WebItem.privacy:
        return "Privacy Policy";
      case WebItem.terms:
        return "Terms of Users";
    }
  }

  String get body {
    switch (this) {
      case WebItem.privacy:
        return """
        The following terms and conditions (the “Terms”) govern your use of the VPN services we provide (the “Service”) and their associated website domains (the “Site”). These Terms constitute a legally binding agreement (the “Agreement”) between you and Tap VPN. (the “Tap VPN”).

Activation of your account constitutes your agreement to be bound by the Terms and a representation that you are at least eighteen (18) years of age, and that the registration information you have provided is accurate and complete.

Tap VPN may update the Terms from time to time without notice. Any changes in the Terms will be incorporated into a revised Agreement that we will post on the Site. Unless otherwise specified, such changes shall be effective when they are posted. If we make material changes to these Terms, we will aim to notify you via email or when you log in at our Site.

By using Tap VPN
You agree to comply with all applicable laws and regulations in connection with your use of this service.regulations in connection with your use of this service.
 """;
      case WebItem.terms:
        return """
        The following terms and conditions (the “Terms”) govern your use of the VPN services we provide (the “Service”) and their associated website domains (the “Site”). These Terms constitute a legally binding agreement (the “Agreement”) between you and Tap VPN. (the “Tap VPN”).

Activation of your account constitutes your agreement to be bound by the Terms and a representation that you are at least eighteen (18) years of age, and that the registration information you have provided is accurate and complete.

Tap VPN may update the Terms from time to time without notice. Any changes in the Terms will be incorporated into a revised Agreement that we will post on the Site. Unless otherwise specified, such changes shall be effective when they are posted. If we make material changes to these Terms, we will aim to notify you via email or when you log in at our Site.

By using Tap VPN
You agree to comply with all applicable laws and regulations in connection with your use of this service.regulations in connection with your use of this service.
        """;
    }
  }
}

class TransformPageRoute extends PageRoute {
  final WidgetBuilder builder;

  TransformPageRoute(this.builder);

  @override
  String? get barrierLabel => null;

  @override
  // TODO: implement opaque
  bool get opaque => false;

  @override
  // TODO: implement maintainState
  bool get maintainState => true;

  @override
  // TODO: implement transitionDuration
  Duration get transitionDuration => const Duration(milliseconds: 0);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Title(
        color: Theme.of(context).primaryColor, child: builder(context));
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }

  @override
  // TODO: implement barrierColor
  Color? get barrierColor => null;
}
