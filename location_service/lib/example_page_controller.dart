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

  // public
  Future<void> requestPermissions() async {
    final LocationPermission locationPermission =
        await FlLocation.requestLocationPermission();
    if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      throw Exception(
          'To start location service, you must grant location permission.');
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      final NotificationPermission notificationPermission =
          await FlutterForegroundTask.checkNotificationPermission();
      if (notificationPermission != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    }
  }

  Future<void> initService() async {
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
      foregroundTaskOptions: const ForegroundTaskOptions(
        isOnceEvent: true,
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> startService() async {
    final ServiceRequestResult result =
        await FlutterForegroundTask.startService(
      notificationTitle: 'Location Service',
      notificationText: '',
      callback: startLocationService,
    );

    if (!result.success) {
      throw result.error ??
          Exception('An error occurred and the service could not be started.');
    }
  }

  Future<void> stopService() async {
    final ServiceRequestResult result =
        await FlutterForegroundTask.stopService();

    if (!result.success) {
      throw result.error ??
          Exception('An error occurred and the service could not be stopped.');
    }
  }

  // private
  void _onReceiveTaskData(dynamic data) {
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

    // Logger
    dev.log('$errorMessage\n${s.toString()}');

    // Show snackbar
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
      requestPermissions().then((_) async {
        final bool isRunningService =
            await FlutterForegroundTask.isRunningService;
        if (!isRunningService) {
          await initService();
          startService();
        }
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
