import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  SharedPrefService._privateConstructor();

  static final SharedPrefService instance = SharedPrefService._privateConstructor();

  Future<bool> checkPrefKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  Future<String?>? getPrefStringValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  setPrefStringValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<bool> getPrefBoolValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? true;
  }

  setPrefBoolValue(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<int?>? getPrefIntValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  setPrefIntValue(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  Future<double?>? getPrefDoubleValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  setPrefDoubleValue(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(key, value);
  }

  Future<List<String>?>? getPrefListValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  setPrefListValue(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, value);
  }

  Future<Set<String>> getPrefKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys();
  }

  removePrefValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
