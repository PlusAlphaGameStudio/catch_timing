import 'package:catch_timing/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordModel extends ChangeNotifier {
  SharedPreferences? _prefs;

  bool? get inited => _inited;
  bool? _inited;

  Future<void> tryInit() async {
    if (inited != null) {
      return;
    }

    _prefs = await SharedPreferences.getInstance();
    _inited = true;
    notifyListeners();
  }

  int getInt(String key) {
    return (_prefs!.getInt(key)) ?? 0;
  }

  Future<void> setInt(String key, int value) async {
    await _prefs!.setInt(key, value);
    notifyListeners();
  }
}

class ResourceModel extends ChangeNotifier {
  bool? get inited => _inited;
  bool? _inited;

  int get totalImageCount => _totalImageCount;
  int _totalImageCount = 0;

  void tryInit() async {
    if (inited != null) {
      return;
    }

    final pathList = await getImagePathList();
    // if (kDebugMode) {
    //   print(pathList);
    // }

    // 최대 100 스테이지까지만 찾아본다.
    const maxImageCount = 100;
    for (var i = 0; i < maxImageCount; i++) {
      if (pathList.contains(getLockImagePath(i + 1)) &&
          pathList.contains(getClearImagePath(i + 1))) {
        _totalImageCount = i + 1;
      }
    }

    if (kDebugMode) {
      print('Total tmage count: $_totalImageCount');
    }

    _inited = true;
    notifyListeners();
  }
}
