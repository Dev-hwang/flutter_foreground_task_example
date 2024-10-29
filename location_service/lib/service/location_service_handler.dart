import 'dart:async';
import 'dart:convert';

import 'package:fl_location/fl_location.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startLocationService() {
  FlutterForegroundTask.setTaskHandler(LocationServiceHandler());
}

class LocationServiceHandler extends TaskHandler {
  StreamSubscription<Location>? _streamSubscription;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _streamSubscription = FlLocation.getLocationStream().listen((location) {
      final double lat = location.latitude;
      final double lon = location.longitude;

      // Update notification content.
      final String text = 'lat: $lat, lon: $lon';
      FlutterForegroundTask.updateService(notificationText: text);

      // Send data to main isolate.
      final String locationJson = jsonEncode(location.toJson());
      FlutterForegroundTask.sendDataToMain(locationJson);
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // not use
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }
}
