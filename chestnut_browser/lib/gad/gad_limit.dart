import 'dart:convert';

class GADLimit {
  int? showTimes;
  int? clickTimes;
  DateTime? date = DateTime.now();

  GADLimit({this.showTimes, this.clickTimes, this.date});

  GADLimit.fromJsonString(String jsonString) {
    var json = jsonDecode(jsonString);
    showTimes = json["showTimes"];
    clickTimes = json["clickTimes"];
    date = DateTime.parse(json["date"] ?? DateTime.now().toString());
  }

  String toJsonString() {
    Map<String, dynamic> m = {};
    m["showTimes"] = showTimes;
    m["clickTimes"] = clickTimes;
    m["date"] = date.toString();
    return jsonEncode(m);
  }
}

enum GADLimitPosition {
  show, click
}