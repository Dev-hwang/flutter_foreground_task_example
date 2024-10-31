import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';

import '../config/constants.dart';
import '../models/record_file_info.dart';
import '../models/record_status.dart';
import 'record_service_handler.dart';

typedef RecordStatusChanged = void Function(RecordStatus status);

class RecordService {
  RecordService._();

  static final RecordService instance = RecordService._();

  RecordStatus _prevRecordStatus = RecordStatus.stopped;
  RecordStatus _currRecordStatus = RecordStatus.stopped;

  // ------------- Service API -------------
  Future<void> _requestNotificationPermission() async {
    // Android 13+, you need to allow notification permission to display foreground service notification.
    //
    // iOS: If you need notification, ask for permission.
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  Future<void> _requestRecordPermission() async {
    if (!await AudioRecorder().hasPermission()) {
      throw Exception(
          'To start record service, you must grant microphone permission.');
    }
  }

  void init() {
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'record_service',
        channelName: 'Record Service',
        channelImportance: NotificationChannelImportance.MAX,
        priority: NotificationPriority.MAX,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> start() async {
    await _requestNotificationPermission();
    await _requestRecordPermission();

    _updateRecordStatus(RecordStatus.starting);

    final ServiceRequestResult result =
        await FlutterForegroundTask.startService(
      serviceId: 300,
      notificationTitle: 'Record Service',
      notificationText: '',
      callback: startRecordService,
    );

    if (!result.success) {
      _rollbackRecordStatus();
      throw result.error ??
          Exception('An error occurred and the service could not be started.');
    }

    _updateRecordStatus(RecordStatus.started);
  }

  Future<void> stop() async {
    _updateRecordStatus(RecordStatus.stopping);

    final ServiceRequestResult result =
        await FlutterForegroundTask.stopService();

    if (!result.success) {
      _rollbackRecordStatus();
      throw result.error ??
          Exception('An error occurred and the service could not be stopped.');
    }

    _updateRecordStatus(RecordStatus.stopped);
  }

  Future<bool> get isRunningService => FlutterForegroundTask.isRunningService;

  RecordStatus get recordStatus => _currRecordStatus;

  // ------------- Service callback -------------
  final List<RecordStatusChanged> _callbacks = [];

  void _updateRecordStatus(RecordStatus status) {
    _prevRecordStatus = _currRecordStatus;
    _currRecordStatus = status;
    for (final RecordStatusChanged callback in _callbacks.toList()) {
      callback(status);
    }
  }

  void _rollbackRecordStatus() {
    final RecordStatus prevStatus = _prevRecordStatus;
    _currRecordStatus = prevStatus;
    for (final RecordStatusChanged callback in _callbacks.toList()) {
      callback(prevStatus);
    }
  }

  void _onReceiveTaskData(Object data) {
    if (data == 'stop') {
      stop();
    }
  }

  void addRecordStatusChangedCallback(RecordStatusChanged callback) {
    if (!_callbacks.contains(callback)) {
      _callbacks.add(callback);
    }
  }

  void removeRecordStatusChangedCallback(RecordStatusChanged callback) {
    _callbacks.remove(callback);
  }

  // ------------- Service function -------------
  Future<List<RecordFileInfo>> getRecordFileInfoList() async {
    final Directory supportDir = await getApplicationSupportDirectory();
    final Directory recordDir =
        Directory(p.join(supportDir.path, Constants.recordDirectoryName));

    final List<RecordFileInfo> result = [];
    if (await recordDir.exists()) {
      final List<FileSystemEntity> entities = await recordDir.list().toList();
      for (final FileSystemEntity entity in entities) {
        result.add(RecordFileInfo.fromFileSystemEntity(entity));
      }
    }

    return result;
  }
}
