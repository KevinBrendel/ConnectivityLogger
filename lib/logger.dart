import 'dart:async';
import 'package:connectivity_logger/aggregated-json-file.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wifi/wifi.dart';

class Logger {
  static const intervalInSeconds = 30;

  bool _logging = false;

  Timer _timer;
  FlutterBlue _flutterBlue;
  Function _onLog;

  StreamSubscription<Position> _positionStream;
  StreamSubscription<List<ScanResult>> _bluetoothStream;

  AggregatedJSONFile jsonFile = new AggregatedJSONFile("");

  Logger(this._onLog);

  start() {
    _logging = true;

    if (_timer == null) {
      _timer = new Timer.periodic(Duration(seconds: intervalInSeconds), _log);
    }

    _flutterBlue = FlutterBlue.instance;

    if (_positionStream == null) {
      _startPositionStream();
    }

    if (_bluetoothStream == null) {
      _startBluetoothStream();
    }
  }

  stop() {
    _logging = false;

    saveData();

    _positionStream?.cancel();
    _positionStream = null;

    _flutterBlue?.stopScan();
    _bluetoothStream?.cancel();
    _bluetoothStream = null;

    _timer?.cancel();
    _timer = null;
  }

  addLabel(String label) {
    DateTime now = DateTime.now();
    jsonFile.addItem(now, {
      "type": "label",
      'timestamp': now.millisecondsSinceEpoch,
      "value": label,
    });
  }

  saveData() {
    jsonFile.saveAndClear();
  }

  _log(Timer _) async {
    //_getBluetoothDevices();
    _getWifiDevices();
    //_getCurrentLocation();
    _onLog();
  }

  _getWifiDevices() async {
    List<WifiResult> wifiList = await Wifi.list('');

    DateTime now = DateTime.now();
    List<Map<String, dynamic>> wifiItems = List<Map<String, dynamic>>();

    wifiList.forEach((result) {
      wifiItems.add({
        "ssid": result.ssid,
        "lvl": result.level.toString(),
      });
    });

    jsonFile.addItem(now, {
      "type": "wifiScan",
      'timestamp': now.millisecondsSinceEpoch,
      "results": wifiItems,
    });
  }

  // _getBluetoothDevices() async {
  //   try {
  //     _flutterBlue.scanResults.listen((results) {
  //       DateTime now = DateTime.now();
  //       List<Map<String, dynamic>> bluetoothItems = List<Map<String, dynamic>>();

  //       results.forEach((result) {
  //         bluetoothItems.add({
  //           "id": result.device.id.toString(),
  //           "name": result.device.name,
  //           "rssi": result.rssi.toString(),
  //         });
  //       });

  //       jsonFile.addItem(now, {
  //         "type": "bluetoothScan",
  //         'timestamp': now.millisecondsSinceEpoch,
  //         "results": bluetoothItems,
  //       });
  //     });

  //     await _flutterBlue.startScan(timeout: Duration(seconds: intervalInSeconds - 1));
  //     _flutterBlue.stopScan();
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  // _getCurrentLocation() async {
  //   try {
  //     Position position = await Geolocator().getCurrentPosition();
  //     jsonFile.addItem(position.timestamp, {
  //       "type": "position",
  //       'timestamp': position.timestamp.millisecondsSinceEpoch,
  //       'lng': position.longitude,
  //       'lat': position.latitude,
  //       'accuracy': position.accuracy,
  //       'altitude': position.altitude,
  //       'heading': position.heading,
  //       'speed': position.speed,
  //       'speedAccuracy': position.speedAccuracy,
  //     });
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  _startBluetoothStream() async {
    try {
      _bluetoothStream = _flutterBlue.scanResults.listen((results) {
        DateTime now = DateTime.now();
        List<Map<String, dynamic>> bluetoothItems = List<Map<String, dynamic>>();

        results.forEach((result) {
          bluetoothItems.add({
            "id": result.device.id.toString(),
            "name": result.device.name,
            "rssi": result.rssi.toString(),
          });
        });

        jsonFile.addItem(now, {
          "type": "bluetoothScan",
          'timestamp': now.millisecondsSinceEpoch,
          "results": bluetoothItems,
        });
      });

      while (_logging) {
        await _flutterBlue.stopScan();
        await _flutterBlue.startScan(timeout: Duration(seconds: intervalInSeconds));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  _startPositionStream() {
    try {
      _positionStream = Geolocator().getPositionStream().listen((position) {
        jsonFile.addItem(position.timestamp, {
          "type": "position",
          'timestamp': position.timestamp.millisecondsSinceEpoch,
          'lng': position.longitude,
          'lat': position.latitude,
          'accuracy': position.accuracy,
          'altitude': position.altitude,
          'heading': position.heading,
          'speed': position.speed,
          'speedAccuracy': position.speedAccuracy,
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
