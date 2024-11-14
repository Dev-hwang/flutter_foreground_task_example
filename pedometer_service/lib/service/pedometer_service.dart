import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/my_pedestrian_status.dart';
import '../models/my_step_count.dart';
import 'pedometer_service_handler.dart';

typedef StepCountCallback = void Function(MyStepCount stepCount);
typedef PedestrianStatusCallback = void Function(MyPedestrianStatus status);

class PedometerService {
  PedometerService._();

  static final PedometerService instance = PedometerService._();

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

  Future<void> _requestActivityPermission() async {
    final Permission permission = Platform.isAndroid
        ? Permission.activityRecognition
        : Permission.sensors;
    if (await permission.isGranted) {
      return;
    }

    final PermissionStatus status = await permission.request();
    if (!status.isGranted) {
      throw Exception(
          'To start pedometer service, you must grant activity permission.');
    }
  }

  void init() {
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'pedometer_service',
        channelName: 'Pedometer Service',
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
    await _requestActivityPermission();

    final ServiceRequestResult result =
        await FlutterForegroundTask.startService(
      serviceId: 500,
      notificationTitle: 'Pedometer Service is running',
      notificationText: '',
      callback: startPedometerService,
    );

    if (!result.success) {
      throw result.error ??
          Exception('An error occurred and the service could not be started.');
    }
  }

  Future<void> stop() async {
    final ServiceRequestResult result =
        await FlutterForegroundTask.stopService();

    if (!result.success) {
      throw result.error ??
          Exception('An error occurred and the service could not be stopped.');
    }
  }

  Future<bool> get isRunningService => FlutterForegroundTask.isRunningService;

  // ------------- Service callback -------------
  final List<StepCountCallback> _stepCountCallbacks = [];
  final List<PedestrianStatusCallback> _pedestrianStatusCallbacks = [];

  void _onReceiveTaskData(Object data) {
    if (data is! Map<String, dynamic>) {
      return;
    }

    if (MyStepCount.containsData(data)) {
      final MyStepCount stepCount = MyStepCount.fromJson(data);
      for (final callback in _stepCountCallbacks.toList()) {
        callback(stepCount);
      }
    } else if (MyPedestrianStatus.containsData(data)) {
      final MyPedestrianStatus status = MyPedestrianStatus.fromJson(data);
      for (final callback in _pedestrianStatusCallbacks.toList()) {
        callback(status);
      }
    }
  }

  void addStepCountCallback(StepCountCallback callback) {
    if (!_stepCountCallbacks.contains(callback)) {
      _stepCountCallbacks.add(callback);
    }
  }

  void removeStepCountCallback(StepCountCallback callback) {
    _stepCountCallbacks.remove(callback);
  }

  void addPedestrianStatusCallback(PedestrianStatusCallback callback) {
    if (!_pedestrianStatusCallbacks.contains(callback)) {
      _pedestrianStatusCallbacks.add(callback);
    }
  }

  void removePedestrianStatusCallback(PedestrianStatusCallback callback) {
    _pedestrianStatusCallbacks.remove(callback);
  }
}
