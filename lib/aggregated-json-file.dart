import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class AggregatedJSONFile {
  final String dataPath;

  DateTime _startTime;
  List<Map> _items = new List<Map>();

  AggregatedJSONFile(this.dataPath);

  void addItem(DateTime timeStamp, Map item) {
    if (_startTime != null && timeStamp.difference(_startTime).inSeconds > 300) {
      saveAndClear();
    }

    if (_startTime == null) {
      _startTime = timeStamp;
    }

    _items.add(item);
  }

  Future saveAndClear() async {
    if (_items.isEmpty) return;

    final String fileName = '${_startTime.millisecondsSinceEpoch}.json';
    DateTime _saveTime = _startTime;

    _startTime = null;

    List saveItems = _items;
    _items = new List();

    try {
      final Directory extDir = await getExternalStorageDirectory();
      final String dirPath =
          '${extDir.path}/ConnectivityLogger/${_saveTime.year}-${_saveTime.month}-${_saveTime.day}/$dataPath';
      await Directory(dirPath).create(recursive: true);
      final String filePath = '$dirPath/$fileName';
      File(filePath).writeAsString(json.encode({'items': saveItems}));
    } catch (e) {
      print("Caught exception while trying to save data as json file: ${e.toString()}");
    }
  }
}
