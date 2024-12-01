import 'dart:convert';
import 'dart:io';

import 'package:fl_location/fl_location.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'location_service_handler.dart';

typedef LocationChanged = void Function(Location location);

class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  // ------------- Service API -------------
  Future<void> _requestPlatformPermissions() async {
    // Android 13+, you need to allow notification permission to display foreground service notification.
    //
    // iOS: If you need notification, ask for permission.
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      // Android 12+, there are restrictions on starting a foreground service.
      //
      // To restart the service on device reboot or unexpected problem, you need to allow below permission.
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // Use this utility only if you provide services that require long-term survival,
      // such as exact alarm service, healthcare service, or Bluetooth communication.
      //
      // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
      // Using this permission may make app distribution difficult due to Google policy.
      if (!await FlutterForegroundTask.canScheduleExactAlarms) {
        // When you call this function, will be gone to the settings page.
        // So you need to explain to the user why set it.
        await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    if (!await FlLocation.isLocationServicesEnabled) {
      throw Exception('Location services is disabled.');
    }

    LocationPermission permission = await FlLocation.checkLocationPermission();
    if (permission == LocationPermission.denied) {
      // Android: ACCESS_COARSE_LOCATION or ACCESS_FINE_LOCATION
      // iOS 12-: NSLocationWhenInUseUsageDescription or NSLocationAlwaysAndWhenInUseUsageDescription
      // iOS 13+: NSLocationWhenInUseUsageDescription
      permission = await FlLocation.requestLocationPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission has been ${permission.name}.');
    }

    // Android: You must request location permission one more time to access background location.
    // iOS 12-: You can request always permission through the above request.
    // iOS 13+: You can only request whileInUse permission through the above request.
    // When the app enters the background, a prompt will appear asking for always permission.
    if (Platform.isAndroid && permission == LocationPermission.whileInUse) {
      // You need a clear explanation of why your app's feature needs access to background location.
      // https://developer.android.com/develop/sensors-and-location/location/permissions#request-background-location

      // Android: ACCESS_BACKGROUND_LOCATION
      permission = await FlLocation.requestLocationPermission();

      if (permission != LocationPermission.always) {
        throw Exception(
            'To start location service, you must always grant location permission.');
      }
    }
  }

  void init() {
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'location_service',
        channelName: 'Location Service',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> start() async {
    await _requestPlatformPermissions();
    await _requestLocationPermission();

    final ServiceRequestResult result =
        await FlutterForegroundTask.startService(
      serviceId: 200,
      notificationTitle: 'Location Service',
      notificationText: '',
      callback: startLocationService,
    );

    if (result is ServiceRequestFailure) {
      throw result.error;
    }
  }

  Future<void> stop() async {
    final ServiceRequestResult result =
        await FlutterForegroundTask.stopService();

    if (result is ServiceRequestFailure) {
      throw result.error;
    }
  }

  Future<bool> get isRunningService => FlutterForegroundTask.isRunningService;

  // ------------- Service callback -------------
  final List<LocationChanged> _callbacks = [];

  void _onReceiveTaskData(Object data) {
    if (data is! String) {
      return;
    }

    final Map<String, dynamic> locationJson = jsonDecode(data);
    final Location location = Location.fromJson(locationJson);
    for (final LocationChanged callback in _callbacks.toList()) {
      callback(location);
    }
  }

  void addLocationChangedCallback(LocationChanged callback) {
    if (!_callbacks.contains(callback)) {
      _callbacks.add(callback);
    }
  }

  void removeLocationChangedCallback(LocationChanged callback) {
    _callbacks.remove(callback);
  }
}
