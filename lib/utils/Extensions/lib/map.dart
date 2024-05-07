extension MapExt on Map {
  void removeEmptyKeys() {
    removeWhere((key, value) => value.isEmpty || value == "" || value == null);
  }

  dynamic get(dynamic key) {
    return this[key];
  }
}

extension ListExt on List<Map> {
  Map findByKey(dynamic key, {dynamic equals}) {
    return where((element) {
      return element[key] == equals;
    }).first;
  }

  List query(String q) {
    String compareVersion = "";
    String comparableKey = "";
    String returnableKey = "";
    String comparableWithKey = "";
    List<String>? keySplit;
    // "GET `name` where `id` = `0`";

    List<String> split = q.split(" ");
    if (q.startsWith('GET')) {
      if (split[1].startsWith("`") && split[1].endsWith("`")) {
        returnableKey = split[1].replaceAll("`", "");

        if (split[2] == "where") {
          if (split[3].startsWith("`") && split[3].endsWith("`")) {
            comparableKey = split[3].replaceAll("`", "");
            if (comparableKey.contains(".")) {
              keySplit = comparableKey.split(".");
            }
          }
          if (split[4] == "=") {
            compareVersion = "eq";
          }
          if (split[4] == ">") {
            compareVersion = "gt";
          }
          if (split[5].startsWith("`") && split[5].endsWith("`")) {
            comparableWithKey = split[5].replaceAll("`", "");
          }
          if (compareVersion == "eq") {
            return where((element) {
              element['obj']['isPrivate'];

              return element[comparableKey] == comparableWithKey;
            }).toList().map((e) => e[returnableKey]).toList();
          }
          if (compareVersion == "gt") {
            if (returnableKey == "*") {
              var list = where((element) {
                return element[comparableKey] > int.parse(comparableWithKey);
              }).toList();
              return list;
            }

            return where((element) {
              return element[comparableKey] > int.parse(comparableWithKey);
            }).toList().map((e) => e[returnableKey]).toList();
          }
        }
      }
    }
    return [];
  }
}
