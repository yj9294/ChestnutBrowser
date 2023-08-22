import 'dart:convert';

import './gad_position.dart';

class GADConfig {
  int? showTimes = 0;
  int? clickTimes = 0;
  List<GADConfigUnitItem>? ads;
  GADConfig.fromJson(String jsonString) {
    var json = jsonDecode(jsonString);
    showTimes = json["showTimes"];
    clickTimes = json["clickTimes"];
    ads = [];
    json["ads"]?.forEach((item) {
      ads?.add(GADConfigUnitItem.fromJson(item));
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> m = {};
    List<Map<String, dynamic>> list = [];
    m["showTimes"] = showTimes;
    m["clickTimes"] = clickTimes;
    for (var item in (ads ?? [])) {
      list.add(item.toJson());
    }
    m["ads"] = list;
    return m;
  }

  List<GADConfigItem> itemsOf(GADPosition position) {
    if (ads?.isEmpty == true || ads == null) {
      return [];
    }
    final items =  List<GADConfigUnitItem>.from(ads!.where((element) =>
    element.position ==
        position.title())).first.items;
    items!.sort((a,b) => b.p!.compareTo(a.p!));
    return items;
  }
}

class GADConfigUnitItem {
  String? position;
  List<GADConfigItem>? items;
  GADConfigUnitItem.fromJson(Map<String, dynamic> json) {
    position = json["position"];
    items = [];
    json["items"]?.forEach((item) {
      items?.add(GADConfigItem.fromJson(item));
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> m = {};
    List<Map<String, dynamic>> list = [];
    m["position"] = position;
    for (var item in (items ?? [])) {
      list.add(item.toJson());
    }
    m["items"] = list;
    return m;
  }
}

class GADConfigItem {
  int? p = 0;
  String? id = "";
  GADConfigItem(this.p, this.id);

  GADConfigItem.fromJson(Map<String, dynamic> json) {
    p = json["p"];
    id = json["id"];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> m = {};
    m["p"] = p;
    m["id"] = id;
    return m;
  }
}