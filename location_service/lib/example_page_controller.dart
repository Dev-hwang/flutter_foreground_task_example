import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:fl_location/fl_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'location_service.dart';

class ExamplePageController {
  State? _state;

  final ValueNotifier<Location?> locationNotifier = ValueNotifier(null);

  // private
  Future<void> _requestPlatformPermissions() async {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    final LocationPermission locationPermission =
        await FlLocation.requestLocationPermission();
    if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      throw Exception(
          'To start location service, you must grant location permission.');
    }
  }

  Future<void> _initService() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'location_service',
        channelName: 'Location Service',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.once(),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> _startService() async {
    final ServiceRequestResult result =
        await FlutterForegroundTask.startService(
      serviceId: 200,
      notificationTitle: 'Location Service',
      notificationText: '',
      callback: startLocationService,
    );

    if (!result.success) {
      throw result.error ??
          Exception('An error occurred and the service could not be started.');
    }
  }

  Future<void> _stopService() async {
    final ServiceRequestResult result =
        await FlutterForegroundTask.stopService();

    if (!result.success) {
      throw result.error ??
          Exception('An error occurred and the service could not be stopped.');
    }
  }

  void _onReceiveTaskData(Object data) {
    if (data is String) {
      final Map<String, dynamic> locationJson = jsonDecode(data);
      final Location location = Location.fromJson(locationJson);
      locationNotifier.value = location;
    }
  }

  void _handleError(Object e, StackTrace s) {
    String errorMessage;
    if (e is PlatformException) {
      errorMessage = '${e.code}: ${e.message}';
    } else {
      errorMessage = e.toString();
    }

    // print error to console.
    dev.log('$errorMessage\n${s.toString()}');

    // show error to user.
    final State? state = _state;
    if (state != null && state.mounted) {
      final SnackBar snackBar = SnackBar(content: Text(errorMessage));
      ScaffoldMessenger.of(state.context).showSnackBar(snackBar);
    }
  }

  @mustCallSuper
  void attach(State state) {
    _state = state;
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

    try {
      // check permissions -> if granted -> start service
      _requestPlatformPermissions().then((_) {
        _requestLocationPermission().then((_) async {
          // already started
          if (await FlutterForegroundTask.isRunningService) {
            return;
          }

          await _initService();
          _startService();
        });
      });
    } catch (e, s) {
      _handleError(e, s);
    }
  }

  @mustCallSuper
  void detach() {
    _state = null;
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
  }

  @mustCallSuper
  void dispose() {
    detach();
    locationNotifier.dispose();
  }
}
