import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  late final SharedPreferences prefs;

  Future<void> init() async {
    prefs = await .getInstance();
  }

  //* Getter
  String? getString(String key) => prefs.getString(key);
  bool? getBool(String key) => prefs.getBool(key);
  List? getStringList(String key) => prefs.getStringList(key);
  double? getDouble(String key) => prefs.getDouble(key);

  //* Setter
  Future<bool> setBool(String key, bool value) async =>
      await prefs.setBool(key, value);

  Future<bool> setString(String key, String value) async =>
      await prefs.setString(key, value);

  //* Clear
  Future<bool> clear() async => await prefs.clear();
  Future<bool> remove(String key) async => await prefs.remove(key);
}
