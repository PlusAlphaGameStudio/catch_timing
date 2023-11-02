import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordModel extends ChangeNotifier {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<int> getInt(String key) async {
    await init();
    return (_prefs!.getInt(key)) ?? 0;
  }

  Future<void> setInt(String key, int value) async {
    await init();
    _prefs!.setInt(key, value);
    notifyListeners();
  }
}
