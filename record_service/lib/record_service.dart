import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'constants.dart';

@pragma('vm:entry-point')
void startRecordService() {
  FlutterForegroundTask.setTaskHandler(RecordServiceHandler());
}

class RecordServiceHandler extends TaskHandler {
  final AudioRecorder _record = AudioRecorder();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await _startRecord();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // not use
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    await _stopRecord();
  }

  @override
  void onNotificationButtonPressed(String id) async {
    if (id == Constants.actionStopRecord) {
      await _stopRecord();
      if (await FlutterForegroundTask.isRunningService) {
        FlutterForegroundTask.stopService();
      }
    }
  }

  Future<void> _startRecord() async {
    // create record directory if it doesn't exist
    final Directory supportDir = await getApplicationSupportDirectory();
    final Directory recordDir =
        Directory(p.join(supportDir.path, Constants.recordFolderName));
    await recordDir.create(recursive: true);

    // determine file path
    final String currTime =
        DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    final String filePath = p.join(recordDir.path, '$currTime.m4a');

    // start record
    await _record.start(const RecordConfig(), path: filePath);

    // create stop action button
    FlutterForegroundTask.updateService(
      notificationText: 'recording..',
      notificationButtons: [
        const NotificationButton(id: Constants.actionStopRecord, text: 'stop'),
      ],
    );
  }

  Future<void> _stopRecord() async {
    // stop record
    await _record.dispose();
  }
}
