import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'constants.dart';
import 'record_info.dart';
import 'record_player_dialog.dart';
import 'record_service.dart';

class ExamplePageController {
  State? _state;

  final ValueNotifier<bool> isRunningService = ValueNotifier(false);
  final ValueNotifier<List<RecordInfo>> recordHistory = ValueNotifier([]);

  // ui
  void onRecordStartButtonPressed() async {
    try {
      await _requestRecordPermission();
      await _startService();
      isRunningService.value = true;
    } catch (e, s) {
      _handleError(e, s);
    }
  }

  void onRecordStopButtonPressed() async {
    try {
      await _stopService();
      isRunningService.value = false;
      refreshRecordHistory();
    } catch (e, s) {
      _handleError(e, s);
    }
  }

  void onRecordHistoryItemPressed(RecordInfo recordInfo) async {
    final State? state = _state;
    if (state != null && state.mounted) {
      showDialog(
        context: state.context,
        builder: (_) => RecordPlayerDialog(recordInfo: recordInfo),
      );
    }
  }

  Future<void> refreshRecordHistory() async {
    try {
      final Directory supportDir = await getApplicationSupportDirectory();
      final Directory recordDir =
          Directory(p.join(supportDir.path, Constants.recordFolderName));

      if (await recordDir.exists()) {
        final List<FileSystemEntity> entities = await recordDir.list().toList();
        final List<RecordInfo> result = [];
        for (final FileSystemEntity entity in entities) {
          result.add(RecordInfo.fromFileSystemEntity(entity));
        }

        recordHistory.value = result;
      }
    } catch (e, s) {
      _handleError(e, s);
    }
  }

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

  Future<void> _requestRecordPermission() async {
    if (!await AudioRecorder().hasPermission()) {
      throw Exception(
          'To start record service, you must grant microphone permission.');
    }
  }

  Future<void> _initService() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'record_service',
        channelName: 'Record Service',
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

  Future<void> _startService() async {
    final ServiceRequestResult result =
        await FlutterForegroundTask.startService(
      serviceId: 300,
      notificationTitle: 'Record Service',
      notificationText: '',
      callback: startRecordService,
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

  // handler
  void _onReceiveTaskData(Object data) {
    // handle task data
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
      _requestPlatformPermissions();
      _initService();
      refreshRecordHistory();
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
    isRunningService.dispose();
    recordHistory.dispose();
  }
}
