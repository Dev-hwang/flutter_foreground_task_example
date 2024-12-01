import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geofencing_api/geofencing_api.dart';
import 'package:geofencing_service/service/regions_store.dart';

import '../models/command_data.dart';
import '../models/geofence_state.dart';
import 'geofencing_service_handler.dart';

typedef GeofenceStateChanged = void Function(GeofenceState state);

class GeofencingService {
  GeofencingService._();

  static final GeofencingService instance = GeofencingService._();

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
    if (!await Geofencing.instance.isLocationServicesEnabled) {
      throw Exception('Location services is disabled.');
    }

    LocationPermission permission =
        await Geofencing.instance.getLocationPermission();
    if (permission == LocationPermission.denied) {
      // Android: ACCESS_COARSE_LOCATION or ACCESS_FINE_LOCATION
      // iOS 12-: NSLocationWhenInUseUsageDescription or NSLocationAlwaysAndWhenInUseUsageDescription
      // iOS 13+: NSLocationWhenInUseUsageDescription
      permission = await Geofencing.instance.requestLocationPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission has been ${permission.name}.');
    }

    if (Platform.isAndroid && permission == LocationPermission.whileInUse) {
      // You need a clear explanation of why your app's feature needs access to background location.
      // https://developer.android.com/develop/sensors-and-location/location/permissions#request-background-location

      // Android: ACCESS_BACKGROUND_LOCATION
      permission = await Geofencing.instance.requestLocationPermission();

      if (permission != LocationPermission.always) {
        throw Exception(
            'To start geofencing service, you must always grant location permission.');
      }
    }
  }

  void init() {
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'geofencing_service',
        channelName: 'Geofencing Service',
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

  Future<void> start({Set<GeofenceRegion> regions = const {}}) async {
    await _requestPlatformPermissions();
    await _requestLocationPermission();

    for (final GeofenceRegion region in regions) {
      await RegionsStore.instance.saveRegion(region);
    }

    final ServiceRequestResult result =
        await FlutterForegroundTask.startService(
      serviceId: 400,
      notificationTitle: 'Geofencing Service is running',
      notificationText: '',
      callback: startGeofencingService,
    );

    if (result is ServiceRequestFailure) {
      throw result.error;
    }
  }

  Future<void> stop() async {
    await RegionsStore.instance.clearRegions();

    final ServiceRequestResult result =
        await FlutterForegroundTask.stopService();

    if (result is ServiceRequestFailure) {
      throw result.error;
    }
  }

  Future<bool> get isRunningService => FlutterForegroundTask.isRunningService;

  // ------------- Service callback -------------
  final List<GeofenceStateChanged> _callbacks = [];

  void _onReceiveTaskData(Object data) {
    if (data is! Map<String, dynamic>) {
      return;
    }

    final GeofenceState geofenceState = GeofenceState.fromJson(data);
    for (final GeofenceStateChanged callback in _callbacks.toList()) {
      callback(geofenceState);
    }
  }

  void addGeofenceStateChangedCallback(GeofenceStateChanged callback) {
    if (!_callbacks.contains(callback)) {
      _callbacks.add(callback);
    }
  }

  void removeGeofenceStateChangedCallback(GeofenceStateChanged callback) {
    _callbacks.remove(callback);
  }

  // ------------- Service function -------------
  void sendCommandData(CommandData commandData) {
    FlutterForegroundTask.sendDataToTask(commandData.toJson());
  }

  void addRegion(GeofenceRegion region) async {
    await RegionsStore.instance.saveRegion(region);

    final CommandData commandData =
        CommandData(command: Command.addRegion, data: region.toJson());
    sendCommandData(commandData);
  }

  void removeRegionById(String id) async {
    await RegionsStore.instance.removeRegionById(id);

    final CommandData commandData =
        CommandData(command: Command.removeRegionById, data: id);
    sendCommandData(commandData);
  }

  void clearRegions() async {
    await RegionsStore.instance.clearRegions();

    const CommandData commandData = CommandData(command: Command.clearRegions);
    sendCommandData(commandData);
  }
}
