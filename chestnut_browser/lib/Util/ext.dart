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
When you use this browser to search for information, access websites, and share information with others, such as typing keywords through the browser and viewing relevant information on the internet, we will collect information from you in order to provide you with corresponding services and a better user experience. When participating in the browser user experience improvement program, your usage, statistical information, certain information entered while using the browser and explorer, and crash reports will be collected as appropriate.
Here, we explain the information we collect, why we collect it, and how we will use it:
Information Collection and Use
We collect information to improve our application and provide better services to all users, including:
1. The information you provided us. For example, when you provide us with your feedback on our applications and services through our feedback channels;
2. We have obtained information from your use of our applications and services. For example, the search keywords you enter in our application, the website links you enter, click on, and interact with;
3. Log information, application events. For example, version, installation date and time, usage statistics, crash events, and application dump reports;
4. Location information;
5. Equipment information. For example, hardware model, operating system version, etc.
How we share information
We will not sell, trade, or otherwise transfer your personally identifiable information to the outside world. This does not include:
1. Trusted third parties who assist us in operating our website, conducting business, or providing services to you, as long as these third parties agree to keep this information confidential;
2. We will access, use, or disclose your information in conjunction with other organizations or entities for any applicable laws, regulations, legal procedures, or enforceable government requirements;
3. Government requirements.
We will protect the rights, property, and safety of our users or the public from harm, as required or permitted by law.
Update 
We may update our privacy policy from time to time, and we suggest that you regularly review this privacy policy to understand any changes made.
Contact us
If you have any questions about this policy, you can contact our support team via the email below.
123Brycee@gmail.com

Terms of Use
Please read these usage terms in detail.
Use of the application
You acknowledge that you may not use this application for illegal purposes;
You agree that we can stop the service at any time without prior notice to you;
You accept the use of our application according to these terms. If you refuse these terms, please do not use our services.
Update
We may update our terms of use from time to time, and we suggest that you regularly check if there have been any changes to these terms of use.
Contact us
If you have any questions about these Terms of Use, please contact us：123Brycee@gmail.com
""";
      case WebItem.terms:
        return """
Please read these usage terms in detail.
Use of the application
You acknowledge that you may not use this application for illegal purposes;
You agree that we can stop the service at any time without prior notice to you;
You accept the use of our application according to these terms. If you refuse these terms, please do not use our services.
Update
We may update our terms of use from time to time, and we suggest that you regularly check if there have been any changes to these terms of use.
Contact us
If you have any questions about these Terms of Use, please contact us：123Brycee@gmail.com
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
