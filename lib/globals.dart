import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

String _getFileName(int stageId) => '${stageId.toString().padLeft(2, '0')}.png';

String get _resourceDomain => kDebugMode ? 'tests' : 'live';

String get _resourcePrefix => 'assets/$_resourceDomain/images';

String getLockImagePath(int stageId) =>
    '$_resourcePrefix/lock/${_getFileName(stageId)}';

String getClearImagePath(int stageId) =>
    '$_resourcePrefix/clear/${_getFileName(stageId)}';

Future<List<String>> getImagePathList() async {
  var manifest = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = json.decode(manifest);

  return manifestMap.keys
      .where((key) => key.startsWith(_resourcePrefix))
      .toList();
}
