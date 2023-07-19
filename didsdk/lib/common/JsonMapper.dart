part of didsdk;

class _JsonMapper {
  static String _getString(Map map, String key) {
    var value = map[key];
    if(value != null) {
      return value is String ? value : "$value";
    } else {
      return "";
    }
  }
  static int _getInt(Map map, String key) {
    var value = map[key];
    if(value != null) {
      return value is int ? value : value is String ? int.parse(value+"") : 0;
    }
    return 0;
  }
  static bool _getBool(Map map, String key) {
    var value = map[key];
    return value != null && value is bool ? value : false;
  }
}